#!/bin/bash

set -euo pipefail

PURGE_DATA=0

usage() {
    cat <<'EOF'
Usage: ./cleanup/remove-signal-desktop.sh [--purge-data]

Removes the Signal Desktop package.
Pass --purge-data to also delete Signal config, data, and cache directories.
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

if pacman -Qi signal-desktop >/dev/null 2>&1; then
    echo "Removing Signal Desktop package"
    yay -Rns --noconfirm signal-desktop
else
    echo "Signal Desktop package is not installed"
fi

if [ "$PURGE_DATA" -ne 1 ]; then
    echo "Skipping Signal Desktop data purge. Re-run with --purge-data to remove app data."
    exit 0
fi

paths=(
    "$HOME/.config/Signal"
    "$HOME/.local/share/Signal"
    "$HOME/.cache/Signal"
)

for path in "${paths[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -rf "$path"
    else
        echo "Already absent: $path"
    fi
done
