# Ghost - Cross-Reference

> **Depends On:** INDEX.md
> **Token Estimate:** ~144 tokens

Map newly ingested transcripts to persona beats. Update this file when the
grimoire gains content that changes how Ghost should be played.

## New Transcripts to Persona Beats

| Transcript or activity | Beats |
|---|---|
| run `python3 lore/db/query.py activity <slug>` | record the scenes and lines worth using |

## Key Beats by Transcript

Use `python3 lore/db/query.py character "Ghost" --about <term>` to find
material, then `python3 lore/db/query.py verify "<line>" --speaker "Ghost" --exact`
to confirm every line before citing it. `--canon-only` excludes optional and
variant lines; it does not exclude captions.
