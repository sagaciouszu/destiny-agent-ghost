#!/bin/bash
# Seed this agent workspace: link or clone the grimoire and get the database.
# Usage: ./setup.sh [grimoire-repo-path] [--dry-run]
# GRIMOIRE_DB=/path/to/grimoire.db copies a local database instead of downloading.
set -e
REPO="$(cd "$(dirname "$0")" && pwd)"
LORE="$REPO/lore"
SOURCE=""
DRY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY=1 ;;
        -h|--help)
            echo "usage: ./setup.sh [grimoire-repo-path] [--dry-run]"
            echo "  GRIMOIRE_DB=/path/to/grimoire.db  use a local database"
            exit 0 ;;
        -*)
            echo "unknown option: $1" >&2
            exit 2 ;;
        *)
            if [ -n "$SOURCE" ]; then
                echo "only one grimoire path may be given" >&2
                exit 2
            fi
            SOURCE="$1" ;;
    esac
    shift
done

say() { echo "[dry-run] $*"; }

if [ -d "$LORE" ] && [ ! -L "$LORE" ]; then
    echo "using existing $LORE"
elif [ -n "$SOURCE" ] && [ -d "$SOURCE" ]; then
    SOURCE_ABS="$(cd "$SOURCE" && pwd)"
    if [ "$DRY" -eq 1 ]; then
        say "link $LORE -> $SOURCE_ABS"
        if [ -L "$LORE" ] && [ ! -e "$LORE" ]; then
            say "remove dangling symlink $LORE"
        fi
    else
        # A dangling lore/ link is runtime state from a moved checkout; treat
        # it as absent instead of mistaking it for a usable archive.
        if [ -L "$LORE" ] && [ ! -e "$LORE" ]; then
            rm -f "$LORE"
        fi
        ln -s "$SOURCE_ABS" "$LORE" 2>/dev/null || true
        if [ -L "$LORE" ]; then
            echo "linked $LORE -> $SOURCE_ABS"
        else
            # Windows (Git Bash): ln may copy or fail; use a junction, then clone.
            if [ -e "$LORE" ]; then
                chmod -R u+w "$LORE" 2>/dev/null || true
                rm -rf "$LORE"
            fi
            if (command -v cmd >/dev/null 2>&1 || command -v cmd.exe >/dev/null 2>&1) && \
               MSYS_NO_PATHCONV=1 cmd /c mklink /J "$(cygpath -w "$LORE" 2>/dev/null || echo "$LORE")" \
                                  "$(cygpath -w "$SOURCE_ABS" 2>/dev/null || echo "$SOURCE_ABS")" >/dev/null 2>&1; then
                echo "junctioned $LORE -> $SOURCE_ABS"
            else
                git clone "$SOURCE_ABS" "$LORE"
                echo "cloned $LORE from $SOURCE_ABS"
            fi
        fi
    fi
elif [ -d "$LORE" ] && [ -f "$LORE/db/grimoire.db" ]; then
    echo "using existing $LORE"
else
    if [ "$DRY" -eq 1 ]; then
        say "clone the grimoire into $LORE"
    else
        [ -d "$LORE" ] || git clone https://github.com/sagaciouszu/destiny-agent-grimoire.git "$LORE"
        echo "cloned $LORE"
    fi
fi

if [ -f "$LORE/db/grimoire.db" ]; then
    echo "using existing database"
elif [ -n "${SOURCE_ABS:-}" ] && [ -f "$SOURCE_ABS/db/grimoire.db" ]; then
    echo "using database from $SOURCE_ABS"
elif [ -n "${GRIMOIRE_DB:-}" ] && [ -f "$GRIMOIRE_DB" ]; then
    if [ "$DRY" -eq 1 ]; then
        say "copy $GRIMOIRE_DB -> $LORE/db/grimoire.db"
    else
        mkdir -p "$LORE/db"
        cp "$GRIMOIRE_DB" "$LORE/db/grimoire.db"
        echo "copied local database $GRIMOIRE_DB"
    fi
else
    if [ "$DRY" -eq 1 ]; then
        say "download and checksum-verify grimoire.db"
    else
        mkdir -p "$LORE/db"
        curl -fsSL https://github.com/sagaciouszu/destiny-agent-grimoire/releases/latest/download/grimoire.db \
            -o "$LORE/db/grimoire.db"
        SUMS="$(mktemp)"
        trap 'rm -f "$SUMS"' EXIT
        curl -fsSL https://github.com/sagaciouszu/destiny-agent-grimoire/releases/latest/download/SHA256SUMS \
            -o "$SUMS"
        if ! (cd "$LORE/db" && sha256sum -c "$SUMS"); then
            rm -f "$LORE/db/grimoire.db"
            echo "FATAL: database checksum failed" >&2
            exit 1
        fi
        echo "downloaded and verified grimoire.db"
    fi
fi

# Seed runtime files from templates once; never overwrite user state.
for rel in USER core/user-memory core/journal core/session-state core/cross-session-memory; do
    src="$REPO/$rel.template.md"
    dst="$REPO/$rel.md"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
        if [ "$DRY" -eq 1 ]; then
            say "seed $rel.md"
        else
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            echo "seeded $rel.md"
        fi
    fi
done

# OpenClaw: give the global config an absolute grimoire MCP path (idempotent).
if [ -f "$LORE/scripts/ensure-openclaw-mcp.sh" ]; then
    if [ "$DRY" -eq 1 ]; then
        say "point OpenClaw's MCP entry at $LORE"
    else
        bash "$LORE/scripts/ensure-openclaw-mcp.sh" "$LORE" \
            || echo "warning: OpenClaw MCP config was not updated"
    fi
fi

if [ "$DRY" -eq 1 ]; then
    echo
    echo "dry-run: nothing was changed"
    exit 0
fi

echo
echo "First session: ask Hunter, Titan or Warlock."
echo "Store it: python3 memory.py prefs-set --user <platform-id> --class <class>"
echo
echo "README: read README.md"
echo "Audit:  bash tests/master-audit.sh"
