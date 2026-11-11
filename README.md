# Omarchy Setup

Personal Omarchy bootstrap, dotfiles, plugins, and cleanup scripts.

## Usage

Requires Arch Linux with `yay` and Git SSH access to private repositories.
Clone this repository, then run:

```bash
./master-installation.sh install  # Bootstrap a machine
./master-installation.sh sync     # Update repos, plugins, and dotfiles
./master-installation.sh doctor   # Check machine state without changes
./master-cleanup.sh               # Remove unwanted apps, keeping user data
./master-cleanup.sh --purge-data  # Also remove data where supported
```

`sync` uses fast-forward-only pulls and skips checkouts with local changes.
Install and sync also reapply Brave preferences and managed policies.
Keep `~/.local/bin` on `PATH` for npm's user-local install fallback.

## Structure

- `browsers/` - Browser-specific preference bootstrap scripts
- `cleanup/` - Explicit cleanup and removal scripts for one-off maintenance tasks
- `repos/` - Scripts for cloning personal repositories and setting up the Urchin keyboard
- `plugins/` - Idempotent installers for preferred Omarchy shell plugins
- `master-installation.sh` - Install, sync, and machine checks
- `master-cleanup.sh` - Run all cleanup scripts
- `install-hyprland-overrides.sh` - Validates Omarchy 4's Hyprland Lua entrypoint and user-module imports

## Hyprland Personal Config

Omarchy 4 loads defaults and personal Lua modules through
`~/.config/hypr/hyprland.lua`. Manage personal settings with chezmoi:

- `dot_config/hypr/bindings.lua` for `hl.unbind(...)` and `o.bind(...)` calls
- `dot_config/hypr/monitors.lua` for `hl.env(...)` and `hl.monitor(...)` calls
- `dot_config/hypr/input.lua` for `hl.config({ input = ... })`
- `dot_config/hypr/looknfeel.lua` for gaps, borders, and animation settings
- `dot_config/hypr/autostart.lua` for startup commands
- `dot_config/hypr/hyprland.lua` only when the stock Omarchy entrypoint itself needs changing

Legacy `.conf` fragments are not loaded. The
[`install-hyprland-overrides.sh`](install-hyprland-overrides.sh) script checks
Lua imports and live session errors. Hyprland steps skip when the Lua entrypoint
is absent.

## Quickshell

Omarchy 4 uses Quickshell instead of Waybar and Walker. Manage bar layout and
widget settings in `~/.config/omarchy/shell.json` through chezmoi; personal
plugins live in `~/.config/omarchy/plugins/`. Waybar config has no effect.

Common Waybar migrations are:

- `mpris` -> add `{ "id": "omarchy.media" }` to a `bar.layout` section
- workspace numbers -> the built-in `{ "id": "omarchy.workspaces" }`
- custom workspace icons -> clone `omarchy.workspaces` and customize the user-owned QML plugin
- battery percentage -> use the `omarchy.power` widget (right-click toggles percentage)
- launcher refresh -> no Walker restart; Quickshell watches desktop entries

### Preferred Omarchy Plugins

[`plugins/install-omarchy-plugins.sh`](plugins/install-omarchy-plugins.sh) installs
or updates plugins on each `install` and `sync`. Add sources to
[`plugins/omarchy-plugins.txt`](plugins/omarchy-plugins.txt) and layout entries
to the chezmoi-managed `shell.json`.

- [Radio Atlas](https://github.com/AksharP5/omarchy-radio-atlas) - provides the Radio Atlas bar widget

## Urchin Keyboard

Urchin firmware lives at `~/Repos/zmk-urchin-kcodedev`. The `kcodedev.urchin`
plugin is installed and enabled after chezmoi applies `shell.json`, which owns
its placement and settings.

Local ZMK builds require Docker. `doctor` checks for it; setup does not install it.

The repository sources and firmware destination can be overridden for a
one-off run:

```bash
URCHIN_ZMK_REPO_URL=git@github.com:example/zmk-urchin.git \
URCHIN_ZMK_REPO_DIR="$HOME/Repos/zmk-urchin" \
URCHIN_OMARCHY_PLUGIN_URL=https://github.com/example/urchin-plugin.git \
./master-installation.sh sync
```

## Dotfiles

Chezmoi applies dotfiles from `~/.local/share/chezmoi`, using this repository:

```bash
git@github.com:kcodedev/dotfiles-chezmoi.git
```

Override it for a one-off run with:

```bash
CHEZMOI_DOTFILES_REPO_URL=git@github.com:kcodedev/other-dotfiles.git ./master-installation.sh sync
```

Keep config shared across `dell-7430`, `acer-revo-mini-pc`, and `macbook-air-2015`;
prefer plain files over host-specific templates. Omarchy handles hardware drivers
and MacBook support.

## Cleanup

Cleanup runs separately from install/sync. It removes apps including LibreOffice,
Spotify, Zed, Cursor, and DBeaver while preserving settings and user data by default.
[`cleanup/remove-helix.sh`](cleanup/remove-helix.sh) also removes Helix theme
overlays and the old `hx` alias; `--purge-data` removes its editor config too.
