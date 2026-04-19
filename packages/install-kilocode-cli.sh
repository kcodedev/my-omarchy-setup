#!/bin/bash

set -euo pipefail

PACKAGE_NAME="@kilocode/cli"
LOCAL_PREFIX="$HOME/.local"
NPM_PREFIX="$(npm config get prefix 2>/dev/null || true)"
UPGRADE_EXISTING="${BOOTSTRAP_UPGRADE:-0}"

if [ -n "$NPM_PREFIX" ] && [ -w "$NPM_PREFIX" ]; then
    TARGET_PREFIX="$NPM_PREFIX"
    INSTALL_ARGS=(-g)
else
    mkdir -p "$LOCAL_PREFIX"
    TARGET_PREFIX="$LOCAL_PREFIX"
    INSTALL_ARGS=(--prefix "$LOCAL_PREFIX" -g)
fi

if npm --prefix "$TARGET_PREFIX" list -g --depth=0 "$PACKAGE_NAME" >/dev/null 2>&1; then
    if [ "$UPGRADE_EXISTING" = "1" ]; then
        npm install "${INSTALL_ARGS[@]}" "$PACKAGE_NAME"
    else
        echo "npm package already installed: $PACKAGE_NAME"
    fi
else
    npm install "${INSTALL_ARGS[@]}" "$PACKAGE_NAME"
fi

if [ "$TARGET_PREFIX" = "$LOCAL_PREFIX" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *)
            echo "Warning: $HOME/.local/bin is not currently in PATH"
            ;;
    esac
fi
