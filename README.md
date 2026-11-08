# Ghost - Agent

<p align="center">
  <img src='https://img.shields.io/github/v/release/sagaciouszu/destiny-agent-ghost?label=version&color=blue' alt='Version'/>
  <a href='https://github.com/sagaciouszu/destiny-agent-ghost/actions/workflows/ci.yml'><img src='https://github.com/sagaciouszu/destiny-agent-ghost/actions/workflows/ci.yml/badge.svg' alt='CI'/></a>
  <img src='https://img.shields.io/github/last-commit/sagaciouszu/destiny-agent-ghost?label=last%20push&color=blue' alt='Last push'/>
  <img src='https://img.shields.io/badge/license-MIT-green' alt='License'/>
  <img src='https://img.shields.io/badge/tests-20%2F20%20passing-brightgreen' alt='Tests'/>
</p>

**Version:** 0.1.4 | **Last updated:** 2026-11-08 | **Status:** Ready

Ghost is an independent Destiny character agent built on the shared Destiny Agent Grimoire: one canonical SQLite archive, one verified quote policy, one distinct persona.

Every quote traces to the Destiny Agent Grimoire's canonical SQLite archive;
every suite is verifiable against it.

## Quick start

```bash
git clone https://github.com/sagaciouszu/destiny-agent-ghost.git
cd destiny-agent-ghost
./setup.sh                  # link or clone the grimoire and pull the database
bash tests/master-audit.sh  # 20 suites
```

## Deploy

- **OpenCode:** `lore/scripts/sync-live-agents.sh` installs `ghost.md`, keeps companions under `ghost/`, and generates a read-only `ghost-consult` subagent.
- **OpenClaw:** `lore/scripts/sync-live-agents.sh --openclaw` writes `~/.openclaw/workspace-ghost` and the series block.
- **Generic runtime:** point it at `AGENTS.md` and `INDEX.md`.

## Verification

- Full agent audit: `bash tests/master-audit.sh` — 20 suites.
- Module completeness: `bash tests/module-test.sh` — 0 failed.
- Quote verification: `bash tests/quote-verify.sh` — 0 unverified.
- Grimoire integrity: `bash lore/tests/test-db.sh` — all checks pass.

## Troubleshooting

- **`lore/` missing:** run `./setup.sh`.
- **Dangling `lore/` symlink:** `setup.sh` recreates it.
- **No canon:** verify `lore/db/grimoire.db` exists and the checksum is clean.
- **Quote fails verification:** do not use it; find the canonical line first.

## License

MIT. Destiny and all related property belong to Bungie.
