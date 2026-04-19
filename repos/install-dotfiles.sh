#!/bin/bash

set -euo pipefail

ORIGINAL_DIR="$(pwd)"

REPO_URL="git@github.com:kcodedev/dotfiles.git"
REPO_NAME="dotfiles"
REPO_DIR="$HOME/$REPO_NAME"
BACKUP_DIR="$HOME/.config-backups/dotfiles-$(date +%Y%m%d-%H%M%S)"

update_repo() {
  if [ -d "$REPO_DIR/.git" ]; then
    if [ -n "$(git -C "$REPO_DIR" status --porcelain 2>/dev/null)" ]; then
      echo "Repository '$REPO_NAME' has local changes. Skipping pull"
    else
      echo "Updating repository '$REPO_NAME'"
      git -C "$REPO_DIR" pull --ff-only
    fi
  elif [ -d "$REPO_DIR" ]; then
    echo "Path exists but is not a git repository: $REPO_DIR"
    exit 1
  else
    git clone "$REPO_URL"
  fi
}

package_targets() {
  find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.git' -printf '%f\n' | sort
}

backup_package_targets() {
  local package="$1"
  local entry
  local child

  while IFS= read -r entry; do
    [ -n "$entry" ] || continue

    if [ "$entry" = ".config" ] && [ -d "$package/.config" ]; then
      while IFS= read -r child; do
        [ -n "$child" ] || continue
        backup_path "$HOME/.config/$child"
      done < <(find "$package/.config" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
    else
      backup_path "$HOME/$entry"
    fi
  done < <(find "$package" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
}

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

update_repo

cd "$REPO_DIR"

mapfile -t packages < <(package_targets)

if [ "${#packages[@]}" -eq 0 ]; then
  echo "No stow packages found in $REPO_DIR"
  exit 1
fi

for package in "${packages[@]}"; do
  backup_package_targets "$package"
done

stow -t "$HOME" "${packages[@]}"

cd "$ORIGINAL_DIR"
