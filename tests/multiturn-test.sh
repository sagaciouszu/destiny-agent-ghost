#!/bin/bash
# Generic multi-turn arc test. Reads tests/multiturn.json:
#   [{"turn":1,"state":"IDENTITY","user":"...","response":"..."}, ...]
# Skips when the file is absent. Validates each response with the agent's
# validator and voice scorer.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"
DATA="$HERE/multiturn.json"
VALIDATOR="$HERE/validate-response.sh"
SCORER="$HERE/voice-scorer.py"

if [ ! -f "$DATA" ]; then
    echo "SKIP: no tests/multiturn.json"
    exit 0
fi

echo "=== MULTI-TURN ARC TEST ==="
PASS=0; TOTAL=0
while IFS=$'\t' read -r TURN STATE USER_MSG RESP; do
    TOTAL=$((TOTAL+1))
    echo "Turn $TURN [$STATE]"
    echo "  Guardian: $USER_MSG"
    echo "  Agent   : $RESP"
    if bash "$VALIDATOR" "$RESP" >/dev/null 2>&1; then REGEX_RES=PASS; else REGEX_RES=FAIL; fi
    if python3 "$SCORER" "$RESP" >/dev/null 2>&1; then STAT_RES=PASS; else STAT_RES=FAIL; fi
    echo "  Regex   : $REGEX_RES"
    echo "  Stat    : $STAT_RES"
    if [ "$REGEX_RES" = PASS ] && [ "$STAT_RES" = PASS ]; then
        PASS=$((PASS+1))
    fi
    echo ""
done < <(python3 - "$DATA" <<'PY'
import json,sys
for row in json.load(open(sys.argv[1])):
    print(f"{row.get('turn','?')}\t{row.get('state','')}\t{row.get('user','')}\t{row.get('response','')}")
PY
)

echo "Turns passed: $PASS/$TOTAL"
[ "$TOTAL" -gt 0 ] && [ "$PASS" -eq "$TOTAL" ]
