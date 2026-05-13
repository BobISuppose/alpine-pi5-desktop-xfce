#!/bin/sh
# Alpine Pi 5 NVMe Desktop Installer - 2026 Edition
set -e

# --- 1. System & Architecture Check ---
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

if [ "$(uname -m)" != "aarch64" ]; then
    echo "Error: This script is for aarch64 (ARM64) only."
    exit 1
fi

echo "--- [1/6] Preparing Repositories (Edge) ---"
# Moving to Edge ensures you have Mesa 26+ for the Pi 5 GPU
sed -i 's/v[0-9]\.[0-9]/edge/g' /etc/apk/repositories
apk update

echo "--- [2/6] Installing Essential Packages ---"
# Added nvme-cli and lsblk specifically for your hardware
apk add mesa-dri-gallium mesa-vulkan-broadcom xf86-video-fbdev \
    eudev dbus-x11 raspberrypi-utils mesa-v3d nvme-cli lsblk

echo "--- [3/6] NVMe Boot Configuration ---"
# Logic to find the NVMe boot partition
BOOT_PART="/dev/nvme0n1p1"
BOOT_MNT="/boot"

if [ -b "$BOOT_PART" ]; then
    echo "NVMe boot partition detected at $BOOT_PART."
    # Check if already mounted, if not, mount it
    if ! mount | grep -q "$BOOT_MNT"; then
        mount "$BOOT_PART" "$BOOT_MNT" || echo "Note: /boot might be mounted elsewhere."
    fi
    
    # Apply Pi 5 overlays to the NVMe boot config
    if [ -f "$BOOT_MNT/usercfg.txt" ] || [ -f "$BOOT_MNT/config.txt" ]; then
        TARGET_FILE="$BOOT_MNT/usercfg.txt"
        [ ! -f "$TARGET_FILE" ] && TARGET_FILE="$BOOT_MNT/config.txt"
        
        echo "Updating $TARGET_FILE with Pi 5 GPU overlays..."
        echo "dtoverlay=vc4-kms-v3d-pi5" >> "$TARGET_FILE"
        echo "dtparam=audio=on" >> "$TARGET_FILE"
        # NVMe Power/Speed tweak for Pi 5
        echo "dtparam=pciex1_gen=3" >> "$TARGET_FILE"
    fi
else
    echo "Warning: NVMe boot partition not found at $BOOT_PART. Please check your mount points."
fi

echo "--- [4/6] Installing XFCE Desktop & Audio ---"
apk add xfce4 xfce4-terminal lightdm-gtk-greeter \
    pipewire pipewire-pulse alsa-plugins-pulse \
    adwaita-icon-theme ttf-dejavu

echo "--- [5/6] Setting up Services & Flatpak ---"
apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

rc-update add udev boot
rc-update add dbus default
rc-update add lightdm default

echo "--- [6/6] Finalizing User Account ---"
read -p "Enter username for the new desktop user: " NEW_USER
adduser -D -G wheel,video,audio,input "$NEW_USER"
passwd "$NEW_USER"

echo "------------------------------------------------"
echo "NVMe Setup complete! Your Pi 5 is ready."
echo "Hardware identified: $(nvme list | grep 'nvme0n1' | awk '{print $3}')"
echo "Please reboot to enter your XFCE Desktop."
echo "------------------------------------------------"
