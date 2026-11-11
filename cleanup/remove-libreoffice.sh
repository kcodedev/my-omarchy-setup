#!/bin/bash

set -euo pipefail

case "${1:-}" in
    help|-h|--help)
        echo "Usage: ./cleanup/remove-libreoffice.sh"
        echo "Removes LibreOffice; preserves app settings and user data."
        exit 0
        ;;
esac

if [ "$#" -ne 0 ]; then
    echo "Unexpected argument: $1" >&2
    exit 1
fi

if pacman -Qi libreoffice-fresh >/dev/null 2>&1; then
    echo "Removing LibreOffice package"
    yay -Rns --noconfirm libreoffice-fresh
else
    echo "LibreOffice package is not installed"
fi
