#!/bin/bash

# Remove Signal Desktop package
if pacman -Qi signal-desktop >/dev/null 2>&1; then
    yay -Rns --noconfirm signal-desktop 2>/dev/null || true
fi

# Remove Signal config directory
if [ -d ~/.config/Signal ]; then
    rm -rf ~/.config/Signal
fi

# Remove Signal data directory
if [ -d ~/.local/share/Signal ]; then
    rm -rf ~/.local/share/Signal
fi

# Remove Signal cache directory
if [ -d ~/.cache/Signal ]; then
    rm -rf ~/.cache/Signal
fi
