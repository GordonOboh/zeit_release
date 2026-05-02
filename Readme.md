# Zeit project
 Qt frontend to `crontab` and `at`
Arch User can check here; [https://aur.archlinux.org/packages/zeit-git](https://aur.archlinux.org/packages/zeit-git)
### Appimage Build ###
Appimage build script was tested on Lubuntu 22.04.2 LTS vm
```bash
sudo apt install curl -y
bash -c "$(curl -fsSL https://raw.githubusercontent.com/GordonOboh/zeit_release/master/build-zeit-appimage.sh)"
```
or

```bash
wget https://raw.githubusercontent.com/GordonOboh/zeit_release/master/build-zeit-appimage.sh
chmod +x build-zeit-appimage.sh
./build-zeit-appimage.sh
```
or

```bash
git clone https://github.com/GordonOboh/zeit_release.git
cd zeit_release/
chmod +x build-zeit-appimage-local.sh
./build-zeit-appimage-local.sh
```

### Features: ###
* Add, edit and delete `crontab` tasks
* Add, edit and delete environment variables for `crontab`
* Add and delete `at` commands
* Alarms and Timers
* Optional root actions, PolKit support (KF5Auth and KF5CoreAddons needed)

### Build dependencies ###
Extra CMake Modules, QtBase, QtTools, KF5Auth (optional), KF5CoreAddons (optional)

```bash
sudo apt install qtbase5-dev qttools5-dev libkf5auth-dev libkf5coreaddons-dev extra-cmake-modules
```

### Runtime dependencies ###
libnotify-bin, mpv

### Build and run ###
```bash
mkdir build && cd build
cmake ..
make -j2
./src/zeit
```

### Screenshot ###
![Screenshot of the Zeit app](https://raw.githubusercontent.com/loimu/zeit/master/assets/screenshot.png)

### Installation on Ubuntu ###
```bash
# stable releases
sudo add-apt-repository ppa:blaze/main
sudo apt update
sudo apt install zeit

# development snapshots
sudo add-apt-repository ppa:blaze/dev
sudo apt update
sudo apt install zeit
```
