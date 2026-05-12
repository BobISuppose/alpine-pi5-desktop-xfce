### **File 2: `install.sh`**
This is the "engine." I have added error handling and a "check" to make sure it's running on the correct architecture.

```bash
#!/bin/sh
# Alpine Pi 5 Desktop Installer - 2026 Edition
set -e

# --- 1. System Check ---
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

if [ "$(uname -m)" != "aarch64" ]; then
    echo "Error: This script is for aarch64 (ARM64) only."
    exit 1
fi

echo "--- Starting Alpine Pi 5 Setup ---"

# --- 2. Repository Setup ---
echo "Updating repositories to Edge for latest drivers..."
sed -i 's/v[0-9]\.[0-9]/edge/g' /etc/apk/repositories
apk update

# --- 3. Graphics & Hardware Support ---
echo "Installing Raspberry Pi 5 GPU drivers..."
apk add mesa-dri-gallium mesa-vulkan-broadcom xf86-video-fbdev \
    eudev dbus-x11 raspberrypi-utils mesa-v3d

# Ensure the Pi 5 V3D overlay is in the boot config
# Alpine usually mounts the boot partition to /boot or /media/mmcblk0p1
BOOT_PATH="/boot"
[ ! -f "$BOOT_PATH/usercfg.txt" ] && BOOT_PATH="/media/mmcblk0p1"

if [ -d "$BOOT_PATH" ]; then
    echo "Found boot partition at $BOOT_PATH. Applying overlays..."
    echo "dtoverlay=vc4-kms-v3d-pi5" >> "$BOOT_PATH/usercfg.txt"
    echo "dtparam=audio=on" >> "$BOOT_PATH/usercfg.txt"
else
    echo "Warning: Could not find boot partition. You must add 'dtoverlay=vc4-kms-v3d-pi5' manually."
fi

# --- 4. Desktop & Audio ---
echo "Installing XFCE, LightDM, and Pipewire..."
apk add xfce4 xfce4-terminal lightdm-gtk-greeter \
    pipewire pipewire-pulse alsa-plugins-pulse \
    adwaita-icon-theme ttf-dejavu

# --- 5. Minecraft Support (Flatpak) ---
echo "Setting up Minecraft compatibility (Flatpak)..."
apk add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# --- 6. Services Configuration ---
echo "Enabling background services..."
rc-update add udev boot
rc-update add dbus default
rc-update add lightdm default

# --- 7. User Creation ---
echo "--- Final Step: Create User ---"
read -p "Enter username for the new desktop user: " NEW_USER
adduser -D -G wheel,video,audio,input "$NEW_USER"
passwd "$NEW_USER"

echo "------------------------------------------------"
echo "Setup complete! Please reboot now."
echo "Once logged into the desktop, run:"
echo "flatpak install flathub org.prismlauncher.PrismLauncher"
echo "------------------------------------------------"
