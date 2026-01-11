# Omarchy Setup

This repository contains installation scripts for setting up an Arch Linux environment with various tools and configurations.

## Structure

- `packages/` - Scripts for installing system packages via yay (AUR helper)
- `repos/` - Scripts for cloning and setting up personal repositories
- `hardware/` - Hardware-specific installation scripts (e.g., for MacBook Air)
- `master-installation.sh` - Main script that runs all installations in order
- `install-hyprland-overrides.sh` - Script to configure Hyprland window manager overrides

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