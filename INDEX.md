# Ghost - Index

> **Depends On:** AGENTS.md
> **Token Estimate:** ~713 tokens

## Load tiers

| Tier | Files | Budget |
|------|-------|--------|
| Minimal | `ghost.md` + `ghost-core.md` | ~0.6K |
| Standard | + `voice/ghost-voice-core.md` + `core/relationships.md` | ~1.1K |
| Deep | all modules | ~16.3K |

## Identity

| File | Purpose |
|------|---------|
| `ghost.md` | platform entry and system prompt |
| `ghost-core.md` | consolidated identity, voice and canon reference |
| `ghost-voice.md` | voice calibration and representative lines |
| `SOUL.md` | one-page essence |
| `IDENTITY.md` | display identity |
| `TOOLS.md` | local and MCP interfaces |
| `AGENTS.md` | operating program |
| `README.md` | project overview |
| `RELEASE.md` | release notes |
| `INDEX.md` | this index |

## Core modules

| File | Purpose |
|------|---------|
| `core/guardrails.md` | authenticity and safety rules |
| `core/relationships.md` | how the character treats each major figure |
| `core/multi-user.md` | per-user isolation and privacy rules |
| `core/arcs.md` | narrative timeline |
| `core/voice-calibration.md` | concrete speech patterns |
| `core/decision-framework.md` | how the character chooses |
| `core/mood-triggers.md` | what shifts the mood |
| `core/tell-detector.md` | tells that reveal intent |
| `core/fear-hierarchy.md` | what the character fears |
| `core/threats-locations.md` | places and enemies that matter |
| `core/seasonal-awareness.md` | current season and events |
| `core/debt-ledger.md` | favors, debts and obligations |

## Voice

| File | Purpose |
|------|---------|
| `voice/ghost-voice-core.md` | core voice DNA |

## World

| File | Purpose |
|------|---------|
| `world/factions.md` | faction stances |
| `world/locations.md` | meaningful places |
| `world/relationships-map.md` | relationship graph |

## Reference

| File | Purpose |
|------|---------|
| `reference/knowledge-web.md` | source map and canon index |
| `reference/quote-index.md` | curated quote pointers |
| `reference/canon-brief.md` | canon-derived speaker brief |
| `reference/derived-voice.md` | measured speech patterns |
| `reference/derived-relationships.md` | co-occurring figures |
| `reference/derived-themes.md` | recurring canon themes |
| `reference/cross-reference.md` | transcripts mapped to persona beats |
| `reference/speech-pattern-analysis.md` | what the measured patterns mean |
| `USER.template.md` | runtime user context, seeded by setup |
| `core/journal.template.md` | runtime journal, seeded by setup |
| `core/session-state.template.md` | runtime session state, seeded by setup |
| `core/user-memory.template.md` | per-user memory, seeded by setup |
| `core/cross-session-memory.template.md` | durable memory, seeded by setup |
| `tests/README.md` | test inventory |

## Verification

```bash
bash tests/master-audit.sh
```
