#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PURGE_DATA=0
MODE="all"

CLEANUP_SCRIPTS=(
    "cleanup/remove-hey-webapp.sh"
    "cleanup/remove-basecamp-webapp.sh"
    "cleanup/remove-fizzy-webapp.sh"
    "cleanup/remove-1password.sh"
    "cleanup/remove-signal-desktop.sh"
    "cleanup/remove-typora.sh"
)

step_index=0
step_total=0

run_script() {
    local script_path="$SCRIPT_DIR/$1"
    shift

    if [ ! -f "$script_path" ]; then
        echo "Missing cleanup script: $script_path"
        exit 1
    fi

    bash "$script_path" "$@"
}

run_step() {
    local label="$1"
    shift

    step_index=$((step_index + 1))
    printf '\n[%d/%d] %s\n' "$step_index" "$step_total" "$label"
    "$@"
}

script_args() {
    local script_name="$1"

    if [ "$PURGE_DATA" -ne 1 ]; then
        return
    fi

    case "$script_name" in
        cleanup/remove-1password.sh|cleanup/remove-signal-desktop.sh|cleanup/remove-typora.sh)
            printf '%s\n' "--purge-data"
            ;;
    esac
}

usage() {
    cat <<'EOF'
Usage: ./master-cleanup.sh [all] [--purge-data]

Runs the repo's cleanup scripts for unwanted Omarchy apps and packages.

Options:
  all           Run the full cleanup set (default)
  --purge-data  Pass data-purge flags to cleanup scripts that support it
  help|-h|--help
EOF
}

for arg in "$@"; do
    case "$arg" in
        all)
            MODE="all"
            ;;
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

case "$MODE" in
    all)
        step_total=${#CLEANUP_SCRIPTS[@]}
        ;;
    *)
        echo "Unknown cleanup mode: $MODE" >&2
        exit 1
        ;;
esac

echo "Cleanup mode: $MODE"
echo "Purge data: $(if [ "$PURGE_DATA" -eq 1 ]; then echo yes; else echo no; fi)"

for cleanup_script in "${CLEANUP_SCRIPTS[@]}"; do
    mapfile -t extra_args < <(script_args "$cleanup_script")
    run_step "Running $cleanup_script" run_script "$cleanup_script" "${extra_args[@]}"
done
