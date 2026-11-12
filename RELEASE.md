# v0.1.10 - Fixture policy migration and hygiene

**2026-11-12**

Test fixtures replaced with synthetic persona-voice text (verbatim canon
removed). Test-name consolidation: persona-prefixed scripts renamed to generic
template slots. Stale audit-count claims corrected (20/20 remains current).

## What's Changed
- All test fixtures (golden-voice, sample-conversation, multiturn, scenarios)
  now use synthetic text scoring >= 55 on the persona voice scorer.
- No fixture text matches canon (verify --exact: NOT FOUND).
- golden-voice.json expect fields, voice-scorer.py, validate-response.sh
  untouched. Persona files untouched.
- Accidental drift reconciled: .gitignore, LICENSE, ci.yml canonicalized.
- README test-count badge corrected where stale.

## Verification
- `bash tests/master-audit.sh`: 20/20.
- `bash tests/shared-helpers-test.sh`: 5/5.
- `python3 grimoire/tests/conformance.py`: PASS.
- `python3 grimoire/tests/sync-doc-counts.py --check`: PASS.

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
