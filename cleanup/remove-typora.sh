#!/bin/bash

set -euo pipefail

PURGE_DATA=0

usage() {
    cat <<'EOF'
Usage: ./cleanup/remove-typora.sh [--purge-data]

Removes the Typora package and Omarchy launcher assets.
Pass --purge-data to also delete Typora config, data, cache, and Omarchy Typora config files.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --purge-data)
            PURGE_DATA=1
            ;;
        help|-h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if pacman -Qi typora >/dev/null 2>&1; then
    echo "Removing Typora package"
    yay -Rns --noconfirm typora
else
    echo "Typora package is not installed"
fi

launcher_paths=(
    "$HOME/.local/share/applications/typora.desktop"
    "$HOME/.local/share/omarchy/applications/typora.desktop"
)

for path in "${launcher_paths[@]}"; do
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

if [ "$PURGE_DATA" -ne 1 ]; then
    echo "Skipping Typora data purge. Re-run with --purge-data to remove app data."
    exit 0
fi

purge_paths=(
    "$HOME/.config/Typora"
    "$HOME/.local/share/Typora"
    "$HOME/.cache/Typora"
    "$HOME/.local/share/omarchy/config/Typora"
)

for path in "${purge_paths[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -rf "$path"
    else
        echo "Already absent: $path"
    fi
done
