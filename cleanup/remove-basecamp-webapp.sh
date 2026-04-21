#!/bin/bash

set -euo pipefail

paths=(
    "$HOME/.local/share/applications/Basecamp.desktop"
    "$HOME/.local/share/applications/icons/Basecamp.png"
    "$HOME/.local/share/omarchy/applications/icons/Basecamp.png"
)

for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -f "$path"
    else
        echo "Already absent: $path"
    fi
done

if command -v update-desktop-database >/dev/null 2>&1; then
    echo "Refreshing desktop database"
    update-desktop-database "$HOME/.local/share/applications"
fi
