# v0.1.9 - Truth and onboarding pass

> **Depends On:** INDEX.md
> **Token Estimate:** ~152 tokens
**2026-11-10**

## What's Changed

- AGENTS states the full verify command and exit-code contract, plus the caption caveat for `--canon-only`.
- The cross-reference advice now uses `verify` rather than `--canon-only` as confirmation.
- Adopts the shared setup.sh: `--mcp`/`--no-mcp`, BOOTSTRAP, curl fallback, guarded checksum and private memory permissions.

## Verification

- `bash tests/master-audit.sh`: 20/20.
- `python3 tests/persona-freshness.py`: rc 0.
- `python3 lore/tests/conformance.py`: PASS.
