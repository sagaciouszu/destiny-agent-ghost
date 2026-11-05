#!/bin/bash
# Conversation smoke: confirm the database has lines for this speaker.
# Exits 1 when the speaker has no transcript lines (gating).
# Usage: bash tests/conversation-test.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"
LORE="${LORE:-$REPO/lore}"
DB="$LORE/db/grimoire.db"
SPEAKER="Ghost"

[ -f "$DB" ] || { echo "FAIL: database not found at $DB - run ./setup.sh"; exit 1; }

python3 - "$DB" "$SPEAKER" <<'PY'
import sqlite3, sys
db, speaker = sys.argv[1], sys.argv[2]
conn = sqlite3.connect(f'file:{db}?mode=ro', uri=True)
try:
    count = conn.execute(
        'SELECT COUNT(*) FROM transcript_lines WHERE speaker LIKE ? AND is_stage_dir=0',
        (f'%{speaker}%',)).fetchone()[0]
finally:
    conn.close()
print(f'speaker lines for {speaker}: {count}')
if not count:
    print('FAIL: no transcript lines yet; populate the persona from canon')
    sys.exit(1)
sys.exit(0)
PY
