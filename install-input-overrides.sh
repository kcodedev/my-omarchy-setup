#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_OVERRIDES="$SCRIPT_DIR/input-overrides.conf"
SOURCE_LINE="source = $INPUT_OVERRIDES"

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

if [ ! -f "$HYPRLAND_CONF" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONF"
    exit 1
fi

if [ ! -f "$INPUT_OVERRIDES" ]; then
    echo "Input overrides config not found at $INPUT_OVERRIDES"
    exit 1
fi

if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONF"; then
    echo "Source line already exists in $HYPRLAND_CONF"
else
    echo "" >> "$HYPRLAND_CONF"
    echo "$SOURCE_LINE" >> "$HYPRLAND_CONF"
    echo "Source line added successfully"
fi

echo "Input overrides setup complete!"

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi
