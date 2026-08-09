#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODE="${1:-install}"
PRODUCT_NAME="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")"

YAY_PACKAGES=(
    jq
    chezmoi
    helix
    keepassxc
    brave-bin
    tmux
    kitty
    visual-studio-code-bin
    cursor-bin
    yazi
    localsend
    obsidian
    dbeaver
    dropbox-cli
    cava
    lazygit
    nodejs
    npm
    glow
    bash-language-server
    models-bin
    railwayapp-cli
)

SPECIAL_INSTALL_SCRIPTS=(
    "packages/install-pipx.sh"
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
    [ -f "$HOME/.config/hypr/hyprland.lua" ]
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

report_brave_extension_policy_status() {
    local policy_file="/etc/brave/policies/managed/extensions.json"
    local vimium_policy="dbepggeogbaibhgnhhndojpepiihcmeb;https://clients2.google.com/service/update2/crx"

    if [ ! -f "$policy_file" ]; then
        print_status "brave extensions" "missing" "$policy_file not present"
        return
    fi

    if ! command -v jq >/dev/null 2>&1; then
        print_status "brave extensions" "unknown" "jq not installed"
        return
    fi

    if jq -e --arg vimium_policy "$vimium_policy" \
        '.ExtensionInstallForcelist // [] | index($vimium_policy)' \
        "$policy_file" >/dev/null 2>&1; then
        print_status "brave extensions" "installed" "Vimium"
    else
        print_status "brave extensions" "drifted" "$policy_file"
    fi
}

report_helix_theme_mapping_status() {
    local config_file="$HOME/.config/helix/config.toml"
    local omarchy_theme_file="$HOME/.config/helix/themes/omarchy.toml"
    local mappings_file="$SCRIPT_DIR/theme-changer/hx-theme-mappings.txt"
    local mapped_total=0
    local mapped_installed=0
    local theme_name

    if ! has_omarchy_install; then
        print_status "helix theme map" "skipped" "~/.config/omarchy not present"
        return
    fi

    if [ -f "$config_file" ] && grep -Eq '^[[:space:]]*theme[[:space:]]*=[[:space:]]*"omarchy"' "$config_file"; then
        print_status "helix theme" "installed" "theme = omarchy"
    else
        print_status "helix theme" "drifted" "$config_file"
    fi

    if [ -L "$omarchy_theme_file" ] &&
       [ "$(readlink -f "$omarchy_theme_file")" = "$HOME/.local/state/omarchy/current/theme/helix.toml" ]; then
        print_status "helix omarchy link" "installed"
    else
        print_status "helix omarchy link" "drifted" "$omarchy_theme_file"
    fi

    if [ ! -f "$mappings_file" ]; then
        print_status "helix theme map" "missing" "$mappings_file"
        return
    fi

    while IFS='=' read -r theme_name _; do
        [[ $theme_name =~ ^[[:space:]]*# ]] && continue
        [[ -z $theme_name ]] && continue

        mapped_total=$((mapped_total + 1))
        if [ -f "$HOME/.config/omarchy/themes/$theme_name/helix.toml" ]; then
            mapped_installed=$((mapped_installed + 1))
        fi
    done <"$mappings_file"

    if [ "$mapped_total" -gt 0 ] && [ "$mapped_installed" -eq "$mapped_total" ]; then
        print_status "helix theme map" "installed" "$mapped_installed/$mapped_total overlays"
    else
        print_status "helix theme map" "drifted" "$mapped_installed/$mapped_total overlays"
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
    report_command_status chezmoi
    report_command_status npm
    report_command_status pipx
    report_command_status jq

    if has_local_bin_on_path; then
        print_status "PATH ~/.local/bin" "ok"
    else
        print_status "PATH ~/.local/bin" "missing"
    fi

    report_repo_status "chezmoi source" "$HOME/.local/share/chezmoi"
    report_repo_status "shell-scripts repo" "$HOME/Repos/shell-scripts"

    report_source_line_status \
        "hypr lua bootstrap" \
        "$HOME/.config/hypr/hyprland.lua" \
        'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")'
    report_source_line_status \
        "hypr monitors lua" \
        "$HOME/.config/hypr/hyprland.lua" \
        'require("hypr.monitors")'
    report_source_line_status \
        "hypr input lua" \
        "$HOME/.config/hypr/hyprland.lua" \
        'require("hypr.input")'
    report_source_line_status \
        "hypr bindings lua" \
        "$HOME/.config/hypr/hyprland.lua" \
        'require("hypr.bindings")'
    report_source_line_status \
        "hypr looknfeel lua" \
        "$HOME/.config/hypr/hyprland.lua" \
        'require("hypr.looknfeel")'
    report_brave_vertical_tabs_status
    report_brave_extension_policy_status
    report_helix_theme_mapping_status
}

perform_install() {
    local include_hyprland_steps=0
    local include_helix_theme_mapping=0

    require_command yay
    require_command git

    if has_hyprland_config; then
        include_hyprland_steps=1
    fi

    if has_omarchy_install; then
        include_helix_theme_mapping=1
    fi

    step_total=$((1 + ${#SPECIAL_INSTALL_SCRIPTS[@]} + 4))

    if [ "$MODE" = "install" ] && is_macbook_host; then
        step_total=$((step_total + 1))
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        step_total=$((step_total + 1))
    fi

    if [ "$include_helix_theme_mapping" -eq 1 ]; then
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
    if [ "$include_helix_theme_mapping" -eq 1 ]; then
        run_step "Installing Omarchy Helix theme mappings" run_script theme-changer/install-omarchy-helix-theme-mapping.sh
    else
        echo
        echo "[skip] Omarchy config not present; skipping Helix theme mappings"
    fi
    run_step "Applying Brave preferences" run_script browsers/apply-brave-preferences.sh
    run_step "Applying Brave managed policies" run_script browsers/apply-brave-policies.sh

    if [ "$MODE" = "install" ] && is_macbook_host; then
        run_step "Running MacBook hardware extras" run_script hardware/install-macbook-air.sh
    fi

    if [ "$include_hyprland_steps" -eq 1 ]; then
        run_step "Validating Hyprland Lua configuration" run_script install-hyprland-overrides.sh
    else
        echo
        echo "[skip] Hyprland config not present; skipping Hyprland-specific steps"
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
