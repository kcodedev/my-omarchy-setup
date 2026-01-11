#!/bin/sh

# Install all the necessary packages
. ./install-stow.sh
. ./install-helix.sh
. ./install-keepassxc.sh
. ./install-taskwarrior.sh
. ./install-brave-bin.sh
. ./install-tmux.sh
. ./install-visual-studio-code-bin.sh
. ./install-cursor-bin.sh
. ./install-yazi.sh
. ./install-podman.sh

# Install the hyprland overrides
. ./install-hyprland-overrides.sh

# Install dotfiles to the home directory
. ./install-dotfiles.sh

