#!/bin/bash

set -euo pipefail

yay -S --noconfirm --needed python-pipx
pipx ensurepath >/dev/null 2>&1 || true

pipx install --force python-lsp-server
pipx install --force mypy
