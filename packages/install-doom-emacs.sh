#!/bin/bash

# Install prerequisites
yay -S --noconfirm --needed emacs

# Remove existing Doom Emacs if it exists
if [ -d ~/.config/emacs ]; then
    systemctl --user stop emacs.service 2>/dev/null || true
    rm -rf ~/.config/emacs
fi
if [ -d ~/.config/doom ]; then
    rm -rf ~/.config/doom
fi
if [ -f ~/.config/systemd/user/emacs.service ]; then
    systemctl --user disable emacs.service 2>/dev/null || true
    rm -f ~/.config/systemd/user/emacs.service
    systemctl --user daemon-reload
fi

# Install Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install