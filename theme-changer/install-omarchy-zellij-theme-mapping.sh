#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATER_PATH="$SCRIPT_DIR/update-zellij-theme.sh"
OMARCHY_HOOK_DIR="$HOME/.config/omarchy/hooks"
OMARCHY_THEME_HOOK="$OMARCHY_HOOK_DIR/theme-set"
HOOK_START="# my-omarchy-setup zellij theme start"
HOOK_END="# my-omarchy-setup zellij theme end"

if [ ! -f "$UPDATER_PATH" ]; then
    echo "Missing Zellij theme updater: $UPDATER_PATH"
    exit 1
fi

mkdir -p "$OMARCHY_HOOK_DIR"

if [ ! -f "$OMARCHY_THEME_HOOK" ]; then
    printf '#!/bin/bash\n\n' >"$OMARCHY_THEME_HOOK"
fi

if ! grep -Fqx "$HOOK_START" "$OMARCHY_THEME_HOOK"; then
    {
        printf '\n%s\n' "$HOOK_START"
        printf '"%s"\n' "$UPDATER_PATH"
        printf '%s\n' "$HOOK_END"
    } >>"$OMARCHY_THEME_HOOK"
fi

chmod +x "$OMARCHY_THEME_HOOK" "$UPDATER_PATH"
"$UPDATER_PATH"

echo "Installed Omarchy Zellij theme mappings"
