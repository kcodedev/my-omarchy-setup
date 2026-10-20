#!/bin/bash

set -euo pipefail

PURGE_DATA=0

for arg in "$@"; do
    case "$arg" in
        --purge-data) PURGE_DATA=1 ;;
        help|-h|--help)
            echo "Usage: ./cleanup/remove-helix.sh [--purge-data]"
            echo "Removes Helix and its Omarchy theme integration; optionally deletes editor config."
            exit 0
            ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

if pacman -Qi helix >/dev/null 2>&1; then
    echo "Removing Helix package"
    sudo pacman -R --noconfirm helix
else
    echo "Helix package is not installed"
fi

# Older versions installed a theme-set wrapper or appended an updater call.
hook="$HOME/.config/omarchy/hooks/theme-set"
updater="helix-theme-mapping/update-helix-theme.sh"
if [ -f "$hook" ] && grep -Fq "$updater" "$hook"; then
    cp -p "$hook" "$hook.before-helix-removal"
    if grep -Fxq '# managed by my-omarchy-setup' "$hook"; then
        if [ -f "$hook.original" ]; then
            mv "$hook.original" "$hook"
        else
            rm -f "$hook"
        fi
    fi
    if [ -f "$hook" ] && grep -Fq "$updater" "$hook"; then
        sed -i '\|helix-theme-mapping/update-helix-theme.sh|d' "$hook"
    fi
fi

shopt -s nullglob
for theme in "$HOME"/.config/omarchy/themes/*/helix.toml; do
    echo "Removing $theme"
    rm -f "$theme"
done

link="$HOME/.config/helix/themes/omarchy.toml"
if [ -L "$link" ]; then
    rm -f "$link"
fi

if [ -f "$HOME/.bashrc" ] && grep -Fxq 'alias hx="helix"' "$HOME/.bashrc"; then
    cp -p "$HOME/.bashrc" "$HOME/.bashrc.before-helix-removal"
    sed -i '/^alias hx="helix"$/d' "$HOME/.bashrc"
fi

if [ "$PURGE_DATA" -eq 1 ]; then
    rm -rf "$HOME/.config/helix" "$HOME/.cache/helix"
else
    echo "Preserving Helix config; use --purge-data to remove it."
fi
