#!/bin/bash

set -euo pipefail

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OVERRIDE_CONFIGS=(
    "$SCRIPT_DIR/hyprland-overrides.conf"
    "$SCRIPT_DIR/looknfeel-overrides.conf"
    "$SCRIPT_DIR/input-overrides.conf"
)

ensure_source_line() {
    local override_config="$1"
    local source_line="source = $override_config"

    if [ ! -f "$override_config" ]; then
        echo "Overrides config not found at $override_config"
        exit 1
    fi

    if grep -Fxq "$source_line" "$HYPRLAND_CONFIG"; then
        echo "Source line already exists in $HYPRLAND_CONFIG: $source_line"
        return
    fi

    echo "Adding source line to $HYPRLAND_CONFIG: $source_line"
    printf '\n%s\n' "$source_line" >> "$HYPRLAND_CONFIG"
}

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONFIG"
    echo "Skipping Hyprland overrides"
    exit 0
fi

for override_config in "${OVERRIDE_CONFIGS[@]}"; do
    ensure_source_line "$override_config"
done

echo "Hyprland overrides setup complete!"

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi
