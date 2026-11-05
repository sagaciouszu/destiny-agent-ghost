#!/bin/bash
# Seed this agent workspace: link or clone the grimoire and get the database.
# Usage: ./setup.sh [grimoire-repo-path]
set -e
REPO="$(cd "$(dirname "$0")" && pwd)"
LORE="$REPO/lore"
SOURCE="${1:-}"

if [ -d "$LORE" ] && [ ! -L "$LORE" ]; then
    echo "using existing $LORE"
elif [ -n "$SOURCE" ] && [ -d "$SOURCE" ]; then
    SOURCE_ABS="$(cd "$SOURCE" && pwd)"
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
elif [ -d "$LORE" ] && [ -f "$LORE/db/grimoire.db" ]; then
    echo "using existing $LORE"
else
    [ -d "$LORE" ] || git clone https://github.com/sagaciouszu/destiny-agent-grimoire.git "$LORE"
    echo "cloned $LORE"
fi

if [ ! -f "$LORE/db/grimoire.db" ]; then
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

# Seed runtime files from templates once; never overwrite user state.
for rel in USER core/user-memory core/journal core/session-state core/cross-session-memory; do
    src="$REPO/$rel.template.md"
    dst="$REPO/$rel.md"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "seeded $rel.md"
    fi
done

# OpenClaw: give the global config an absolute grimoire MCP path (idempotent).
if [ -f "$LORE/scripts/ensure-openclaw-mcp.sh" ]; then
    bash "$LORE/scripts/ensure-openclaw-mcp.sh" "$LORE" \
        || echo "warning: OpenClaw MCP config was not updated"
fi

echo
echo "First session: ask Hunter, Titan or Warlock."
echo "Store it: python3 memory.py prefs-set --user <platform-id> --class <class>"
echo
echo "README: read README.md"
echo "Audit:  bash tests/master-audit.sh"
