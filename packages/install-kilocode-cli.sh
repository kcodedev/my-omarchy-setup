#!/bin/bash

set -euo pipefail

PACKAGE_NAME="@kilocode/cli"
LOCAL_PREFIX="$HOME/.local"
NPM_PREFIX="$(npm config get prefix 2>/dev/null || true)"

if [ -n "$NPM_PREFIX" ] && [ -w "$NPM_PREFIX" ]; then
    npm install -g "$PACKAGE_NAME"
else
    mkdir -p "$LOCAL_PREFIX"
    npm install --prefix "$LOCAL_PREFIX" -g "$PACKAGE_NAME"

    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *)
            echo "Warning: $HOME/.local/bin is not currently in PATH"
            ;;
    esac
fi
