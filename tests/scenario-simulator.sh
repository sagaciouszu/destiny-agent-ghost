#!/bin/bash
# Generic scenario simulator. Reads tests/scenarios.json:
#   [{"input":"...","response":"..."}, ...]
# Skips when the file is absent. Validates each response.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
DATA="$HERE/scenarios.json"
VALIDATOR="$HERE/validate-response.sh"
SCORER="$HERE/voice-scorer.py"

if [ ! -f "$DATA" ]; then
    echo "SKIP: no tests/scenarios.json"
    exit 0
fi

echo "=== SCENARIO SIMULATOR ==="
PASS=0; TOTAL=0
while IFS=$'\t' read -r INPUT RESP; do
    TOTAL=$((TOTAL+1))
    echo "Guardian: $INPUT"
    echo "Agent   : $RESP"
    if bash "$VALIDATOR" "$RESP" >/dev/null 2>&1; then REGEX_RES=PASS; else REGEX_RES=FAIL; fi
    if python3 "$SCORER" "$RESP" >/dev/null 2>&1; then STAT_RES=PASS; else STAT_RES=FAIL; fi
    echo "  Regex: $REGEX_RES | Stat: $STAT_RES"
    if [ "$REGEX_RES" = PASS ] && [ "$STAT_RES" = PASS ]; then
        PASS=$((PASS+1))
    fi
    echo ""
done < <(python3 - "$DATA" <<'PY'
import json,sys
for row in json.load(open(sys.argv[1])):
    print(f"{row.get('input','')}\t{row.get('response','')}")
PY
)

echo "Scenarios passed: $PASS/$TOTAL"
[ "$TOTAL" -gt 0 ] && [ "$PASS" -eq "$TOTAL" ]
