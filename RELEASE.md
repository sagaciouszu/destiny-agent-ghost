# v0.1.5 - Docs and count sync with destiny-agent-grimoire v0.39.0

> **Depends On:** INDEX.md
> **Token Estimate:** ~0.6K tokens
**2026-11-10**

Documentation and counts are synced against destiny-agent-grimoire v0.39.0
(schema 1.9.0; 9,229 transcripts / 125,324 lines, of which 7,911 transcripts
and 55,678 lines are caption-tier). No persona canon change: `canon_lines` and
`canon_variant_lines` are unchanged and still match the DB persona predicate
(exact speaker, `is_stage_dir=0`, `is_optional=0`, `source_tier != 'game_caption'`).

## What's Changed

- `TOOLS.md` MCP tool list now matches the 22-tool manifest, including `entity`.
- Core and canon-brief transcript counts and source-tier tables now use live
  DB values and the persona predicate.
- Added the caption-tier and `v_speakers` note to `README.md`.

## Verification

- `bash tests/master-audit.sh`: 20/20 suites passed.
- `python3 tests/persona-freshness.py`: rc 0.
- `python3 lore/tests/count-consistency.py`: 21 passed, 0 failed.
- `python3 lore/tests/conformance.py`: PASS.

# v0.1.4 - Sync with destiny-agent-grimoire v0.29.0

> **Depends On:** INDEX.md
> **Token Estimate:** ~0.3K tokens
**2026-11-07**

The shared lore database behind this agent is now destiny-agent-grimoire
v0.29.0 (schema 1.5.0):

- `transcript_lines` now records attribution provenance for game captions
  (`speaker_source`: `ishtar_containment` / `dialogue_node` / `line_prefix`);
  counts unchanged (2,422 transcripts / 78,740 lines).
- Game captions remain excluded from persona canon (the DB predicate
  `source_tier != 'game_caption'` holds); no persona canon changes.
- Verification: this repo's audits green against the released DB
  (`tests/persona-freshness.py` rc=0); main `grimoire-master-audit.sh`
  14/14; every gate referenced by this repo unchanged.

No content change. The full agent audits are run against the released
database at each push.

## What's Changed

- Sync with destiny-agent-grimoire v0.29.0 (schema 1.5.0; caption attribution
  provenance stored on caption lines)
- Persona canon unchanged (captions excluded by source-tier predicate)
- Counts match the released DB

## Verification

Full master-audit green; persona-freshness passes against the released DB;
all suite counts verified.
