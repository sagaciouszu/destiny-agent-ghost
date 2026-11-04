#!/bin/bash
# Generic voice consistency check. Reads `forbidden_terms` from persona.json and
# flags them inside quoted strings, unless the quote is verified canon.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"
LORE="${LORE:-$REPO/lore}"
DB="${DB:-$LORE/db/grimoire.db}"

python3 - "$DB" "$REPO" <<'PY'
import json, os, re, sqlite3, sys
db, repo = sys.argv[1], sys.argv[2]
persona_path = os.path.join(repo, 'persona.json')
persona = json.load(open(persona_path, encoding='utf-8')) if os.path.exists(persona_path) else {}
terms = [t.lower() for t in persona.get('forbidden_terms') or [] if t]
if not terms:
    print('no forbidden_terms declared; PASS')
    sys.exit(0)
if not os.path.exists(db):
    print(f'FAIL: database missing at {db}')
    sys.exit(1)
speaker = persona.get('speaker') or ''
conn = sqlite3.connect(db)
canon = set()
if speaker:
    for (line,) in conn.execute('SELECT line FROM transcript_lines WHERE speaker=?', (speaker,)):
        if line:
            canon.add(re.sub(r'\s+', ' ', line.lower()))
conn.close()

hits = []
for root, dirs, files in os.walk(repo):
    dirs[:] = [d for d in dirs if d not in ('.git', 'lore', 'memory', '__pycache__', 'reference', 'tests')]
    for name in files:
        if not name.endswith('.md'):
            continue
        path = os.path.join(root, name)
        for line in open(path, encoding='utf-8', errors='ignore'):
            for m in re.finditer(r'"([^"]{7,})"', line):
                quote = m.group(1).strip()
                if any(t in quote.lower() for t in terms):
                    if any(quote.lower() in c or c in quote.lower() for c in canon):
                        continue
                    hits.append((os.path.relpath(path, repo), quote[:100]))
print(f'forbidden terms: {terms}')
if hits:
    for path, quote in hits[:10]:
        print(f'  {path}: {quote}')
    print(f'FAIL: {len(hits)} contaminated quote(s)')
    sys.exit(1)
print('PASS: no contaminated quotes')
PY
