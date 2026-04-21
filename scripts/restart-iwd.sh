#!/bin/bash

set -euo pipefail

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name" >&2
        exit 1
    fi
}

require_command pkexec
require_command systemctl

if ! systemctl list-unit-files iwd.service >/dev/null 2>&1; then
    echo "iwd.service is not installed on this system" >&2
    exit 1
fi

pkexec systemctl restart iwd.service

if command -v notify-send >/dev/null 2>&1; then
    notify-send "iwd restarted" "Wireless daemon has been restarted."
fi
