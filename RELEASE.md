# 0.1.2 - Sync with destiny-agent-grimoire v0.29.0

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
