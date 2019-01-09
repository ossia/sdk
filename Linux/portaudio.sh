#!/bin/bash

source ./common.sh

wget -nv http://www.portaudio.com/archives/pa_snapshot.tgz
tar xaf pa_snapshot.tgz

sed -i '378i TARGET_INCLUDE_DIRECTORIES(portaudio_static PUBLIC "$<INSTALL_INTERFACE:include>")' portaudio/CMakeLists.txt
sed -i '307d' portaudio/CMakeLists.txt # SET(PA_LIBRARY_DEPENDENCIES ${PA_LIBRARY_DEPENDENCIES} ${ALSA_LIBRARIES})
sed -i '306d' portaudio/CMakeLists.txt # SET(PA_PKGCONFIG_LDFLAGS "${PA_PKGCONFIG_LDFLAGS} -lasound")
sed -i '305d' portaudio/CMakeLists.txt

sed -i '305i  SET(PA_PRIVATE_COMPILE_DEFINITIONS ${PA_PRIVATE_COMPILE_DEFINITIONS} PA_USE_ALSA PA_ALSA_DYNAMIC)' portaudio/CMakeLists.txt
sed -i '305i  SET(PA_PKGCONFIG_LDFLAGS "${PA_PKGCONFIG_LDFLAGS} ${CMAKE_DL_LIBS}")' portaudio/CMakeLists.txt
      
      
cd portaudio/build

$CMAKE .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_POSITION_INDEPENDENT_CODE=1 \
 -DPA_BUILD_SHARED=Off \
 -DPA_USE_JACK=Off \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX/portaudio

make -j$NPROC
make install
