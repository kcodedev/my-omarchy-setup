#!/bin/bash

# Script to update Helix theme based on omarchy theme change
# Called from theme-set hook with theme name as argument

THEME="${1:-dark}"  # Default to dark if not provided

# Load theme mappings from file
declare -A THEME_MAP
MAPPINGS_FILE="$(dirname "$0")/theme-mappings.txt"
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
  sed -i "s/theme = \".*\"/theme = \"$HELIX_THEME\"/" "$CONFIG_FILE"
fi