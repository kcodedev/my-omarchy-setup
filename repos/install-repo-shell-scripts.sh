#!/bin/bash

REPO_URL="git@github.com:kcodedev/shell-scripts.git"
REPO_NAME="shell-scripts"
REPOS_DIR="$HOME/Repos"

# Create Repos directory if it doesn't exist
if [ ! -d "$REPOS_DIR" ]; then
    echo "Creating $REPOS_DIR directory"
    mkdir -p "$REPOS_DIR"
fi

cd "$REPOS_DIR"

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' already exists in $REPOS_DIR. Skipping clone"
else
    echo "Cloning $REPO_NAME to $REPOS_DIR"
    git clone "$REPO_URL"
    
    # Check if the clone was successful
    if [ $? -eq 0 ]; then
        echo "Successfully cloned $REPO_NAME to $REPOS_DIR"
    else
        echo "Failed to clone the repository."
        exit 1
    fi
fi

echo "Shell-scripts repo setup complete!"
