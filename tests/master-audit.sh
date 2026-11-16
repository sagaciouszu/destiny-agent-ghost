#!/bin/bash
# Master audit for the generated agent: local suites plus shared gates.
# Usage: bash tests/master-audit.sh
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$HERE")"
LORE="${LORE:-$REPO/lore}"
WORKSPACE="${WORKSPACE:-$REPO}"
export WORKSPACE
export LORE

[ -f "$LORE/db/grimoire.db" ] || {
    echo "FATAL: grimoire database missing at $LORE/db/grimoire.db"
    echo "       run: ./setup.sh"
    exit 1
}

PASS=0; FAIL=0; TOTAL=0
run() {
    TOTAL=$((TOTAL+1))
    if eval "$2" >/dev/null 2>&1; then
        echo "  ✓ [$1] PASS"; PASS=$((PASS+1))
    else
        echo "  ✗ [$1] FAIL"; FAIL=$((FAIL+1))
    fi
}

# tests/suites.json is the single suite registry. This audit loads it at
# runtime so there is exactly one list to maintain; do not add an inline
# SUITES block here. (Bash 3.2 compatible: no mapfile; count kept in a
# scalar because empty-array expansion trips set -u on old bash.)
SUITES=()
SUITE_COUNT=0
while IFS= read -r line; do
    if [ -n "$line" ]; then
        SUITES+=("$line")
        SUITE_COUNT=$((SUITE_COUNT + 1))
    fi
done < <(python3 - "$HERE/suites.json" <<'PY'
import json, sys
for s in json.load(open(sys.argv[1], encoding='utf-8'))['suites']:
    print(f"{s['name']}|{s['command']}")
PY
)
[ "$SUITE_COUNT" -gt 0 ] || { echo "FATAL: no suites loaded from tests/suites.json"; exit 1; }

echo "============================================================"
echo "  GHOST - MASTER AUDIT"
echo "============================================================"
echo ""
for entry in "${SUITES[@]}"; do
    run "${entry%%|*}" "${entry#*|}"
done
echo ""
echo "============================================================"
echo "  SCORECARD: $PASS / $TOTAL SUITES PASSED ($FAIL failed)"
echo "============================================================"
[ "$FAIL" -eq 0 ]
