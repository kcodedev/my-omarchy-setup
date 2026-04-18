#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Install all the necessary packages
. ./packages/install-stow.sh
. ./packages/install-helix.sh
. ./packages/install-keepassxc.sh
. ./packages/install-taskwarrior.sh
. ./packages/install-brave-bin.sh
. ./packages/install-zellij.sh
. ./packages/install-tmux.sh
. ./packages/install-kitty.sh
. ./packages/install-visual-studio-code-bin.sh
. ./packages/install-cursor-bin.sh
. ./packages/install-yazi.sh
. ./packages/install-podman.sh
. ./packages/install-localsend.sh
. ./packages/install-obsidian.sh
. ./packages/install-fuzzel.sh
. ./packages/install-pipx.sh
. ./packages/install-glow.sh
. ./packages/install-bash-language-server.sh
. ./packages/install-models.sh

# Install KiloCode CLI
npm install -g @kilocode/cli

# Install my shell-scripts Repo
. ./repos/install-repo-shell-scripts.sh

# Install the hyprland overrides
. ./install-hyprland-overrides.sh

# Install dotfiles to the home directory
. ./repos/install-dotfiles.sh
