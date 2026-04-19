#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$HOME/.config/omarchy/hooks"
HOOK_FILE="$HOOKS_DIR/theme-set"
ORIGINAL_HOOK_FILE="$HOOKS_DIR/theme-set.original"
HELIX_UPDATER="$SCRIPT_DIR/update-helix-theme.sh"
MANAGED_MARKER="# managed by my-omarchy-setup"

mkdir -p "$HOOKS_DIR"

if [ -f "$HOOK_FILE" ] && ! grep -Fqx "$MANAGED_MARKER" "$HOOK_FILE"; then
  if [ -f "$ORIGINAL_HOOK_FILE" ]; then
    backup_file="$ORIGINAL_HOOK_FILE.$(date +%Y%m%d-%H%M%S).bak"
    mv "$ORIGINAL_HOOK_FILE" "$backup_file"
    printf 'Backed up previous preserved hook to %s\n' "$backup_file"
  fi

  mv "$HOOK_FILE" "$ORIGINAL_HOOK_FILE"
  chmod +x "$ORIGINAL_HOOK_FILE"
  printf 'Preserved existing Omarchy hook at %s\n' "$ORIGINAL_HOOK_FILE"
fi

cat > "$HOOK_FILE" <<EOF
#!/bin/bash

set -euo pipefail

$MANAGED_MARKER

if [ -x "$ORIGINAL_HOOK_FILE" ]; then
  "$ORIGINAL_HOOK_FILE" "\$@"
fi

"$HELIX_UPDATER" "\${1:-}"
EOF

chmod +x "$HOOK_FILE"

current_theme=""
if [ -f "$HOME/.config/omarchy/current/theme.name" ]; then
  current_theme="$(tr -d '\n' < "$HOME/.config/omarchy/current/theme.name")"
fi

"$HELIX_UPDATER" "$current_theme"

printf 'Installed Omarchy theme hook at %s\n' "$HOOK_FILE"
printf 'Current Omarchy theme: %s\n' "${current_theme:-dark}"
