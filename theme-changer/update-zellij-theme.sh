#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPINGS_FILE="$SCRIPT_DIR/zellij-theme-mappings.txt"
ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
ZELLIJ_CONFIG_FILE="$ZELLIJ_CONFIG_DIR/config.kdl"
ZELLIJ_THEMES_DIR="$ZELLIJ_CONFIG_DIR/themes"
ZELLIJ_THEME_FILE="$ZELLIJ_THEMES_DIR/catppuccin.kdl"
SOURCE_THEME_FILE="$SCRIPT_DIR/zellij-catppuccin.kdl"
CURRENT_THEME_NAME_FILE="$HOME/.config/omarchy/current/theme.name"
DEFAULT_ZELLIJ_THEME="ansi"

if [ ! -f "$MAPPINGS_FILE" ]; then
    echo "Missing Zellij theme mappings: $MAPPINGS_FILE"
    exit 1
fi

if [ ! -f "$SOURCE_THEME_FILE" ]; then
    echo "Missing Zellij theme file: $SOURCE_THEME_FILE"
    exit 1
fi

mkdir -p "$ZELLIJ_CONFIG_DIR" "$ZELLIJ_THEMES_DIR"
cp "$SOURCE_THEME_FILE" "$ZELLIJ_THEME_FILE"

omarchy_theme=""
if [ -f "$CURRENT_THEME_NAME_FILE" ]; then
    omarchy_theme="$(tr -d '[:space:]' <"$CURRENT_THEME_NAME_FILE")"
fi

zellij_theme="$DEFAULT_ZELLIJ_THEME"
while IFS='=' read -r mapped_omarchy_theme mapped_zellij_theme; do
    [[ $mapped_omarchy_theme =~ ^[[:space:]]*# ]] && continue
    [[ -z $mapped_omarchy_theme ]] && continue

    if [ "$mapped_omarchy_theme" = "$omarchy_theme" ]; then
        zellij_theme="$mapped_zellij_theme"
        break
    fi
done <"$MAPPINGS_FILE"

if [ ! -f "$ZELLIJ_CONFIG_FILE" ]; then
    printf 'theme "%s"\n' "$zellij_theme" >"$ZELLIJ_CONFIG_FILE"
elif grep -Eq '^[[:space:]]*theme[[:space:]]+"' "$ZELLIJ_CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*theme[[:space:]]+\"[^\"]*\"/theme \"$zellij_theme\"/" "$ZELLIJ_CONFIG_FILE"
else
    tmp_file="$(mktemp)"
    {
        printf 'theme "%s"\n' "$zellij_theme"
        cat "$ZELLIJ_CONFIG_FILE"
    } >"$tmp_file"
    mv "$tmp_file" "$ZELLIJ_CONFIG_FILE"
fi

echo "Set Zellij theme to $zellij_theme"
