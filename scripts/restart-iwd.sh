#!/bin/bash

# Restart iwd service
pkexec systemctl restart iwd

# Optional: Notify user
notify-send "iwd restarted" "Wireless daemon has been restarted."