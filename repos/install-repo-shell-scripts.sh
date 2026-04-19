#!/bin/bash

set -euo pipefail

ORIGINAL_DIR="$(pwd)"

REPO_URL="git@github.com:kcodedev/shell-scripts.git"
REPO_NAME="shell-scripts"
REPOS_DIR="$HOME/Repos"
REPO_DIR="$REPOS_DIR/$REPO_NAME"
BIN_DIR="$HOME/.local/bin"

update_repo() {
    if [ -d "$REPO_DIR/.git" ]; then
        if [ -n "$(git -C "$REPO_DIR" status --porcelain 2>/dev/null)" ]; then
            echo "Repository '$REPO_NAME' has local changes. Skipping pull"
        else
            echo "Updating $REPO_NAME in $REPOS_DIR"
            git -C "$REPO_DIR" pull --ff-only
        fi
    elif [ -d "$REPO_DIR" ]; then
        echo "Path exists but is not a git repository: $REPO_DIR"
        exit 1
    else
        echo "Cloning $REPO_NAME to $REPOS_DIR"
        git clone "$REPO_URL"
        echo "Successfully cloned $REPO_NAME to $REPOS_DIR"
    fi
}

install_wrapper() {
    local command_name="$1"
    local target_script="$2"
    local script_args="${3:-}"
    local wrapper_path="$BIN_DIR/$command_name"

    cat > "$wrapper_path" <<EOF
#!/bin/bash
set -euo pipefail
export KC_SHELL_SCRIPTS_DIR="$REPO_DIR"
exec "$REPO_DIR/$target_script" $script_args "\$@"
EOF

    chmod +x "$wrapper_path"
    echo "Installed wrapper: $wrapper_path"
}

if [ ! -d "$REPOS_DIR" ]; then
    echo "Creating $REPOS_DIR directory"
    mkdir -p "$REPOS_DIR"
fi

if [ ! -d "$BIN_DIR" ]; then
    echo "Creating $BIN_DIR directory"
    mkdir -p "$BIN_DIR"
fi

cd "$REPOS_DIR"

update_repo

install_wrapper "kc-project-launch" "project-launch.sh"
install_wrapper "kc-project-launch-active" "project-launch.sh" "active"
install_wrapper "kc-bookmark-launch" "bm-launch.sh"
install_wrapper "kc-cheatsheet-launch" "cheatsheet-launch.sh"
install_wrapper "kc-emoji-launch" "emoji-launch.sh"
install_wrapper "kc-keymap" "keymap.sh"
install_wrapper "kc-search-launch" "search-launch.sh"
install_wrapper "kc-git-repo-status" "git_repo_status.sh"

echo "Shell-scripts repo setup complete!"

cd "$ORIGINAL_DIR"
