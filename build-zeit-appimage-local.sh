#!/bin/bash
set -e  # Exit on error

# ------------------------------------------------------------
# Build Zeit AppImage from an existing local source directory
# Run this script from the root of the 'zeit' source tree.
# ------------------------------------------------------------

# Check that we are in the correct directory
if [ ! -f "CMakeLists.txt" ] || [ ! -d "misc/applications" ]; then
    echo "ERROR: Please run this script from the root of the 'zeit' source directory."
    echo "Expected to find CMakeLists.txt and misc/applications/zeit.desktop"
    exit 1
fi

echo "=== Installing build dependencies (if missing) ==="
sudo apt update
sudo apt install -y build-essential cmake wget \
    qtbase5-dev qttools5-dev qttools5-dev-tools \
    libkf5auth-dev libkf5coreaddons-dev extra-cmake-modules

# libcrontab0 is required; if not installed, try to install it
if ! dpkg -l | grep -q libcrontab0; then
    echo "=== Installing libcrontab0 (required for Zeit) ==="
    wget -q https://mirror.koddos.net/mxlinux/mx/repo/pool/main/z/zeit/libcrontab0_0.5.97+git20210503-1~mx21+1_amd64.deb
    sudo dpkg -i libcrontab0_*.deb || sudo apt install -f -y
    rm libcrontab0_*.deb
else
    echo "libcrontab0 is already installed."
fi

# Download linuxdeploy tools if not already present
if [ ! -f "linuxdeploy-x86_64.AppImage" ]; then
    echo "=== Downloading linuxdeploy ==="
    wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
    chmod +x linuxdeploy-x86_64.AppImage
fi
if [ ! -f "linuxdeploy-plugin-qt-x86_64.AppImage" ]; then
    echo "=== Downloading linuxdeploy Qt plugin ==="
    wget -q https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
    chmod +x linuxdeploy-plugin-qt-x86_64.AppImage
fi

echo "=== Fixing .desktop file (in place) ==="
sed -i 's/Categories=.*/Categories=System;Utility;X-Scheduler;/' misc/applications/zeit.desktop
sed -i 's|Exec=/usr/bin/zeit|Exec=zeit|' misc/applications/zeit.desktop
sed -i 's/Icon=chronometer/Icon=zeit/' misc/applications/zeit.desktop

echo "=== Cleaning previous build (if any) ==="
rm -rf build

echo "=== Building Zeit ==="
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)
make install DESTDIR=./AppDir

# Copy the fixed .desktop file and icon into AppDir
cp ../misc/applications/zeit.desktop ./AppDir/
cp ../assets/zeit_256.png ./AppDir/zeit.png

# Ensure icon is also placed in standard hicolor path (belt and braces)
mkdir -p ./AppDir/usr/share/icons/hicolor/256x256/apps
cp ./AppDir/zeit.png ./AppDir/usr/share/icons/hicolor/256x256/apps/zeit.png

cd ..

echo "=== Creating AppImage ==="
./linuxdeploy-x86_64.AppImage --appdir build/AppDir \
    --desktop-file build/AppDir/zeit.desktop \
    --icon-file build/AppDir/zeit.png \
    --output appimage --plugin qt

echo "=== AppImage created ==="
ls -la Zeit-*.AppImage

# Optional: move the AppImage to parent directory
cp Zeit-*.AppImage ..
echo "AppImage also copied to $(dirname $(pwd))/Zeit-*.AppImage"
