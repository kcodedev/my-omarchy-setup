#!/bin/bash

set -euo pipefail

case "${1:-}" in
    help|-h|--help)
        echo "Usage: ./cleanup/remove-spotify.sh"
        echo "Removes Spotify; preserves app settings and user data."
        exit 0
        ;;
esac

if [ "$#" -ne 0 ]; then
    echo "Unexpected argument: $1" >&2
    exit 1
fi

if pacman -Qi spotify >/dev/null 2>&1; then
    echo "Removing Spotify package"
    yay -Rns --noconfirm spotify
else
    echo "Spotify package is not installed"
fi
