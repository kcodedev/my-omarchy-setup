#!/bin/bash
# Install the Git dashboard from its independent repository.
set -euo pipefail

REPO_URL="${GIT_REPOS_PLUGIN_URL:-git@github.com:kcodedev/omarchy-git-repos.git}"
REPO_DIR="${GIT_REPOS_PLUGIN_DIR:-$HOME/Repos/omarchy-git-repos}"

if [[ -d "$REPO_DIR/.git" ]]; then
    if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
        echo "Git dashboard has local changes; keeping the existing checkout."
    else
        git -C "$REPO_DIR" pull --ff-only
    fi
elif [[ -e "$REPO_DIR" ]]; then
    echo "Path exists but is not a Git repository: $REPO_DIR" >&2
    exit 1
else
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone -- "$REPO_URL" "$REPO_DIR"
fi

python3 "$REPO_DIR/install.py"
