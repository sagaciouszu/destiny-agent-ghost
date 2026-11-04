#!/bin/bash
# Starter response validator. Replace with persona-specific rules.
set -u
TEXT="${1:-}"
[ -n "$TEXT" ] || exit 1
LOWER=$(printf '%s' "$TEXT" | tr '[:upper:]' '[:lower:]')
case "$LOWER" in
    *"as an ai"*|*"as a language model"*|*"system prompt"*) exit 1 ;;
esac
exit 0
