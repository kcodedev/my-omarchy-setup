#!/bin/bash

set -euo pipefail

case "${1:-}" in
    help|-h|--help)
        echo "Usage: ./cleanup/remove-cursor.sh"
        echo "Removes Cursor; preserves app settings and user data."
        exit 0
        ;;
esac

if [ "$#" -ne 0 ]; then
    echo "Unexpected argument: $1" >&2
    exit 1
fi

if pacman -Qi cursor-bin >/dev/null 2>&1; then
    echo "Removing Cursor package"
    yay -Rns --noconfirm cursor-bin
else
    echo "Cursor package is not installed"
fi
