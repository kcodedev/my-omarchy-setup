#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-install}"
PRODUCT_NAME="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")"

YAY_PACKAGES=(
    jq
    stow
    helix
    keepassxc
    brave-bin
    zellij
    tmux
    kitty
    visual-studio-code-bin
    cursor-bin
    yazi
    podman
    podman-compose
    localsend
    obsidian
    dbeaver
    dropbox-cli
    fuzzel
    cava
    lazygit
    nodejs
    npm
    glow
    bash-language-server
    models-bin
)

SPECIAL_INSTALL_SCRIPTS=(
    "packages/install-pipx.sh"
    "packages/install-kilocode-cli.sh"
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

install_yay_packages() {
    if [ "$#" -eq 0 ]; then
        echo "No packages provided for yay install"
        exit 1
    fi

    yay -S --noconfirm --needed "$@"
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

report_brave_vertical_tabs_status() {
    local preferences_file="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
    local vertical_tabs_enabled
    local vertical_tabs_collapsed
    local hide_when_collapsed

    if [ ! -f "$preferences_file" ]; then
        print_status "brave vertical tabs" "missing" "$preferences_file not present"
        return
    fi

    if ! command -v jq >/dev/null 2>&1; then
        print_status "brave vertical tabs" "unknown" "jq not installed"
        return
    fi

    vertical_tabs_enabled="$(jq -r 'if .brave.tabs.vertical_tabs_enabled == null then false else .brave.tabs.vertical_tabs_enabled end' "$preferences_file" 2>/dev/null || echo false)"
    vertical_tabs_collapsed="$(jq -r 'if .brave.tabs.vertical_tabs_collapsed == null then false else .brave.tabs.vertical_tabs_collapsed end' "$preferences_file" 2>/dev/null || echo false)"
    hide_when_collapsed="$(jq -r 'if .brave.tabs.vertical_tabs_hide_completely_when_collapsed == null then true else .brave.tabs.vertical_tabs_hide_completely_when_collapsed end' "$preferences_file" 2>/dev/null || echo true)"

    if [ "$vertical_tabs_enabled" = "true" ] &&
       [ "$vertical_tabs_collapsed" = "true" ] &&
       [ "$hide_when_collapsed" = "false" ]; then
        print_status "brave vertical tabs" "installed"
    else
        print_status "brave vertical tabs" "drifted" "$preferences_file"
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
    report_command_status jq

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
    report_brave_vertical_tabs_status

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

    step_total=$((1 + ${#SPECIAL_INSTALL_SCRIPTS[@]} + 3))

    if [ "$MODE" = "install" ] && is_macbook_host; then
        step_total=$((step_total + 1))
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        step_total=$((step_total + 1))
    fi

    if [ "$include_theme_hook" -eq 1 ]; then
        step_total=$((step_total + 1))
    fi

    echo "Setup mode: $MODE"
    echo "Detected host: $PRODUCT_NAME"
    echo

    run_step "Installing base yay packages" install_yay_packages "${YAY_PACKAGES[@]}"

    for package_script in "${SPECIAL_INSTALL_SCRIPTS[@]}"; do
        run_step "Running $package_script" run_script "$package_script"
    done
    run_step "Syncing shell-scripts repo and wrappers" run_script repos/install-repo-shell-scripts.sh
    run_step "Syncing dotfiles" run_script repos/install-dotfiles.sh
    run_step "Applying Brave preferences" run_script browsers/apply-brave-preferences.sh

    if [ "$MODE" = "install" ] && is_macbook_host; then
        run_step "Running MacBook hardware extras" run_script hardware/install-macbook-air.sh
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        run_step "Installing Hyprland source overrides" run_script install-hyprland-overrides.sh
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
