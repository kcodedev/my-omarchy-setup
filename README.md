# Omarchy Setup

This repository contains installation scripts for setting up an Arch Linux environment with various tools and configurations.

## Structure

- `packages/` - Scripts for installing system packages via yay (AUR helper)
- `repos/` - Scripts for cloning and setting up personal repositories
- `hardware/` - Hardware-specific installation scripts (e.g., for MacBook Air)
- `master-installation.sh` - Main script that runs all installations in order
- `install-hyprland-overrides.sh` - Script to configure Hyprland window manager overrides

## Hyprland Overrides

Hyprland uses a single main configuration file located at `~/.config/hypr/hyprland.conf`. To implement overrides, the system sources additional configuration files into this main file using the `source` directive. This allows modular configuration where custom settings can be added without directly modifying the base Hyprland config.

In this setup:
- The [`hyprland-overrides.conf`](hyprland-overrides.conf) file contains custom key bindings and unbindings, such as launching shell scripts with specific key combinations (e.g., `SUPER SHIFT, P` for project launcher) and overriding default bindings (e.g., unbinding `SUPER SHIFT, W` and rebinding it to restart iWD).
- The [`install-hyprland-overrides.sh`](install-hyprland-overrides.sh) script appends a `source` line to the main `hyprland.conf` file, pointing to the overrides file. This ensures the overrides are loaded when Hyprland starts.

When Hyprland reads its config, it processes the `source` directive, merging the contents of the overrides file into the configuration. This approach keeps the base config clean while allowing easy customization and updates to overrides.

## Usage

1. Clone this repository
2. Make scripts executable: `chmod +x *.sh */*.sh`
3. Run the master installation: `./master-installation.sh`
4. For hardware-specific setups (e.g., MacBook Air), run the appropriate script manually: `./hardware/install-macbook-air.sh`

## Prerequisites

- Arch Linux with yay installed
- Git configured for SSH access to private repos

## Notes

- Scripts check for existing installations to avoid duplicates
- Hardware-specific scripts include detection to prevent running on incompatible systems
- Reboot recommended after installing kernel modules (e.g., FacetimeHD)