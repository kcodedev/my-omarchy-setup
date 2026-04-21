#!/bin/bash

set -euo pipefail

PURGE_DATA=0
PACKAGES=(
    1password-beta
    1password-cli
)
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
PASSWORDS_BINDING='bindd = SUPER SHIFT, SLASH, Passwords, exec, uwsm-app -- 1password'

usage() {
    cat <<'EOF'
Usage: ./cleanup/remove-1password.sh [--purge-data]

Removes the 1Password desktop app and CLI packages.
Pass --purge-data to also delete local 1Password config, cache, and data directories if present.
EOF
}

remove_package_if_installed() {
    local package_name="$1"

    if pacman -Qi "$package_name" >/dev/null 2>&1; then
        echo "Removing package: $package_name"
        yay -Rns --noconfirm "$package_name"
    else
        echo "Package not installed: $package_name"
    fi
}

remove_hypr_binding() {
    local target_file="$1"
    local binding_line="$2"
    local tmp_file

    if [ ! -f "$target_file" ]; then
        echo "Hyprland bindings file not found: $target_file"
        return
    fi

    if ! grep -Fxq "$binding_line" "$target_file"; then
        echo "1Password Hyprland binding already absent"
        return
    fi

    tmp_file="$(mktemp)"
    grep -Fvx "$binding_line" "$target_file" > "$tmp_file"
    cp "$target_file" "$target_file.bak"
    mv "$tmp_file" "$target_file"
    echo "Removed 1Password binding from $target_file"
}

for arg in "$@"; do
    case "$arg" in
        --purge-data)
            PURGE_DATA=1
            ;;
        help|-h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

for package_name in "${PACKAGES[@]}"; do
    remove_package_if_installed "$package_name"
done

remove_hypr_binding "$BINDINGS_FILE" "$PASSWORDS_BINDING"

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
fi

if [ "$PURGE_DATA" -ne 1 ]; then
    echo "Skipping 1Password data purge. Re-run with --purge-data to remove app data."
    exit 0
fi

purge_paths=(
    "$HOME/.config/1Password"
    "$HOME/.cache/1Password"
    "$HOME/.local/share/1Password"
    "$HOME/.config/op"
    "$HOME/.cache/op"
    "$HOME/.local/share/op"
)

for path in "${purge_paths[@]}"; do
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -rf "$path"
    else
        echo "Already absent: $path"
    fi
done
