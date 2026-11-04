#!/usr/bin/env python3
"""Score a candidate line against canonical Ghost dialogue.

This is a starter heuristic, not a truth test. Replace or tune it once real
canon lines exist. Exit 0 on pass, 1 on fail, 2 when the database is missing.
"""
import os
import re
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
SPEAKER = "Ghost"


def tokens(text):
    return re.findall(r"[a-z0-9']+", text.lower())


def ngrams(words, n=4):
    return {tuple(words[i:i + n]) for i in range(max(0, len(words) - n + 1))}


def corpus():
    lore = os.environ.get('LORE') or os.path.join(REPO, 'lore')
    db = os.environ.get('GRIMOIRE_DB') or os.path.join(lore, 'db', 'grimoire.db')
    if not os.path.exists(db):
        print('database not found; run ./setup.sh')
        sys.exit(2)
    conn = sqlite3.connect(f'file:{db}?mode=ro', uri=True)
    try:
        rows = conn.execute(
            'SELECT line FROM transcript_lines WHERE speaker LIKE ? AND is_stage_dir=0',
            (f'%{SPEAKER}%',)).fetchall()
    finally:
        conn.close()
    return ' '.join(r[0] for r in rows if r[0])


def main():
    if len(sys.argv) < 2:
        print('usage: voice-scorer.py "<line>"')
        return 2
    candidate = ' '.join(sys.argv[1].split())
    if len(tokens(candidate)) < 8:
        print('FAIL: too short to score')
        return 1
    reference = corpus()
    if not reference:
        print('SKIP: no canonical lines for this speaker yet')
        return 0
    overlap = len(ngrams(tokens(candidate)) & ngrams(tokens(reference)))
    total = max(1, len(ngrams(tokens(candidate))))
    score = overlap / total
    verdict = 'PASS' if score >= 0.15 else 'FAIL'
    print(f'{verdict}: {SPEAKER} voice score {score:.2f}')
    return 0 if verdict == 'PASS' else 1


if __name__ == '__main__':
    sys.exit(main())
