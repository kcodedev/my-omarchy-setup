#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
PLUGINS_FILE="$SCRIPT_DIR/omarchy-plugins.txt"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

normalize_git_url() {
    printf '%s\n' "${1%.git}"
}

install_or_update_plugin() {
    local plugin_id="$1"
    local plugin_url="$2"
    local plugin_dir="$PLUGINS_DIR/$plugin_id"
    local current_url

    if [ ! -e "$plugin_dir" ]; then
        echo "Installing Omarchy plugin: $plugin_id"
        omarchy plugin add "$plugin_url" --yes
        return
    fi

    if [ ! -d "$plugin_dir/.git" ]; then
        echo "Plugin path exists but is not a git checkout: $plugin_dir"
        exit 1
    fi

    current_url="$(git -C "$plugin_dir" remote get-url origin 2>/dev/null || true)"
    if [ "$(normalize_git_url "$current_url")" != "$(normalize_git_url "$plugin_url")" ]; then
        echo "Plugin origin does not match the configured source: $plugin_id"
        echo "Expected: $plugin_url"
        echo "Found:    ${current_url:-none}"
        exit 1
    fi

    echo "Updating Omarchy plugin: $plugin_id"
    omarchy plugin update "$plugin_id" --yes
}

require_command git
require_command omarchy

while read -r plugin_id plugin_url; do
    if [ -z "$plugin_id" ] || [[ "$plugin_id" == \#* ]]; then
        continue
    fi

    if [ -z "$plugin_url" ]; then
        echo "Missing plugin URL for: $plugin_id"
        exit 1
    fi

    install_or_update_plugin "$plugin_id" "$plugin_url"
done <"$PLUGINS_FILE"
