#!/bin/sh

# Install all the necessary packages
. ./install-stow.sh
. ./install-helix.sh
. ./install-keepassxc.sh
. ./install-taskwarrior.sh
. ./install-brave-bin.sh
. ./install-tmux.sh
. ./install-kitty.sh
. ./install-visual-studio-code-bin.sh
. ./install-cursor-bin.sh
. ./install-yazi.sh
. ./install-podman.sh
. ./install-localsend.sh
. ./install-obsidian.sh
. ./install-fuzzel.sh
. ./install-pipx.sh

# Install my shell-scripts Repo
. ./install-repo-shell-scripts.sh

# Install the hyprland overrides
. ./install-hyprland-overrides.sh

# Install dotfiles to the home directory
. ./install-dotfiles.sh

