#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-install}"
PRODUCT_NAME="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")"

PACKAGE_SCRIPTS=(
    "packages/install-stow.sh"
    "packages/install-helix.sh"
    "packages/install-keepassxc.sh"
    "packages/install-brave-bin.sh"
    "packages/install-zellij.sh"
    "packages/install-tmux.sh"
    "packages/install-kitty.sh"
    "packages/install-visual-studio-code-bin.sh"
    "packages/install-cursor-bin.sh"
    "packages/install-yazi.sh"
    "packages/install-podman.sh"
    "packages/install-localsend.sh"
    "packages/install-obsidian.sh"
    "packages/install-dbeaver.sh"
    "packages/install-dropbox-cli.sh"
    "packages/install-fuzzel.sh"
    "packages/install-cava.sh"
    "packages/install-lazygit.sh"
    "packages/install-nodejs-npm.sh"
    "packages/install-pipx.sh"
    "packages/install-glow.sh"
    "packages/install-bash-language-server.sh"
    "packages/install-models.sh"
)

step_index=0
step_total=0

require_command() {
    local command_name="$1"

    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "Missing required command: $command_name"
        exit 1
    fi
}

run_script() {
    local script_path="$SCRIPT_DIR/$1"

    if [ ! -f "$script_path" ]; then
        echo "Missing install script: $script_path"
        exit 1
    fi

    bash "$script_path"
}

run_step() {
    local label="$1"
    shift

    step_index=$((step_index + 1))
    printf '\n[%d/%d] %s\n' "$step_index" "$step_total" "$label"
    "$@"
}

has_hyprland_config() {
    [ -f "$HOME/.config/hypr/hyprland.conf" ]
}

has_omarchy_install() {
    [ -d "$HOME/.config/omarchy" ]
}

has_local_bin_on_path() {
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) return 0 ;;
        *) return 1 ;;
    esac
}

is_macbook_host() {
    [[ "$PRODUCT_NAME" == *"MacBook"* ]]
}

print_status() {
    local label="$1"
    local status="$2"
    local details="${3:-}"

    if [ -n "$details" ]; then
        printf '%-22s %-12s %s\n' "$label" "$status" "$details"
    else
        printf '%-22s %-12s\n' "$label" "$status"
    fi
}

report_command_status() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        print_status "$command_name" "ok" "$(command -v "$command_name")"
    else
        print_status "$command_name" "missing"
    fi
}

report_repo_status() {
    local label="$1"
    local repo_dir="$2"

    if [ ! -d "$repo_dir" ]; then
        print_status "$label" "missing" "$repo_dir"
        return
    fi

    if [ ! -d "$repo_dir/.git" ]; then
        print_status "$label" "invalid" "$repo_dir is not a git repo"
        return
    fi

    if [ -n "$(git -C "$repo_dir" status --porcelain 2>/dev/null)" ]; then
        print_status "$label" "dirty" "$repo_dir"
    else
        print_status "$label" "clean" "$repo_dir"
    fi
}

report_source_line_status() {
    local label="$1"
    local target_file="$2"
    local source_line="$3"

    if [ ! -f "$target_file" ]; then
        print_status "$label" "skipped" "$target_file not present"
        return
    fi

    if grep -Fxq "$source_line" "$target_file"; then
        print_status "$label" "installed"
    else
        print_status "$label" "missing"
    fi
}

doctor() {
    echo "Setup doctor"
    echo "Mode: inspect-only"
    echo

    print_status "host" "$(if is_macbook_host; then echo macbook; else echo generic; fi)" "$PRODUCT_NAME"
    report_command_status yay
    report_command_status git
    report_command_status stow
    report_command_status npm
    report_command_status pipx

    if has_local_bin_on_path; then
        print_status "PATH ~/.local/bin" "ok"
    else
        print_status "PATH ~/.local/bin" "missing"
    fi

    report_repo_status "dotfiles repo" "$HOME/dotfiles"
    report_repo_status "shell-scripts repo" "$HOME/Repos/shell-scripts"

    report_source_line_status \
        "hypr overrides" \
        "$HOME/.config/hypr/hyprland.conf" \
        "source = $SCRIPT_DIR/hyprland-overrides.conf"
    report_source_line_status \
        "looknfeel overrides" \
        "$HOME/.config/hypr/hyprland.conf" \
        "source = $SCRIPT_DIR/looknfeel-overrides.conf"
    report_source_line_status \
        "input overrides" \
        "$HOME/.config/hypr/hyprland.conf" \
        "source = $SCRIPT_DIR/input-overrides.conf"

    if [ -x "$HOME/.config/omarchy/hooks/theme-set" ]; then
        print_status "omarchy theme hook" "installed"
    elif has_omarchy_install; then
        print_status "omarchy theme hook" "missing"
    else
        print_status "omarchy theme hook" "skipped" "~/.config/omarchy not present"
    fi
}

perform_install() {
    local include_hyprland_steps=0
    local include_theme_hook=0

    require_command yay
    require_command git

    if has_hyprland_config; then
        include_hyprland_steps=1
    fi

    if has_omarchy_install; then
        include_theme_hook=1
    fi

    step_total=${#PACKAGE_SCRIPTS[@]}
    step_total=$((step_total + 3))

    if [ "$MODE" = "install" ] && is_macbook_host; then
        step_total=$((step_total + 1))
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        step_total=$((step_total + 3))
    fi

    if [ "$include_theme_hook" -eq 1 ]; then
        step_total=$((step_total + 1))
    fi

    echo "Setup mode: $MODE"
    echo "Detected host: $PRODUCT_NAME"
    echo

    for package_script in "${PACKAGE_SCRIPTS[@]}"; do
        run_step "Running $package_script" run_script "$package_script"
    done

    run_step "Installing KiloCode CLI" run_script packages/install-kilocode-cli.sh
    run_step "Syncing shell-scripts repo and wrappers" run_script repos/install-repo-shell-scripts.sh
    run_step "Syncing dotfiles" run_script repos/install-dotfiles.sh

    if [ "$MODE" = "install" ] && is_macbook_host; then
        run_step "Running MacBook hardware extras" run_script hardware/install-macbook-air.sh
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        run_step "Installing Hyprland overrides" run_script install-hyprland-overrides.sh
        run_step "Installing look'n'feel overrides" run_script install-looknfeel-overrides.sh
        run_step "Installing input overrides" run_script install-input-overrides.sh
    else
        echo
        echo "[skip] Hyprland config not present; skipping Hyprland-specific steps"
    fi

    if [ "$include_theme_hook" -eq 1 ]; then
        run_step "Installing Omarchy theme hook" run_script theme-changer/install-omarchy-theme-hook.sh
    else
        echo
        echo "[skip] Omarchy config not present; skipping theme hook"
    fi
}

case "$MODE" in
    install|sync)
        perform_install
        ;;
    doctor)
        doctor
        ;;
    help|-h|--help)
        cat <<'EOF'
Usage: ./master-installation.sh [install|sync|doctor]

install  Full setup run, including host-specific extras.
sync     Re-run the reusable setup steps and update existing repos.
doctor   Inspect local setup state without changing anything.

Set BOOTSTRAP_UPGRADE=1 to upgrade already-installed npm and pipx tools.
EOF
        ;;
    *)
        echo "Unknown mode: $MODE"
        echo "Run ./master-installation.sh help for usage."
        exit 1
        ;;
esac
