#!/bin/bash
# 
ORIGINAL_DIR=$(pwd)

REPO_URL="git@github.com:kcodedev/dotfiles.git"
REPO_NAME="dotfiles"

is_stow_installed() {
  pacman -Qi "stow" &> /dev/null
}

if ! is_stow_installed; then
  echo "Install stow first"
  exit 1
fi

cd ~

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
  git clone "$REPO_URL"
fi

# Check if the clone was successful
if [ $? -eq 0 ]; then
  # Remove old configs before stowing
  # Stow won't overwrite existing files - it only creates symlinks
  echo "removing old configs"
  rm -rf ~/.config/helix
  rm -rf ~/.config/bash
  rm -rf ~/.config/fuzzel
  rm -f ~/.bashrc
  rm -f ~/.tmux.conf

  cd "$REPO_NAME"
  stow bash
  stow tmux
  stow helix
  stow fuzzel
else
  echo "Failed to clone the repository."
  exit 1
fi

