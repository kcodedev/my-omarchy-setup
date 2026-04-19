#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

run_script() {
    . "$SCRIPT_DIR/$1"
}

require_command yay
require_command git

# Install all the necessary packages
run_script packages/install-stow.sh
run_script packages/install-helix.sh
run_script packages/install-keepassxc.sh
run_script packages/install-taskwarrior.sh
run_script packages/install-brave-bin.sh
run_script packages/install-zellij.sh
run_script packages/install-tmux.sh
run_script packages/install-kitty.sh
run_script packages/install-visual-studio-code-bin.sh
run_script packages/install-cursor-bin.sh
run_script packages/install-yazi.sh
run_script packages/install-podman.sh
run_script packages/install-localsend.sh
run_script packages/install-obsidian.sh
run_script packages/install-fuzzel.sh
run_script packages/install-nodejs-npm.sh
run_script packages/install-pipx.sh
run_script packages/install-glow.sh
run_script packages/install-bash-language-server.sh
run_script packages/install-models.sh

# Install KiloCode CLI
run_script packages/install-kilocode-cli.sh

# Install my shell-scripts Repo
run_script repos/install-repo-shell-scripts.sh

# Install the Hyprland overrides
run_script install-hyprland-overrides.sh
run_script install-input-overrides.sh

# Install dotfiles to the home directory
run_script repos/install-dotfiles.sh
