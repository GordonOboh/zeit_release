#!/bin/bash
# ============================================================
# WARNING: This script is UNTESTED on fresh Arch installations.
#          It may contain errors, missing dependencies, or
#          cause unexpected behavior.
#          RUN AT YOUR OWN RISK.
# ============================================================

# Force user to accept
echo
echo "**************************************************"
echo "⚠️  YOU ARE ABOUT TO RUN AN UNTESTED SCRIPT"
echo "**************************************************"
echo "This script will install packages, clone repositories,"
echo "and build an AppImage on your Arch Linux system."
echo
echo "By proceeding, you assume all responsibility for any"
echo "damage, data loss, or system instability."
echo
read -p "Type 'yes' (lowercase) to continue, or anything else to abort: " user_input

if [[ "$user_input" != "yes" ]]; then
    echo "Aborted by user."
    exit 1
fi

echo "Risk accepted. Continuing..."

set -e  # Exit on any error

# ------------------------------------------------------------
# Build Zeit AppImage on Arch Linux
# ------------------------------------------------------------

echo "=== Installing build dependencies (Arch) ==="
sudo pacman -S --needed --noconfirm base-devel cmake git wget \
    qt5-base qt5-tools kauth5 kcoreaddons5 extra-cmake-modules fuse2

# Create a clean build directory
BUILD_DIR="$HOME/zeit-appimage-build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "=== Cloning Zeit source ==="
git clone https://github.com/loimu/zeit.git
cd zeit

echo "=== Downloading linuxdeploy tools ==="
wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget -q https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage

echo "=== Fixing .desktop file (categories, exec, icon) ==="
# 1. Replace the Categories line with valid Freedesktop categories
sed -i 's/Categories=.*/Categories=System;Utility;X-Scheduler;/' misc/applications/zeit.desktop
# 2. Change Exec from absolute path to just 'zeit' (AppImage runtime will handle it)
sed -i 's|Exec=/usr/bin/zeit|Exec=zeit|' misc/applications/zeit.desktop
# 3. Use 'zeit' as the icon name (to match the actual icon file)
sed -i 's/Icon=chronometer/Icon=zeit/' misc/applications/zeit.desktop

echo "=== Building Zeit ==="
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)
make install DESTDIR=./AppDir

# Copy the fixed .desktop file and the high‑quality icon into AppDir
cp ../misc/applications/zeit.desktop ./AppDir/
cp ../assets/zeit_256.png ./AppDir/zeit.png

# Ensure icon is also placed in the standard hicolor path (belt and braces)
mkdir -p ./AppDir/usr/share/icons/hicolor/256x256/apps
cp ./AppDir/zeit.png ./AppDir/usr/share/icons/hicolor/256x256/apps/zeit.png

cd ..

echo "=== Creating AppImage (skipping strip to avoid .relr.dyn errors) ==="
NO_STRIP=1 ./linuxdeploy-x86_64.AppImage --appdir build/AppDir \
    --desktop-file build/AppDir/zeit.desktop \
    --icon-file build/AppDir/zeit.png \
    --output appimage --plugin qt

echo "=== AppImage created successfully ==="
ls -la Zeit-*.AppImage

# Copy the AppImage to the user's home directory for easy access
cp Zeit-*.AppImage "$HOME/Zeit.AppImage"
echo "AppImage also copied to $HOME/Zeit.AppImage"

# Optionally clean up the build directory (comment out if you want to keep it)
cd "$BUILD_DIR"
cd ..
rm -rf "$BUILD_DIR"
echo "Build directory removed."
