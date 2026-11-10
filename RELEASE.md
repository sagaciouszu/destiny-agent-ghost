# v0.1.7 - Sync with destiny-agent-grimoire v0.40.0

> **Depends On:** INDEX.md
> **Token Estimate:** ~207 tokens
**2026-11-10**

The mounted archive moved to grimoire v0.40.0 (schema 1.10.0). Persona counts
are unchanged; the persona was sourced against schema 1.9.0 and does not need
re-sourcing for this release.

## What's Changed

- `v_canon_speakers` (230 persona-canon speakers) is available through
  `python3 lore/db/query.py list canon-speakers`; `v_speakers` remains the
  423-row discovery view.
- `character` and `transcript` accept `--tier` and `--exclude-tier` (MCP
  `tier` / `exclude_tier`).
- `TOOLS.md` documents the tier filters and the canon-speaker listing.

## Verification

- `bash tests/master-audit.sh`: 20/20.
- `python3 tests/persona-freshness.py`: rc 0.
- `python3 lore/tests/conformance.py`: PASS.
