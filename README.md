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
- `install-hyprland-overrides.sh` - Script to source chezmoi-managed personal Hyprland config from Omarchy's `hyprland.conf`

## Hyprland Personal Config

Hyprland uses a single main configuration file at `~/.config/hypr/hyprland.conf`. Omarchy owns that file, so this setup keeps the Omarchy file intact and only ensures it contains one stable personal source line:

```conf
source = ~/.config/hypr/personal.conf
```

Chezmoi manages the personal fragments from `~/.local/share/chezmoi`:

- `dot_config/hypr/personal.conf.tmpl` always sources `common.conf` and chooses host-specific fragments by hostname.
- `dot_config/hypr/common.conf` contains shared bindings, window rules, gaps, borders, and animation preferences.
- `dot_config/hypr/laptop.conf` contains laptop monitor, scaling, and touchpad input settings.
- `dot_config/hypr/desktop.conf` is reserved for desktop monitor and input assumptions.

The [`install-hyprland-overrides.sh`](install-hyprland-overrides.sh) script removes legacy setup-repo override source lines and adds the single `personal.conf` line if needed. The old setup-repo override files are no longer sourced directly.

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
- Brave preferences are re-applied during install/sync for repo-managed defaults such as vertical tabs
- `doctor` reports command availability, repo state, Hyprland personal config status, and Omarchy hook status
- `master-cleanup.sh` runs the repo cleanup scripts without mixing removals into install/sync
- Hyprland-specific steps now skip cleanly when `~/.config/hypr/hyprland.conf` is not present
- npm and pipx tools are only upgraded when `BOOTSTRAP_UPGRADE=1` is set
- Hardware-specific scripts include detection to prevent running on incompatible systems
- Reboot recommended after installing kernel modules (e.g., FacetimeHD)
