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

SUITES=(
    "Module Completeness|bash $HERE/module-test.sh | grep -q 'Failed: 0'"
    "Quote Verification|bash $HERE/quote-verify.sh | grep -q 'unverified quotes: 0'"
    "Multi-User Isolation|grep -q 'Never quote or summarize one user' $WORKSPACE/core/multi-user.md && grep -q 'memory.py' $WORKSPACE/core/multi-user.md"
    "Memory Isolation|python3 $HERE/memory-test.py | grep -q 'memory isolation'"
    "Connection|bash $HERE/connection-test.sh | grep -q 'Failed: 0'"
    "Conversation|bash $HERE/conversation-test.sh"
    "Multi-Turn|bash $HERE/multiturn-test.sh"
    "Scenarios|bash $HERE/scenario-simulator.sh"
    "Voice Consistency|bash $HERE/voice-consistency.sh"
    "Golden Voice Snapshots|bash $HERE/golden-voice-test.sh | grep -q 'Failed: 0'"
    "Depends On Coverage|python3 $LORE/tests/check-agent-structure.py deps $WORKSPACE"
    "Token Estimate Coverage|python3 $LORE/tests/check-agent-structure.py tokens $WORKSPACE"
    "No Em-Dashes|python3 $LORE/tests/check-agent-structure.py dashes $WORKSPACE"
    "INDEX Completeness|python3 $LORE/tests/check-agent-structure.py index $WORKSPACE"
    "No Personal Paths|python3 $LORE/tests/check-agent-structure.py paths $WORKSPACE"
)

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
