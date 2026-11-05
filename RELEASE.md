# v0.1.1 - Windows readiness and conversation parity

> **Depends On:** INDEX.md
> **Token Estimate:** ~0.13K tokens

**2026-11-05**

## What's Changed

- Windows-safe lore link: `setup.sh` now tries a symlink, then a `mklink /J`
  junction, then a clone, clearing read-only bits first (Git Bash/MSYS safe).
- `Sample Conversation` suite added to the master audit: a three-turn fixture
  scored against the persona voice scorer.
- Suite manifest (`tests/suites.json`) plus shared runner `tests/run-suites.sh`;
  the grimoire's no-loss baseline keeps every suite from disappearing.
- Personal-path guard now detects any `/home/<user>` pattern; machine paths
  scrubbed from documentation.
- README version stamp refreshed.
- The existing sample-conversation test is now wired into the audit; it had never run before.

## Verification

16/16 master audit, agent parity 60/60, connections 36/36, grimoire conformance PASS.
