#!/bin/bash

set -euo pipefail

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.lua"
REQUIRED_MODULES=(
    "hypr.monitors"
    "hypr.input"
    "hypr.bindings"
    "hypr.looknfeel"
    "hypr.autostart"
)

if [ ! -f "$HYPRLAND_CONFIG" ]; then
    echo "Hyprland Lua config not found at $HYPRLAND_CONFIG"
    echo "Skipping Hyprland validation"
    exit 0
fi

if ! grep -Fq '/default/hypr/bootstrap.lua' "$HYPRLAND_CONFIG"; then
    echo "Hyprland Lua config does not load Omarchy's bootstrap: $HYPRLAND_CONFIG" >&2
    echo "Run 'omarchy refresh config hypr/hyprland.lua', then re-apply your personal Lua modules." >&2
    exit 1
fi

missing_modules=()
for module in "${REQUIRED_MODULES[@]}"; do
    if ! grep -Fq "require(\"$module\")" "$HYPRLAND_CONFIG"; then
        missing_modules+=("$module")
    fi
done

if [ "${#missing_modules[@]}" -gt 0 ]; then
    echo "Hyprland Lua config is missing Omarchy user-module imports:" >&2
    printf '  require("%s")\n' "${missing_modules[@]}" >&2
    echo "Refresh the entrypoint with 'omarchy refresh config hypr/hyprland.lua'." >&2
    exit 1
fi

echo "Hyprland Lua entrypoint is configured for Omarchy 4"

if command -v hyprctl >/dev/null 2>&1; then
    if hyprctl reload >/dev/null 2>&1; then
        config_errors="$(hyprctl configerrors 2>/dev/null || true)"
        if [ -n "$config_errors" ]; then
            echo "Hyprland configuration errors:" >&2
            printf '%s\n' "$config_errors" >&2
            exit 1
        fi
        echo "Hyprland configuration reloaded without errors"
    else
        echo "Hyprland is not reachable; skipped live reload validation"
    fi
fi
