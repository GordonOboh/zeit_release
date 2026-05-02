#!/bin/bash
set -e  # Exit on any error

# ------------------------------------------------------------
# Build script for Zeit AppImage (Lubuntu/Ubuntu 22.04)
# ------------------------------------------------------------

echo "=== Installing build dependencies ==="
sudo apt update
sudo apt install -y build-essential cmake git wget \
    qtbase5-dev qttools5-dev qttools5-dev-tools \
    libkf5auth-dev libkf5coreaddons-dev extra-cmake-modules

# Install libcrontab0 (required for Zeit)
echo "=== Installing libcrontab0 ==="
wget -q https://mirror.koddos.net/mxlinux/mx/repo/pool/main/z/zeit/libcrontab0_0.5.97+git20210503-1~mx21+1_amd64.deb
sudo dpkg -i libcrontab0_0.5.97+git20210503-1~mx21+1_amd64.deb || sudo apt install -f -y
rm libcrontab0_*.deb

echo "=== Cloning Zeit source ==="
git clone https://github.com/loimu/zeit.git
cd zeit

echo "=== Downloading linuxdeploy tools ===""
wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
wget -q https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage

echo "=== Fixing .desktop file (in source) ==="
sed -i 's/Categories=.*/Categories=System;Utility;X-Scheduler;/' misc/applications/zeit.desktop
sed -i 's|Exec=/usr/bin/zeit|Exec=zeit|' misc/applications/zeit.desktop
sed -i 's/Icon=chronometer/Icon=zeit/' misc/applications/zeit.desktop

echo "=== Building Zeit ==="
mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j$(nproc)
make install DESTDIR=./AppDir

# Copy the fixed .desktop file and the icon into AppDir
cp ../misc/applications/zeit.desktop ./AppDir/
cp ../assets/zeit_256.png ./AppDir/zeit.png

# Ensure icon is also placed in standard hicolor path (optional but safe)
mkdir -p ./AppDir/usr/share/icons/hicolor/256x256/apps
cp ./AppDir/zeit.png ./AppDir/usr/share/icons/hicolor/256x256/apps/zeit.png

cd ..

echo "=== Creating AppImage ==="
./linuxdeploy-x86_64.AppImage --appdir build/AppDir \
    --desktop-file build/AppDir/zeit.desktop \
    --icon-file build/AppDir/zeit.png \
    --output appimage --plugin qt

echo "=== Copying result and cleaning up ==="
cp Zeit-*.AppImage ..
cd ..
rm -rf zeit/   # remove entire build folder
echo "Done! AppImage is in the current directory: $(ls Zeit-*.AppImage)"
