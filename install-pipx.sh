#!/bin/bash

# Install pipx
yay -S --noconfirm --needed pipx

# Install pylsp and mypy using pipx
pipx install python-lsp-server
pipx install mypy
