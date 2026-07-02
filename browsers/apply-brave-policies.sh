#!/bin/bash

set -euo pipefail

BRAVE_POLICY_DIR="/etc/brave/policies/managed"
BRAVE_EXTENSION_POLICY_FILE="$BRAVE_POLICY_DIR/extensions.json"
CHROME_WEBSTORE_UPDATE_URL="https://clients2.google.com/service/update2/crx"

# Chrome Web Store extension IDs.
VIMIUM_EXTENSION_ID="dbepggeogbaibhgnhhndojpepiihcmeb"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

main() {
    local policy_entry="$VIMIUM_EXTENSION_ID;$CHROME_WEBSTORE_UPDATE_URL"
    local temp_file

    require_command jq

    temp_file="$(mktemp)"
    jq -n --arg policy_entry "$policy_entry" \
        '{ExtensionInstallForcelist: [$policy_entry]}' >"$temp_file"

    if [ -d "$BRAVE_POLICY_DIR" ] && [ -w "$BRAVE_POLICY_DIR" ]; then
        install -m 644 "$temp_file" "$BRAVE_EXTENSION_POLICY_FILE"
    elif [ "$(id -u)" -eq 0 ]; then
        install -d -m 755 "$BRAVE_POLICY_DIR"
        install -m 644 "$temp_file" "$BRAVE_EXTENSION_POLICY_FILE"
    else
        sudo install -d -m 755 "$BRAVE_POLICY_DIR"
        sudo install -m 644 "$temp_file" "$BRAVE_EXTENSION_POLICY_FILE"
    fi

    rm -f "$temp_file"

    echo "Applied Brave extension policy to $BRAVE_EXTENSION_POLICY_FILE"
    echo "Force-installed extensions: Vimium"
}

main "$@"
