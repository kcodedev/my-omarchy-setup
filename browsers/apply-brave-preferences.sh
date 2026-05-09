#!/bin/bash

set -euo pipefail

BRAVE_CONFIG_DIR="$HOME/.config/BraveSoftware/Brave-Browser"
DESIRED_VERTICAL_TABS_ENABLED=true
DESIRED_VERTICAL_TABS_COLLAPSED=true
DESIRED_VERTICAL_TABS_HIDE_WHEN_COLLAPSED=false

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

brave_is_running() {
    pgrep -x brave >/dev/null 2>&1 || pgrep -x brave-browser >/dev/null 2>&1
}

update_preferences_file() {
    local preferences_file="$1"
    local temp_file

    mkdir -p "$(dirname "$preferences_file")"

    if [ ! -f "$preferences_file" ]; then
        printf '{}\n' > "$preferences_file"
    fi

    temp_file="$(mktemp)"

    jq \
        --argjson vertical_tabs_enabled "$DESIRED_VERTICAL_TABS_ENABLED" \
        --argjson vertical_tabs_collapsed "$DESIRED_VERTICAL_TABS_COLLAPSED" \
        --argjson vertical_tabs_hide_when_collapsed "$DESIRED_VERTICAL_TABS_HIDE_WHEN_COLLAPSED" \
        '
        (.brave //= {}) |
        (.brave.tabs //= {}) |
        .brave.tabs.vertical_tabs_enabled = $vertical_tabs_enabled |
        .brave.tabs.vertical_tabs_collapsed = $vertical_tabs_collapsed |
        .brave.tabs.vertical_tabs_hide_completely_when_collapsed = $vertical_tabs_hide_when_collapsed
        ' \
        "$preferences_file" > "$temp_file"

    mv "$temp_file" "$preferences_file"
}

main() {
    local profile_dir
    local preferences_file
    local updated_count=0
    local -a profile_dirs=()

    require_command jq

    if brave_is_running; then
        echo "Brave appears to be running. Close Brave, then rerun this step to update profile preferences safely."
        exit 0
    fi

    mkdir -p "$BRAVE_CONFIG_DIR"

    shopt -s nullglob
    for profile_dir in "$BRAVE_CONFIG_DIR"/Default "$BRAVE_CONFIG_DIR"/Profile\ *; do
        if [ -d "$profile_dir" ]; then
            profile_dirs+=("$profile_dir")
        fi
    done
    shopt -u nullglob

    if [ "${#profile_dirs[@]}" -eq 0 ]; then
        profile_dirs+=("$BRAVE_CONFIG_DIR/Default")
    fi

    for profile_dir in "${profile_dirs[@]}"; do
        preferences_file="$profile_dir/Preferences"
        update_preferences_file "$preferences_file"
        updated_count=$((updated_count + 1))
        echo "Applied Brave preferences to $preferences_file"
    done

    echo "Brave vertical tabs configured for $updated_count profile(s)"
}

main "$@"
