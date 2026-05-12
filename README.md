# alpine-pi5-desktop-xfce
Simple script to include a lightweight desktop environment, gaming drivers, and flatpack. Keep things minimal

# Alpine Pi 5 Desktop Installer

An automated script to turn a minimal Alpine Linux (aarch64) installation into a full XFCE desktop optimized for the Raspberry Pi 5.

## Features
- **GPU Acceleration:** Configures V3D drivers for the BCM2712.
- **Desktop:** Installs XFCE4 + LightDM.
- **Audio:** Modern Pipewire stack.
- **Gaming:** Pre-configures Flatpak & Prism Launcher for Minecraft.

## Usage
1. Install Alpine Linux (aarch64) on your Pi 5.
2. Log in as `root`.
3. Run the following:

```bash
apk add git
git clone [https://github.com/BobISuppose/alpine-pi5-desktop.git](https://github.com/BobISuppose/alpine-pi5-desktop.git)
cd alpine-pi5-desktop
chmod +x install.sh
./install.sh
