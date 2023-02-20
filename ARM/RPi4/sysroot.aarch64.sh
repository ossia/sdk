#!/bin/bash

######
#
# 1. In the host
#
# Extract https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/
# $ sudo losetup --show -fP 2022-09-22-raspios-bullseye-arm64-lite.img 
# $ sudo mkdir /mnt/raspios
# $ sudo mount /dev/loop0p1 /mnt/raspios
# $ cp /mnt/raspios/kernel8.img /mnt/raspios/bcm2710-rpi-3-b.dtb .
# $ sudo umount /mnt/raspios
# $ sudo mount /dev/loop0p2 /mnt/raspios
#  
# Then edit /mnt/raspios/etc/passwd to replace pi:x: by pi:: to remove the password check
#
# $ sudo umount /mnt/raspios
# $ sudo losetup -d /dev/loop0
# $ qemu-system-aarch64 \
#     -m 1024 \
#     -M raspi3b \
#     -kernel kernel8.img \
#     -dtb bcm2710-rpi-3-b.dtb \
#     -sd 2022-09-22-raspios-bullseye-arm64-lite.img \
#     -append "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4 modules-load=dwc2,g_ether" \
#     -device usb-net,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::2222-:22 \
#     -smp 4
#
#
# 2. Within the pi:
#
# $ nano /etc/apt/sources.list
# ... uncomment the deb-src lines
# $ nano /etc/apt/sources.list.d/...
# ... uncomment the deb-src lines
# $ sudo apt update ; sudo apt full-upgrade
# 
# Run the install commands in Dockerfile.debian
#
# $ sudo systemctl enable ssh
# $ sudo systemctl start ssh
#
#
# Useful function to compress a debian package: 
# compress_debian_package () {
#     dpkg -L "$1" | perl -nE 'chomp; say unless -d' | tar caf "$1.tar" -T -
# }
compress_debian_packages () {
    sudo apt-get -y -q install $@
    dpkg -L $@ | perl -nE 'chomp; say unless -d' | tar caf "output.tar.gz" -T -
}

source common.sh
export SYSROOT_SCRIPT=$PWD/copy_sysroot.sh

mkdir -p $SDK_INSTALL_ROOT
cd $SDK_INSTALL_ROOT && \
    mkdir -p pi && \
    mkdir -p pi/build && \
    mkdir -p pi/tools && \
    mkdir -p pi/sysroot && \
    mkdir -p pi/sysroot/usr && \
    mkdir -p pi/sysroot/opt && \
    chown -R 1000:1000 pi

# sudo losetup --show -fP 2022-09-22-raspios-bullseye-arm64-lite.img
# sudo mount /dev/loop0p2 /mnt/raspios

$SYSROOT_SCRIPT "/mnt/raspios" "$SDK_INSTALL_ROOT" "aarch64-linux-gnu"

(
cd $SDK_INSTALL_ROOT/pi
ls

wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
sudo python sysroot-relativelinks.py sysroot
)