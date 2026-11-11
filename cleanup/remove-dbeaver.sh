#!/bin/bash

set -euo pipefail

case "${1:-}" in
    help|-h|--help)
        echo "Usage: ./cleanup/remove-dbeaver.sh"
        echo "Removes DBeaver; preserves app settings and user data."
        exit 0
        ;;
esac

if [ "$#" -ne 0 ]; then
    echo "Unexpected argument: $1" >&2
    exit 1
fi

if pacman -Qi dbeaver >/dev/null 2>&1; then
    echo "Removing DBeaver package"
    yay -Rns --noconfirm dbeaver
else
    echo "DBeaver package is not installed"
fi
