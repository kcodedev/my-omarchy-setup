#!/bin/bash

set -euo pipefail

# Script to update Helix theme based on Omarchy theme changes.
# Omarchy historically called ~/.config/omarchy/hooks/theme-set with the new
# theme name as $1, but this script can also fall back to the current theme.

OMARCHY_CURRENT_THEME_FILE="$HOME/.config/omarchy/current/theme.name"
THEME="${1:-}"

if [ -z "$THEME" ] && [ -f "$OMARCHY_CURRENT_THEME_FILE" ]; then
  THEME="$(tr -d '\n' < "$OMARCHY_CURRENT_THEME_FILE")"
fi

THEME="${THEME:-dark}"

# Load theme mappings from file
declare -A THEME_MAP
MAPPINGS_FILE="$(dirname "$0")/hx-theme-mappings.txt"
if [ -f "$MAPPINGS_FILE" ]; then
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ $key =~ ^[[:space:]]*# ]] && continue
    [[ -z $key ]] && continue
    THEME_MAP["$key"]="$value"
  done < "$MAPPINGS_FILE"
fi

# Get Helix theme from mapping, fallback to term16_dark
HELIX_THEME="${THEME_MAP[$THEME]:-term16_dark}"

# Update Helix config
CONFIG_FILE="$HOME/.config/helix/config.toml"
if [ -f "$CONFIG_FILE" ]; then
  if grep -Eq '^[[:space:]]*theme[[:space:]]*=' "$CONFIG_FILE"; then
    sed -i -E "s/^[[:space:]]*theme[[:space:]]*=.*/theme = \"$HELIX_THEME\"/" "$CONFIG_FILE"
  else
    tmp_file="$(mktemp)"
    {
      printf 'theme = "%s"\n' "$HELIX_THEME"
      cat "$CONFIG_FILE"
    } > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
  fi
fi
