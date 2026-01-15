#!/bin/bash

# Stop and disable Emacs service if it exists
if [ -f ~/.config/systemd/user/emacs.service ]; then
    systemctl --user stop emacs.service 2>/dev/null || true
    systemctl --user disable emacs.service 2>/dev/null || true
    rm -f ~/.config/systemd/user/emacs.service
    systemctl --user daemon-reload
fi

# Remove Doom Emacs directory
if [ -d ~/.config/emacs ]; then
    rm -rf ~/.config/emacs
fi

# Remove Doom configs
if [ -d ~/.config/doom ]; then
    rm -rf ~/.config/doom
fi

# Remove alternative Doom config location
if [ -d ~/.doom.d ]; then
    rm -rf ~/.doom.d
fi

# Uninstall Emacs
installed_emacs=$(pacman -Q | grep '^emacs' | head -1 | awk '{print $1}')
if [ -n "$installed_emacs" ]; then
    yay -Rns --noconfirm "$installed_emacs" 2>/dev/null || true
fi