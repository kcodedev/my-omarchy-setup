#!/bin/bash

set -euo pipefail

ZMK_REPO_URL="${URCHIN_ZMK_REPO_URL:-git@github.com:kcodedev/zmk-urchin-kcodedev.git}"
ZMK_REPO_DIR="${URCHIN_ZMK_REPO_DIR:-$HOME/Repos/zmk-urchin-kcodedev}"
PLUGIN_REPO_URL="${URCHIN_OMARCHY_PLUGIN_URL:-https://github.com/kcodedev/urchin-omarchy-plugin.git}"
PLUGIN_ID="kcodedev.urchin"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

repo_has_changes() {
    local repo_dir="$1"

    [ -n "$(git -C "$repo_dir" status --porcelain 2>/dev/null)" ]
}

sync_zmk_repo() {
    if [ -d "$ZMK_REPO_DIR/.git" ]; then
        if repo_has_changes "$ZMK_REPO_DIR"; then
            echo "Urchin ZMK repository has local changes. Skipping pull: $ZMK_REPO_DIR"
        else
            echo "Updating Urchin ZMK repository"
            git -C "$ZMK_REPO_DIR" pull --ff-only
        fi
    elif [ -e "$ZMK_REPO_DIR" ]; then
        echo "Urchin ZMK path exists but is not a git repository: $ZMK_REPO_DIR"
        exit 1
    else
        echo "Cloning Urchin ZMK repository into $ZMK_REPO_DIR"
        mkdir -p "$(dirname "$ZMK_REPO_DIR")"
        git clone "$ZMK_REPO_URL" "$ZMK_REPO_DIR"
    fi
}

sync_omarchy_plugin() {
    local installed_id

    if [ -d "$PLUGIN_DIR/.git" ]; then
        installed_id="$(jq -r '.id // empty' "$PLUGIN_DIR/manifest.json" 2>/dev/null || true)"
        if [ "$installed_id" != "$PLUGIN_ID" ]; then
            echo "Unexpected plugin manifest in $PLUGIN_DIR: ${installed_id:-missing id}"
            exit 1
        fi

        if repo_has_changes "$PLUGIN_DIR"; then
            echo "Urchin Omarchy plugin has local changes. Skipping update: $PLUGIN_DIR"
        else
            echo "Updating Urchin Omarchy plugin"
            omarchy plugin update "$PLUGIN_ID" --yes
        fi
    elif [ -e "$PLUGIN_DIR" ]; then
        echo "Urchin plugin path exists but is not a git repository: $PLUGIN_DIR"
        exit 1
    else
        echo "Installing Urchin Omarchy plugin"
        omarchy plugin add "$PLUGIN_REPO_URL" --enable --yes
    fi

    # Chezmoi owns the exact bar placement. Enabling without placement preserves it.
    omarchy plugin enable "$PLUGIN_ID"
}

require_command git
require_command jq
require_command omarchy

sync_zmk_repo
sync_omarchy_plugin

echo "Urchin ZMK repository and Omarchy plugin are ready."
