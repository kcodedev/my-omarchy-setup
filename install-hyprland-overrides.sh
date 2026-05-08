#!/bin/bash

set -euo pipefail

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONAL_CONFIG="$HOME/.config/hypr/personal.conf"
PERSONAL_SOURCE_LINE="source = ~/.config/hypr/personal.conf"

LEGACY_SOURCE_LINES=(
    "source = $SCRIPT_DIR/hyprland-overrides.conf"
    "source = $SCRIPT_DIR/looknfeel-overrides.conf"
    "source = $SCRIPT_DIR/input-overrides.conf"
)

ensure_source_line() {
    if [ ! -f "$PERSONAL_CONFIG" ]; then
        echo "Personal Hyprland config not found at $PERSONAL_CONFIG"
        echo "Skipping personal source line"
        return
    fi

    if grep -Fxq "$PERSONAL_SOURCE_LINE" "$HYPRLAND_CONFIG"; then
        echo "Source line already exists in $HYPRLAND_CONFIG: $PERSONAL_SOURCE_LINE"
        return
    fi

    echo "Adding source line to $HYPRLAND_CONFIG: $PERSONAL_SOURCE_LINE"
    printf '\n%s\n' "$PERSONAL_SOURCE_LINE" >> "$HYPRLAND_CONFIG"
}

remove_legacy_source_lines() {
    local legacy_source_line
    local temp_file

    temp_file="$(mktemp)"
    cp "$HYPRLAND_CONFIG" "$temp_file"

    for legacy_source_line in "${LEGACY_SOURCE_LINES[@]}"; do
        if grep -Fxq "$legacy_source_line" "$temp_file"; then
            echo "Removing legacy source line from $HYPRLAND_CONFIG: $legacy_source_line"
            grep -Fxv "$legacy_source_line" "$temp_file" >"${temp_file}.next"
            mv "${temp_file}.next" "$temp_file"
        fi
    done

    if ! cmp -s "$HYPRLAND_CONFIG" "$temp_file"; then
        cp "$temp_file" "$HYPRLAND_CONFIG"
    fi

    rm -f "$temp_file" "${temp_file}.next"
}

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Skipping Hyprland overrides"
    exit 0
fi

remove_legacy_source_lines
ensure_source_line

echo "Hyprland override source setup complete!"

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi
