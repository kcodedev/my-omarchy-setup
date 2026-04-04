#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$HOME/.config/omarchy/hooks"
HOOK_FILE="$HOOKS_DIR/theme-set"
HELIX_UPDATER="$SCRIPT_DIR/update-helix-theme.sh"

mkdir -p "$HOOKS_DIR"

cat > "$HOOK_FILE" <<EOF
#!/bin/bash

set -euo pipefail

"$HELIX_UPDATER" "\${1:-}"
EOF

chmod +x "$HOOK_FILE"

current_theme=""
if [ -f "$HOME/.config/omarchy/current/theme.name" ]; then
  current_theme="$(tr -d '\n' < "$HOME/.config/omarchy/current/theme.name")"
fi

"$HELIX_UPDATER" "$current_theme"

printf 'Installed Omarchy theme hook at %s\n' "$HOOK_FILE"
