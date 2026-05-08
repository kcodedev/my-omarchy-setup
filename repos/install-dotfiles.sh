#!/bin/bash

set -euo pipefail

REPO_URL="${CHEZMOI_DOTFILES_REPO_URL:-git@github.com:kcodedev/dotfiles-chezmoi.git}"
SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}"

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

source_has_changes() {
    [ -n "$(git -C "$SOURCE_DIR" status --porcelain 2>/dev/null)" ]
}

init_source() {
    if [ -d "$SOURCE_DIR/.git" ]; then
        return 0
    fi

    if [ -e "$SOURCE_DIR" ]; then
        echo "Chezmoi source path exists but is not a git repository: $SOURCE_DIR"
        exit 1
    fi

    echo "Initializing chezmoi source from $REPO_URL"
    chezmoi init --source "$SOURCE_DIR" "$REPO_URL"
}

update_source() {
    if source_has_changes; then
        echo "Chezmoi source has local changes. Skipping pull: $SOURCE_DIR"
        return 0
    fi

    echo "Updating chezmoi source"
    git -C "$SOURCE_DIR" pull --ff-only
}

apply_dotfiles() {
    echo "Applying chezmoi-managed dotfiles"
    chezmoi --source "$SOURCE_DIR" apply --verbose
}

refresh_desktop_launchers() {
    local applications_dir="$HOME/.local/share/applications"

    if [ -d "$applications_dir" ] && command -v update-desktop-database >/dev/null 2>&1; then
        echo "Updating local desktop application database"
        update-desktop-database "$applications_dir" || true
    fi

    if command -v omarchy-restart-walker >/dev/null 2>&1; then
        echo "Restarting Walker"
        omarchy-restart-walker || true
    fi
}

require_command git
require_command chezmoi

init_source
update_source
apply_dotfiles
refresh_desktop_launchers
