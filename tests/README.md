# Tests

> **Token Estimate:** ~182 tokens

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
