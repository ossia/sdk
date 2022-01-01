#!/bin/bash

export VERSION=78
export SDK_RELEASE=23

wget https://boostorg.jfrog.io/artifactory/main/release/1.${VERSION}.0/source/boost_1_${VERSION}_0.7z
wget https://boostorg.jfrog.io/artifactory/main/release/1.${VERSION}.0/source/boost_1_${VERSION}_0.tar.bz2

7z x boost_1_${VERSION}_0.7z

# Windows extraction
mkdir windows
pushd windows
mkdir boost_1_${VERSION}_0
mv ../boost_1_${VERSION}_0/boost boost_1_${VERSION}_0/
7z a boost_1_${VERSION}_0.zip boost_1_${VERSION}_0
mv boost_1_${VERSION}_0.zip ..
popd

rm -rf boost_1_${VERSION}_0

tar xaf boost_1_${VERSION}_0.tar.bz2

# Unix extraction
mkdir unix
pushd unix
mkdir boost_1_${VERSION}_0
mv ../boost_1_${VERSION}_0/boost boost_1_${VERSION}_0/
tar caf boost_1_${VERSION}_0.tar.gz boost_1_${VERSION}_0
mv boost_1_${VERSION}_0.tar.gz ..
popd

rm -rf boost_1_${VERSION}_0

rm -rf unix windows