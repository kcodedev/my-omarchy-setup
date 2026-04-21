#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOKNFEEL_OVERRIDES="$SCRIPT_DIR/looknfeel-overrides.conf"
SOURCE_LINE="source = $LOOKNFEEL_OVERRIDES"

HYPRLAND_CONF="$HOME/.config/hypr/hyprland.conf"

if [ ! -f "$HYPRLAND_CONF" ]; then
    echo "Hyprland config not found at $HYPRLAND_CONF"
    echo "Skipping look'n'feel overrides"
    exit 0
fi

if [ ! -f "$LOOKNFEEL_OVERRIDES" ]; then
    echo "Look'n'feel overrides config not found at $LOOKNFEEL_OVERRIDES"
    exit 1
fi

if grep -Fxq "$SOURCE_LINE" "$HYPRLAND_CONF"; then
    echo "Source line already exists in $HYPRLAND_CONF"
else
    echo "" >> "$HYPRLAND_CONF"
    echo "$SOURCE_LINE" >> "$HYPRLAND_CONF"
    echo "Source line added successfully"
fi

echo "Look'n'feel overrides setup complete!"

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi
