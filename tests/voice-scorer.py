#!/usr/bin/env python3
"""Ghost Statistical Voice Similarity Scorer.

Scores a candidate line against the canonical Ghost corpus in the grimoire
database. Components: vocabulary overlap (0-20), bigram/trigram phrasing
(0-10), signature marker density (0-25), sentence cadence (0-15), character
3-gram overlap (0-15), signature phrases (0-15), a forbidden-term penalty
read from persona.json (0 to -25), plus brevity (0-5) and consistency (0-5)
bonuses. The total is clamped to 0-100; PASS at >= 55.

Exit codes: 0 = pass, 1 = fail (or input too short / no corpus),
2 = grimoire database missing.

Usage: ./voice-scorer.py "We have to win. I am picking up a signal."
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)

SPEAKER = "Ghost"
MIN_TOKENS = 8
PASS_SCORE = 55.0

# Signature markers verified against the Ghost corpus (document frequency in
# the grimoire database); every token occurs in canonical lines.
MARKERS = {
    "guardian", "light", "traveler", "cayde", "fallen", "vex", "hive",
    "cabal", "signal", "readings", "scanner", "systems", "ship", "wait",
    "careful", "sensors", "transmat", "siva", "zavala", "ikora", "osiris",
    "mara", "rasputin", "exo", "hello", "servitor", "captain", "titan",
    "ghost", "weird", "here", "scan",
}

# Signature phrases verified present in the corpus (matched as substrings of
# the normalized candidate).
SIG_PHRASES = [
    "looks like", "must be", "some kind", "we've got", "picking up",
    "there are", "red legion", "i'm picking", "golden age", "let's get",
    "out here", "don't know", "fallen are", "black garden", "vex are",
    "we're here", "i'm not sure", "i've never seen", "let's see what",
    "must have been", "we've got company", "i'm so sorry",
    "we're almost there", "we have to win", "the light", "another brig",
    "be careful", "we should ask", "anything about it", "i've heard rumors",
]


def tokenize(text):
    return re.findall(r"[a-z0-9']+", text.lower().replace("\u2019", "'"))


def ngrams(tokens, n):
    return [tuple(tokens[i:i + n]) for i in range(len(tokens) - n + 1)]


def normalize(text):
    return re.sub(r"\s+", " ", text.lower().replace("\u2019", "'")).strip()


def load_corpus():
    """Canonical Ghost lines from the grimoire DB; exit 2 when it is missing."""
    candidates = [
        os.environ.get("GRIMOIRE_DB", ""),
        os.path.join(os.environ.get("LORE", ""), "db", "grimoire.db"),
        os.path.join(HERE, "..", "lore", "db", "grimoire.db"),
    ]
    for db in candidates:
        if db and os.path.exists(db):
            import sqlite3
            conn = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
            try:
                rows = conn.execute(
                    "SELECT line FROM transcript_lines "
                    "WHERE speaker = ? AND is_stage_dir=0",
                    (SPEAKER,)).fetchall()
            finally:
                conn.close()
            return [r[0] for r in rows if r[0]]
    print("database not found; run ./setup.sh")
    sys.exit(2)


def load_forbidden_terms():
    """Forbidden terms from the persona, so the scorer and the persona agree."""
    try:
        data = json.load(open(os.path.join(REPO, "persona.json"), encoding="utf-8"))
    except (OSError, ValueError):
        return []
    return [str(t).lower().replace("\u2019", "'")
            for t in (data.get("forbidden_terms") or []) if t]


def score_response(candidate, corpus_lines, forbidden_terms):
    cand_tokens = tokenize(candidate)
    if not cand_tokens:
        return 0.0, {}

    all_tokens = []
    for line in corpus_lines:
        all_tokens.extend(tokenize(line))
    all_text = " ".join(all_tokens)

    vocab = set(all_tokens)
    bi_set = set(ngrams(all_tokens, 2))
    tri_set = set(ngrams(all_tokens, 3))

    # 1. Vocabulary overlap (0-20 pts)
    in_vocab = sum(1 for t in cand_tokens if t in vocab)
    vocab_score = min(20.0, (in_vocab / len(cand_tokens)) * 20.0)

    # 2. Bigram & trigram overlap with canonical phrasing (0-10 pts)
    cand_bi = ngrams(cand_tokens, 2)
    cand_tri = ngrams(cand_tokens, 3)
    bi_hits = sum(1 for b in cand_bi if b in bi_set) / max(1, len(cand_bi))
    tri_hits = sum(1 for t in cand_tri if t in tri_set) / max(1, len(cand_tri))
    ngram_score = min(10.0, (bi_hits * 12.0) + (tri_hits * 12.0))

    # 3. Signature marker density (0-25 pts)
    marker_hits = sorted({t for t in cand_tokens if t in MARKERS})
    marker_score = min(25.0, len(marker_hits) * 5.0)

    # 4. Sentence cadence (0-15 pts): Ghost averages ~6.6 words/sentence,
    #    short observational bursts that speed up under pressure.
    sents = [s.strip() for s in re.split(r"[.!?]+", candidate) if s.strip()]
    avg_words = len(cand_tokens) / max(1, len(sents))
    if 2.5 <= avg_words <= 8.0:
        cadence_score = 15.0
    elif 8.0 < avg_words <= 12.0:
        cadence_score = 12.0
    elif 12.0 < avg_words <= 16.0:
        cadence_score = 8.0
    elif avg_words < 2.5:
        cadence_score = 10.0
    elif avg_words <= 21.0:
        cadence_score = 5.0
    else:
        cadence_score = 2.0

    # 5. Character 3-gram overlap (0-15 pts)
    cand_text = normalize(candidate)
    cand_chars = {cand_text[i:i + 3] for i in range(len(cand_text) - 2)}
    corpus_chars = {all_text[i:i + 3] for i in range(len(all_text) - 2)}
    char_overlap = len(cand_chars & corpus_chars) / max(1, len(cand_chars))
    char_score = min(15.0, char_overlap * 15.0)

    # 6. Signature phrase detection (0-15 pts)
    found_phrases = [p for p in SIG_PHRASES if p in cand_text]
    phrase_score = min(15.0, len(found_phrases) * 3.0)

    # 7. Forbidden-term penalty from persona.json (0 to -25 pts)
    forbidden_found = sorted({
        t for t in forbidden_terms
        if (" " in t and t in cand_text) or (" " not in t and t in cand_tokens)
    })
    forbidden_penalty = min(25.0, len(forbidden_found) * 8.0)

    # 8. Brevity bonus (0-5 pts)
    word_count = len(cand_tokens)
    if word_count <= 25:
        brevity_bonus = 5.0
    elif word_count <= 40:
        brevity_bonus = 3.0
    else:
        brevity_bonus = 0.0

    # 9. Consistency bonus: longer answers that stay in voice (0-5 pts)
    if word_count > 30 and len(found_phrases) >= 5 and len(marker_hits) >= 4:
        consistency_bonus = 5.0
    elif word_count > 20 and len(found_phrases) >= 3 and len(marker_hits) >= 3:
        consistency_bonus = 3.0
    else:
        consistency_bonus = 0.0

    total_raw = (vocab_score + ngram_score + marker_score + cadence_score +
                 char_score + phrase_score + brevity_bonus +
                 consistency_bonus - forbidden_penalty)
    total = round(max(0.0, min(100.0, total_raw)), 1)

    details = {
        "vocab_score": round(vocab_score, 1),
        "ngram_score": round(ngram_score, 1),
        "marker_score": round(marker_score, 1),
        "cadence_score": round(cadence_score, 1),
        "char_score": round(char_score, 1),
        "phrase_score": round(phrase_score, 1),
        "forbidden_penalty": round(forbidden_penalty, 1),
        "brevity_bonus": round(brevity_bonus, 1),
        "consistency_bonus": round(consistency_bonus, 1),
        "markers_found": marker_hits,
        "phrases_found": found_phrases,
        "forbidden_found": forbidden_found,
        "avg_words_per_sentence": round(avg_words, 1),
        "corpus_lines": len(corpus_lines),
    }
    return total, details


def main():
    if len(sys.argv) < 2:
        print('usage: voice-scorer.py "<line>"')
        return 1
    candidate = " ".join(sys.argv[1:])
    corpus = load_corpus()
    print(f"=== {SPEAKER.upper()} STATISTICAL VOICE SCORER ===")
    print(f"Corpus size: {len(corpus)} canonical lines")
    if not corpus:
        print("Total Score: 0.0/100 (FAIL)")
        print("  Reason: no canonical lines for this speaker yet")
        return 1
    if len(tokenize(candidate)) < MIN_TOKENS:
        print("Total Score: 0.0/100 (FAIL)")
        print(f"  Reason: too short to score (need >= {MIN_TOKENS} tokens)")
        return 1
    total, d = score_response(candidate, corpus, load_forbidden_terms())
    status = "PASS" if total >= PASS_SCORE else "FAIL"
    print(f"Total Score: {total}/100 ({status})")
    print(f"  Vocabulary overlap : {d['vocab_score']}/20")
    print(f"  N-gram phrasing    : {d['ngram_score']}/10")
    print(f"  Signature markers  : {d['marker_score']}/25 ({', '.join(d['markers_found']) or 'none'})")
    print(f"  Sentence cadence   : {d['cadence_score']}/15 (avg {d['avg_words_per_sentence']} words/sentence)")
    print(f"  Char n-gram        : {d['char_score']}/15")
    print(f"  Signature phrases  : {d['phrase_score']}/15 ({', '.join(d['phrases_found']) or 'none'})")
    print(f"  Forbidden terms    : -{d['forbidden_penalty']}/25 ({', '.join(d['forbidden_found']) or 'none'})")
    print(f"  Brevity bonus      : +{d['brevity_bonus']}/5")
    print(f"  Consistency bonus  : +{d['consistency_bonus']}/5")
    return 0 if total >= PASS_SCORE else 1


if __name__ == "__main__":
    sys.exit(main())
