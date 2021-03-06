#!/bin/bash

cd /opt/ossia-sdk-rpi/pi
sudo cp /usr/lib/arm-linux-gnueabihf/*.o /usr/lib/
sudo rsync -az /lib sysroot
sudo rsync -az /usr/include sysroot/usr
sudo rsync -az /usr/lib sysroot/usr
sudo rsync -az /opt/vc sysroot/opt