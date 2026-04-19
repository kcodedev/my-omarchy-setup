#!/bin/bash

set -euo pipefail

ORIGINAL_DIR="$(pwd)"

REPO_URL="git@github.com:kcodedev/shell-scripts.git"
REPO_NAME="shell-scripts"
REPOS_DIR="$HOME/Repos"

if [ ! -d "$REPOS_DIR" ]; then
    echo "Creating $REPOS_DIR directory"
    mkdir -p "$REPOS_DIR"
fi

cd "$REPOS_DIR"

if [ -d "$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' already exists in $REPOS_DIR. Skipping clone"
else
    echo "Cloning $REPO_NAME to $REPOS_DIR"
    git clone "$REPO_URL"
    echo "Successfully cloned $REPO_NAME to $REPOS_DIR"
fi

echo "Shell-scripts repo setup complete!"

cd "$ORIGINAL_DIR"
