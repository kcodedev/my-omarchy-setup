#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAPPINGS_FILE="$SCRIPT_DIR/hx-theme-mappings.txt"
OMARCHY_THEMES_DIR="$HOME/.config/omarchy/themes"
CURRENT_THEME_DIR="$HOME/.config/omarchy/current/theme"
HELIX_CONFIG_DIR="$HOME/.config/helix"
HELIX_CONFIG_FILE="$HELIX_CONFIG_DIR/config.toml"
HELIX_THEMES_DIR="$HELIX_CONFIG_DIR/themes"
HELIX_OMARCHY_THEME="$HELIX_THEMES_DIR/omarchy.toml"
OLD_HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"
OLD_ORIGINAL_HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set.original"
OLD_MANAGED_MARKER="# managed by my-omarchy-setup"
OLD_UPDATER_PATH="$SCRIPT_DIR/update-helix-theme.sh"
UPDATER_PATH="$SCRIPT_DIR/update-helix-theme.sh"

if [ ! -f "$MAPPINGS_FILE" ]; then
    echo "Missing Helix theme mappings: $MAPPINGS_FILE"
    exit 1
fi

mkdir -p "$OMARCHY_THEMES_DIR" "$HELIX_THEMES_DIR"

restore_stale_theme_hook() {
    if [ ! -f "$OLD_HOOK_FILE" ]; then
        return
    fi

    if ! grep -Fqx "$OLD_MANAGED_MARKER" "$OLD_HOOK_FILE"; then
        return
    fi

    if ! grep -Fq "$OLD_UPDATER_PATH" "$OLD_HOOK_FILE"; then
        return
    fi

    if [ -f "$OLD_ORIGINAL_HOOK_FILE" ]; then
        mv "$OLD_ORIGINAL_HOOK_FILE" "$OLD_HOOK_FILE"
        chmod +x "$OLD_HOOK_FILE"
        echo "Restored preserved Omarchy theme hook"
    else
        rm "$OLD_HOOK_FILE"
        echo "Removed stale Omarchy theme hook"
    fi
}

remove_stale_helix_hook_call() {
    local temp_file

    if [ ! -f "$OLD_HOOK_FILE" ]; then
        return
    fi

    if ! grep -Fq "$OLD_UPDATER_PATH" "$OLD_HOOK_FILE"; then
        return
    fi

    temp_file="$(mktemp)"
    grep -Fv "$OLD_UPDATER_PATH" "$OLD_HOOK_FILE" >"$temp_file" || true

    if grep -Eqv '^[[:space:]]*(#.*)?$|^[[:space:]]*set -euo pipefail[[:space:]]*$|^[[:space:]]*#!/bin/(ba)?sh[[:space:]]*$' "$temp_file"; then
        mv "$temp_file" "$OLD_HOOK_FILE"
        chmod +x "$OLD_HOOK_FILE"
    else
        rm -f "$OLD_HOOK_FILE" "$temp_file"
    fi

    echo "Removed stale Helix theme hook call"
}

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
    while IFS='=' read -r omarchy_theme helix_theme; do
        [[ $omarchy_theme =~ ^[[:space:]]*# ]] && continue
        [[ -z $omarchy_theme ]] && continue

        theme_dir="$OMARCHY_THEMES_DIR/$omarchy_theme"
        mkdir -p "$theme_dir"
        printf 'inherits = "%s"\n' "$helix_theme" >"$theme_dir/helix.toml"
    done <"$MAPPINGS_FILE"
}

restore_stale_theme_hook
remove_stale_helix_hook_call

chmod +x "$UPDATER_PATH"
"$UPDATER_PATH"

if command -v omarchy-theme-refresh >/dev/null 2>&1 &&
   [ -f "$HOME/.config/omarchy/current/theme.name" ]; then
    omarchy-theme-refresh
fi

echo "Installed Omarchy Helix theme mappings"
