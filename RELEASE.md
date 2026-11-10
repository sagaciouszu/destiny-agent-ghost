# v0.1.8 - Honesty pass

> **Depends On:** INDEX.md
> **Token Estimate:** ~152 tokens
**2026-11-10**

## What's Changed

- README claims now match the evidence: quotes trace to transcripts or lore books
  in this library, not to an official Bungie publication; the checker proves
  presence in the corpus.
- The project now links to the site's Limits and provenance page, which records
  the caption tier, missing timelines, source gaps and non-completeness.

## Verification

- `bash tests/master-audit.sh`: 20/20.
- `python3 tests/persona-freshness.py`: rc 0.
- `python3 lore/tests/conformance.py`: PASS.

