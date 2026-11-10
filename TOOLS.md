# Ghost - Tools

> **Depends On:** AGENTS.md
> **Token Estimate:** ~538 tokens

## Query CLI

- Query CLI: one of `python3 lore/db/query.py search|entity|character|character-info|item|book|transcript|find-item|record|verify|verify-many|list|activity|event|lore|seal|seals|coverage|stats`; MCP tool names use underscores.
- Search: `python3 lore/db/query.py search "<term>" --limit 10`
- Character lines: `python3 lore/db/query.py character "Ghost" --limit 20`
- Quote check: `python3 lore/db/query.py verify "<line>" --speaker "Ghost" --exact`
- Stats: `python3 lore/db/query.py stats`

## Discovery by activity, season and event

- Activity: `search "<term>" --activity menagerie` or `activity last-wish`
- Season: `search "<term>" --season 17` / `--season haunted`
- Event: `search "<term>" --event "The Dawning"` or `event festival-of-the-lost`
- Expansion: `search "<term>" --expansion "The Final Shape"`
- Coverage and gaps: `coverage`; browsing: `list activities|seasons|events|lore`
- Manifest lore: `lore "<title or hash>"`
- Canon-only: `--canon-only` on `character` or `transcript` excludes optional/variant
  lines but not caption-tier rows; filter `source_tier='game_caption'` explicitly
  for persona-canon-only text. `--section` filters by location.
- Class variants: `character "Ghost" --class hunter`; store the user's class
  with `python3 memory.py prefs-set --user <id> --class hunter`. Source tiers: validated/published/proofed Ishtar >
  untagged Ishtar > Destinypedia > captions.
- Classification confidence is `explicit`, `derived`, `manual` or `unknown`.
  Treat `unknown` as unknown; never present a guessed season as fact.

## MCP (optional)

Twenty-two tools over stdio: `search`, `entity`, `character`, `character_info`, `item`, `verify`,
`verify_many`, `list_records`, `stats`, `book`, `transcript`, `find_item`, `record`,
`seals`, `seal`, `lore`, `activities`, `activity`, `seasons`, `events`,
`event`, `coverage`. `search` also takes `activity`,
`season`, `event`, `expansion` and `timeline`. Register
`lore/mcp-server/run.sh`.

## Verification

- Full audit: `bash tests/master-audit.sh`
- Module checks: `bash tests/module-test.sh`
- Quotes: `bash tests/quote-verify.sh`
- Database integrity: `bash lore/tests/test-db.sh` (65 checks)
- Query interface: `bash lore/tests/query-interface-test.sh` (89 checks)
