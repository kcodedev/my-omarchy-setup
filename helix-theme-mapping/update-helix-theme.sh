#!/bin/bash

# Rebuild Omarchy theme overlays and Helix's link to the active theme.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPINGS_FILE="$SCRIPT_DIR/hx-theme-mappings.txt"
OMARCHY_THEMES_DIR="$HOME/.config/omarchy/themes"
CURRENT_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
HELIX_CONFIG_DIR="$HOME/.config/helix"
HELIX_CONFIG_FILE="$HELIX_CONFIG_DIR/config.toml"
HELIX_THEMES_DIR="$HELIX_CONFIG_DIR/themes"
HELIX_OMARCHY_THEME="$HELIX_THEMES_DIR/omarchy.toml"

if [ ! -f "$MAPPINGS_FILE" ]; then
    echo "Missing Helix theme mappings: $MAPPINGS_FILE"
    exit 1
fi

mkdir -p "$OMARCHY_THEMES_DIR" "$HELIX_THEMES_DIR"

write_helix_config_theme() {
    mkdir -p "$HELIX_CONFIG_DIR"

    if [ ! -f "$HELIX_CONFIG_FILE" ]; then
        printf 'theme = "omarchy"\n' >"$HELIX_CONFIG_FILE"
        return
    fi

    if grep -Eq '^[[:space:]]*theme[[:space:]]*=' "$HELIX_CONFIG_FILE"; then
        sed -i -E 's/^[[:space:]]*theme[[:space:]]*=.*/theme = "omarchy"/' "$HELIX_CONFIG_FILE"
    else
        tmp_file="$(mktemp)"
        {
            printf 'theme = "omarchy"\n'
            cat "$HELIX_CONFIG_FILE"
        } >"$tmp_file"
        mv "$tmp_file" "$HELIX_CONFIG_FILE"
    fi
}

write_theme_overlays() {
    local omarchy_theme
    local helix_theme
    local theme_dir

    while IFS='=' read -r omarchy_theme helix_theme; do
        [[ $omarchy_theme =~ ^[[:space:]]*# ]] && continue
        [[ -z $omarchy_theme ]] && continue

        theme_dir="$OMARCHY_THEMES_DIR/$omarchy_theme"
        mkdir -p "$theme_dir"
        printf 'inherits = "%s"\n' "$helix_theme" >"$theme_dir/helix.toml"
    done <"$MAPPINGS_FILE"
}

ln -sf "$CURRENT_THEME_DIR/helix.toml" "$HELIX_OMARCHY_THEME"
write_helix_config_theme
write_theme_overlays
