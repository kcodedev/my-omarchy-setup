#!/bin/bash

set -euo pipefail

ORIGINAL_DIR="$(pwd)"

REPO_URL="git@github.com:kcodedev/shell-scripts.git"
REPO_NAME="shell-scripts"
REPOS_DIR="$HOME/Repos"
REPO_DIR="$REPOS_DIR/$REPO_NAME"
BIN_DIR="$HOME/.local/bin"

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

if [ -d "$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' already exists in $REPOS_DIR. Skipping clone"
else
    echo "Cloning $REPO_NAME to $REPOS_DIR"
    git clone "$REPO_URL"
    echo "Successfully cloned $REPO_NAME to $REPOS_DIR"
fi

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
