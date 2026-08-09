# Omarchy Setup

This repository contains installation scripts for setting up an Arch Linux environment with various tools and configurations.

## Structure

- `packages/` - Special-case package installers; plain `yay` packages are declared in `master-installation.sh`
- `browsers/` - Browser-specific preference bootstrap scripts
- `cleanup/` - Explicit cleanup and removal scripts for one-off maintenance tasks
- `repos/` - Scripts for cloning and setting up personal repositories
- `hardware/` - Hardware-specific installation scripts (e.g., for MacBook Air)
- `master-installation.sh` - Main script that runs all installations in order
- `master-cleanup.sh` - Main script that runs the repo cleanup scripts in one pass
- `install-hyprland-overrides.sh` - Validates Omarchy 4's Hyprland Lua entrypoint and user-module imports

## Hyprland Personal Config

Omarchy 4 configures Hyprland in Lua. The active entrypoint is
`~/.config/hypr/hyprland.lua`, which loads Omarchy's defaults followed by these
user-owned modules:

```lua
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
```

Personal Hyprland settings belong in the corresponding `.lua` files under
`~/.config/hypr/`. The chezmoi source repository must therefore manage:

- `dot_config/hypr/bindings.lua` for `hl.unbind(...)` and `o.bind(...)` calls
- `dot_config/hypr/monitors.lua` for `hl.env(...)` and `hl.monitor(...)` calls
- `dot_config/hypr/input.lua` for `hl.config({ input = ... })`
- `dot_config/hypr/looknfeel.lua` for gaps, borders, and animation settings
- `dot_config/hypr/hyprland.lua` only when the stock Omarchy entrypoint itself needs changing

Legacy `personal.conf`, `common.conf`, and host `.conf` fragments are not loaded
by the Lua entrypoint. The [`install-hyprland-overrides.sh`](install-hyprland-overrides.sh)
script verifies the Lua bootstrap/imports and checks a live Hyprland session for
configuration errors; it no longer edits the inactive `.conf` stub.

## Quickshell

Omarchy 4 replaced Waybar and Walker with the Omarchy shell built on Quickshell.
Bar layout and built-in widgets are configured by
`~/.config/omarchy/shell.json`; personal plugin code belongs under
`~/.config/omarchy/plugins/`. A chezmoi-managed `dot_config/waybar/` directory
has no effect on the Omarchy 4 bar.

Common Waybar migrations are:

- `mpris` -> add `{ "id": "omarchy.media" }` to a `bar.layout` section
- workspace numbers -> the built-in `{ "id": "omarchy.workspaces" }`
- custom workspace icons -> clone `omarchy.workspaces` and customize the user-owned QML plugin
- battery percentage -> use the `omarchy.power` widget (right-click toggles percentage)
- launcher refresh -> no Walker restart; Quickshell watches desktop entries

## Usage

1. Clone this repository
2. Run a full machine bootstrap: `./master-installation.sh install`
3. Re-sync an existing machine after repo changes: `./master-installation.sh sync`
4. Inspect the current machine state without changing anything: `./master-installation.sh doctor`
5. Upgrade already-installed npm and pipx tools during a sync: `BOOTSTRAP_UPGRADE=1 ./master-installation.sh sync`
6. Remove unwanted Omarchy apps in one pass: `./master-cleanup.sh`
7. Also purge app data for supported cleanup scripts: `./master-cleanup.sh --purge-data`

## Dotfiles

Dotfiles are managed with chezmoi. The default source repository is:

```bash
git@github.com:kcodedev/dotfiles-chezmoi.git
```

Override it for a one-off run with:

```bash
CHEZMOI_DOTFILES_REPO_URL=git@github.com:kcodedev/other-dotfiles.git ./master-installation.sh sync
```

The intended setup is identical config across `dell-7430`, `acer-revo-mini-pc`, and
`macbook-air-2015`, so the first chezmoi repo should stay mostly plain files rather
than host-specific templates.

## Prerequisites

- Arch Linux with yay installed
- Git configured for SSH access to private repos
- `~/.local/bin` on your `PATH` if you want npm global installs to fall back to a user-local prefix

## Notes

- `install` auto-detects MacBook hardware and runs the hardware extras for that host
- `sync` updates existing repos with `git pull --ff-only` when they are clean, and skips pulling if you have local changes
- `sync` applies dotfiles with chezmoi from `~/.local/share/chezmoi`
- Brave preferences and managed policies are re-applied during install/sync for repo-managed defaults such as vertical tabs and force-installed extensions
- `doctor` reports command availability, repo state, Hyprland Lua module status, and Omarchy hook status
- `master-cleanup.sh` runs the repo cleanup scripts without mixing removals into install/sync
- Hyprland-specific steps skip cleanly when `~/.config/hypr/hyprland.lua` is not present
- npm and pipx tools are only upgraded when `BOOTSTRAP_UPGRADE=1` is set
- Hardware-specific scripts include detection to prevent running on incompatible systems
- Reboot recommended after installing kernel modules (e.g., FacetimeHD)
