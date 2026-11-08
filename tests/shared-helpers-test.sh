#!/bin/bash
# shared-helpers-test.sh: byte-compare the shared test helpers with their canonical copies in the grimoire repo (lore/tests/); input: none (paths derive from this script's location); output: one PASS/FAIL line per helper (PASS with a note when the canonical copy is absent); exit codes: 0 when every helper matches or is skipped, 1 if any helper differs.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
CANON="$HERE/../lore/tests"
PASS=0; FAIL=0

check() {
    local f="$1"
    if [ ! -f "$HERE/$f" ]; then
        echo "  FAIL $f (missing from $(basename "$(dirname "$HERE")")/tests)"
        FAIL=$((FAIL+1))
        return
    fi
    if [ ! -f "$CANON/$f" ]; then
        echo "  PASS $f (skipped: no canonical copy at lore/tests/$f)"
        PASS=$((PASS+1))
        return
    fi
    if cmp -s "$HERE/$f" "$CANON/$f"; then
        echo "  PASS $f"
        PASS=$((PASS+1))
    else
        echo "  FAIL $f (differs from lore/tests/$f)"
        FAIL=$((FAIL+1))
    fi
}

echo "=== SHARED HELPERS TEST ==="
for helper in persona-freshness.py memory-test.py run-suites.sh; do
    check "$helper"
done

echo ""
echo "Passed: $PASS | Failed: $FAIL"
[ "$FAIL" -eq 0 ]
