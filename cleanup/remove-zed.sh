#!/bin/bash

set -euo pipefail

case "${1:-}" in
    help|-h|--help)
        echo "Usage: ./cleanup/remove-zed.sh"
        echo "Removes Zed; preserves app settings and user data."
        exit 0
        ;;
esac

if [ "$#" -ne 0 ]; then
    echo "Unexpected argument: $1" >&2
    exit 1
fi

if pacman -Qi zed >/dev/null 2>&1; then
    echo "Removing Zed package"
    yay -Rns --noconfirm zed
else
    echo "Zed package is not installed"
fi
