#!/bin/bash

# For building the toolchain
yum -y install glibc-devel \
    devtoolset-8-gcc devtoolset-8-make \
    libxcb-devel xcb-util xcb-util-devel which mesa-libGL-devel \
    rh-git218 svn perl-Data-Dump perl-Data-Dumper \
    cmake3 ncurses-devel zlib-devel
    
# For building score

yum -y update
yum -y install epel-release centos-release-scl devtoolset-8
yum -y update
yum -y install glibc-devel \
    devtoolset-8-gcc devtoolset-8-make \
    libxcb-devel xcb-util xcb-util-devel which mesa-libGL-devel \
    rh-git218 \
    cmake3 ncurses-devel zlib-devel
