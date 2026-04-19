#!/bin/bash

set -euo pipefail

UPGRADE_EXISTING="${BOOTSTRAP_UPGRADE:-0}"

yay -S --noconfirm --needed python-pipx
pipx ensurepath >/dev/null 2>&1 || true

manage_pipx_package() {
    local package_name="$1"

    if pipx list --short 2>/dev/null | grep -Fxq "$package_name"; then
        if [ "$UPGRADE_EXISTING" = "1" ]; then
            pipx upgrade "$package_name"
        else
            echo "pipx package already installed: $package_name"
        fi
    else
        pipx install "$package_name"
    fi
}

manage_pipx_package python-lsp-server
manage_pipx_package mypy
