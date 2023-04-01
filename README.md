# makemkv-appimage
This repository is for building AppImages of MakeMKV for Linux.
The AppImage is built in an Ubuntu 18.04 based image, so it should run on any Ubuntu distribution that is the same or newer.
It is confirmed to work on 22.04.
As of now, only x86_64 processor architecture is supported.
Pre-built AppImages can be downloaded from the releases, but they can also be built using the repository code.

# Using makemkv-appimage
To use the build system, docker and bash need to be available.
Installation on Ubuntu:
```
sudo apt-get install -y docker.io
```
Then the build script needs to be executed.
```
./build.sh
```
After the build, the AppImage can be obtained from the "build-artifacts" folder.
