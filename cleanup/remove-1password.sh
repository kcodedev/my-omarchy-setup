#!/bin/bash

set -euo pipefail

PURGE_DATA=0
PACKAGES=(
    1password-beta
    1password-cli
)
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"
PASSWORDS_UNBIND='hl.unbind("SUPER + SHIFT + SLASH")'

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

ensure_hypr_unbind() {
    local target_file="$1"
    local unbind_line="$2"

    if [ ! -f "$target_file" ]; then
        echo "Hyprland bindings file not found: $target_file"
        return
    fi

    if grep -Fxq "$unbind_line" "$target_file"; then
        echo "1Password Hyprland binding already disabled"
        return
    fi

    cp "$target_file" "$target_file.bak"
    printf '\n-- Disable Omarchy\047s packaged 1Password binding.\n%s\n' "$unbind_line" >>"$target_file"
    echo "Disabled the 1Password binding in $target_file"
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

ensure_hypr_unbind "$BINDINGS_FILE" "$PASSWORDS_UNBIND"

if command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1; then
    config_errors="$(hyprctl configerrors 2>/dev/null || true)"
    if [ -n "$config_errors" ]; then
        echo "Hyprland configuration errors:" >&2
        printf '%s\n' "$config_errors" >&2
        exit 1
    fi
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
