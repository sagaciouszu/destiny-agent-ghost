<p align="center">
  <img src='https://img.shields.io/github/v/release/sagaciouszu/destiny-agent-ghost?label=version&color=blue' alt='Version'/>
  <a href='https://github.com/sagaciouszu/destiny-agent-ghost/actions/workflows/ci.yml'><img src='https://github.com/sagaciouszu/destiny-agent-ghost/actions/workflows/ci.yml/badge.svg' alt='CI'/></a>
  <img src='https://img.shields.io/github/last-commit/sagaciouszu/destiny-agent-ghost?label=last%20push&color=blue' alt='Last push'/>
  <img src='https://img.shields.io/badge/license-MIT-green' alt='License'/>
  <img src='https://img.shields.io/badge/tests-18%2F18%20passing-brightgreen' alt='Tests'/>
</p>

# Ghost - Agent

> **Version:** 0.1.4 | **Last updated:** 2026-11-07 | **Status:** Ready

> **Depends On:** AGENTS.md
> **Token Estimate:** ~378 tokens

Ghost is an independent Destiny character agent built on the shared
Destiny Agent Grimoire: one canonical SQLite archive, one verified quote
policy, many distinct personas.

## Quick start

```bash
./setup.sh                      # link or clone the grimoire and get the database
bash tests/master-audit.sh      # local suites + shared gates
```

## Deploy

- **OpenCode:** `lore/scripts/sync-live-agents.sh` installs `ghost.md`, keeps
  companions inert under `ghost/`, and generates a read-only `ghost-consult`
  subagent.
- **OpenClaw:** `lore/scripts/sync-live-agents.sh --openclaw` writes
  `~/.openclaw/workspace-ghost` and the series block.
- **Generic runtime:** point it at `AGENTS.md` and `INDEX.md`.

## Verification

| Suite | Command | Expected |
|---|---|---|
| Full agent audit | `bash tests/master-audit.sh` | all suites pass |
| Module completeness | `bash tests/module-test.sh` | 0 failed |
| Quote verification | `bash tests/quote-verify.sh` | 0 unverified |
| Database integrity | `bash lore/tests/test-db.sh` | 51 checks |
| File conformance | `python3 lore/tests/conformance.py` | PASS |

## Troubleshooting

- **`lore/` missing:** run `./setup.sh`.
- **Dangling `lore/` symlink:** `setup.sh` recreates it.
- **No canon:** verify `lore/db/grimoire.db` exists.
- **Quote fails verification:** do not use it; find the canonical line first.

## License

MIT. Destiny and all related property belong to Bungie.
