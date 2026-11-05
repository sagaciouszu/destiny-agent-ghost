# Tests

> **Token Estimate:** ~350 tokens

Run the full gate first:

```bash
bash tests/master-audit.sh
```

| Test | Purpose |
|---|---|
| `master-audit.sh` | every local and shared gate |
| `connection-test.sh` | grimoire database, query interface, lore/seal, MCP |
| `module-test.sh` | required modules and no placeholders |
| `quote-verify.sh` | every quoted line is canon |
| `conversation-test.sh` | recorded sample conversation |
| `multiturn-test.sh` | generated `multiturn.json` arc |
| `scenario-simulator.sh` | generated `scenarios.json` cases |
| `voice-consistency.sh` | forbidden terms outside verified canon |
| `golden-voice-test.sh` | locked voice snapshots |
| `memory-test.py` | per-user memory isolation |

## Voice scoring methodology

`voice-scorer.py` scores a candidate line against this speaker's canonical
corpus (`speaker = Ghost` rows in `lore/db/grimoire.db`, stage directions
excluded). Components: vocabulary overlap /20, bigram+trigram phrasing /10,
signature markers /25, sentence cadence /15, character 3-gram overlap /15,
signature phrases /15, brevity /5 and consistency /5 bonuses, minus a
forbidden-term penalty /25 read from `persona.json`. Totals are clamped to
0-100; PASS at >= 55 exits 0, fail exits 1, a missing database exits 2.
`golden-voice.json` pins fixed responses to their expected pass/fail verdict
through `golden-voice-test.sh`.
