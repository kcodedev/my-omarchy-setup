#!/bin/bash

# Install prerequisites
yay -S --noconfirm --needed emacs ripgrep fd git

# Install Doom Emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install