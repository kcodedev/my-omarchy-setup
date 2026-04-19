#!/bin/bash

set -euo pipefail

ORIGINAL_DIR="$(pwd)"

REPO_URL="git@github.com:kcodedev/dotfiles.git"
REPO_NAME="dotfiles"
REPO_DIR="$HOME/$REPO_NAME"
BACKUP_DIR="$HOME/.config-backups/dotfiles-$(date +%Y%m%d-%H%M%S)"

backup_path() {
  local target="$1"
  local backup_target

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi

  backup_target="$BACKUP_DIR/${target#$HOME/}"
  mkdir -p "$(dirname "$backup_target")"
  mv "$target" "$backup_target"
  echo "Backed up $target to $backup_target"
}

if ! pacman -Qi stow >/dev/null 2>&1; then
  echo "Install stow first"
  exit 1
fi

cd "$HOME"

if [ -d "$REPO_DIR" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
  git clone "$REPO_URL"
fi

backup_path "$HOME/.config/helix"
backup_path "$HOME/.config/bash"
backup_path "$HOME/.config/fuzzel"
backup_path "$HOME/.bashrc"
backup_path "$HOME/.tmux.conf"

cd "$REPO_DIR"
stow bash
stow tmux
stow helix
stow fuzzel

cd "$ORIGINAL_DIR"
