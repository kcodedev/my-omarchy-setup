#!/bin/bash

# Check if running on MacBook hardware
PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
if [[ $PRODUCT_NAME != *"MacBook"* ]]; then
    echo "This script is intended for MacBook hardware. Detected: $PRODUCT_NAME"
    exit 1
fi

echo "Installing MacBook Air specific packages..."

# Install FacetimeHD camera driver
yay -S --noconfirm --needed facetimehd-dkms

# Install SPI driver for keyboard backlight and touchpad support
yay -S --noconfirm --needed macbook12-spi-driver-dkms

# Optional: Install brightness control tools
yay -S --noconfirm --needed brightnessctl

# Rebuild initramfs for DKMS modules
sudo mkinitcpio -P

echo "MacBook Air specific installation complete. Reboot recommended."