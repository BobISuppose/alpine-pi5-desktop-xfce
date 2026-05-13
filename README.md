# Alpine Pi 5 Desktop Installer

An automated, high-performance bootstrap script to transform a minimal Alpine Linux installation into a fully accelerated XFCE desktop environment specifically optimized for the **Raspberry Pi 5 (BCM2712)** architecture.

## Features
- **Kernel and ARM Optimization:** linux-rpi optimized for BCM2712. The script utilizes the linux-rpi kernel package. Unlike the generic linux-lts, this kernel includes downstream patches from the Raspberry Pi Foundation, critical for managing the Pi 5's 16KB page size and the RP1 I/O controller. Musl Standard Library. Alpine’s use of musl libc instead of glibc results in a significantly reduced binary footprint and faster execution times. However, this creates challenges for proprietary software, which is addressed via the Flatpak layer.
- **GPU Acceleration:** Configures V3D drivers for the BCM2712. Vulkan 1.2: Installed via mesa-vulkan-broadcom for modern shader processing.
- **Desktop:** Installs XFCE4 + LightDM. Ultra-ightweight, uses <200MB of RAM as of May 2026. Alpine uses OpenRC rather than systemd. This provides a deterministic, dependency-based boot sequence. The script registers dbus, udev, and lightdm into the default runlevel to ensure a seamless "graphical boot." By avoiding the "monolithic" bloat of modern environments, an idle XFCE instance on this build consumes < 250MB RAM, leaving maximum overhead for heavy applications.
- **Audio:** Modern Pipewire stack. Handles HDMI and Bluetooth audio out of the box. Using wireplumber, the system handles dynamic hardware events (like plugging in HDMI audio or Bluetooth headsets) without requiring a manual restart of the audio daemon. pipewire-pulse and alsa-plugins are included to provide a transparent bridge for legacy applications.
- **Gaming:** Pre-configures Flatpak & Prism Launcher for Minecraft. This is the Flatpak based prism launcher bypassing the common glibc/musl compatibility issues. Most Linux games (including Minecraft) are compiled against glibc and are often distributed for x86_64 architectures. Flatpaks bundle their own glibc runtime, allowing software to run on a musl host without library conflicts. Prism Launcher: Specifically chosen for its ability to pull native aarch64 Java builds. This allows Minecraft to run with near-zero virtualization overhead on the ARM8v8 instruction set.

## 🚀 Quick Start (Beginners)

1. **Flash:** Use Raspberry Pi Imager to flash **Alpine Linux (aarch64)** to your SD card.
2. **Boot:** Power on your Pi 5 and log in as `root`.
3. **Connect:** Run `setup-alpine` to configure Wi-Fi and disk (choose `sys` mode).
4. **Execute:**

   ```bash
   apk add git
   git clone https://github.com/BobISuppose/alpine-pi5-desktop-xfce.git
   cd alpine-pi5-desktop
   chmod +x install.sh
   ./install.sh
   ```
