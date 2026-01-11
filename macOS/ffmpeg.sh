#!/bin/bash -eu

source ./common.sh
source ../common/clone-ffmpeg.sh

export FFMPEG_COMMON_FLAGS=(
 --enable-cross-compile
 --disable-doc
 --disable-ffmpeg 
 --disable-ffplay 
 --disable-debug 
 --disable-autodetect 
 --enable-avfoundation 
 --enable-indev=avfoundation 
 --enable-videotoolbox
 --enable-audiotoolbox 
 --pkg-config-flags="--static" 
 --enable-gpl 
 --enable-version3 
 --disable-openssl 
 --disable-securetransport 
 --disable-network
 --disable-iconv 
 --disable-libxcb 
 --enable-protocols 
 --disable-lzma 
)

export FFMPEG_ARM64_FLAGS=(
 --cpu=$CPU_TARGET
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="$CC  -arch arm64 " 
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH"
 --extra-ldflags="$CFLAGS_NOARCH"
)
export FFMPEG_X86_64_FLAGS=(
 --arch="x86_64"
 --prefix=$INSTALL_PREFIX/ffmpeg
 --cc="$CC  -arch x86_64 " 
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -march=$CPU_TARGET"
 --extra-ldflags="$CFLAGS_NOARCH"
)
export FFMPEG_X86_64H_FLAGS=(
 --arch="x86_64h"
 --prefix=$INSTALL_PREFIX/ffmpeg_h
 --cc="$CC  -arch x86_64h " 
 --cxx="$CXX"
 --extra-cflags="$CFLAGS_NOARCH -mtune=cannonlake"
 --extra-ldflags="$CFLAGS_NOARCH"
)

if [[ "$TARGET_ARCH" == "arm64" ]]; then
  (
  rm -rf ffmpeg-build
  mkdir -p ffmpeg-build
  cd ffmpeg-build
  
  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_ARM64_FLAGS[@]}"
  
  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )
else
(
  # We build ffmpeg twice, once in x86_64 and once in x86_64h and then we combine with lipo
  (
  mkdir -p ffmpeg-build
  cd ffmpeg-build
  
  unset CFLAGS
  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_X86_64_FLAGS[@]}"
  
  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )
  
  (
  mkdir -p ffmpeg-build_h
  cd ffmpeg-build_h

  unset CFLAGS
  xcrun ../ffmpeg-$FFMPEG_VERSION/configure "${FFMPEG_COMMON_FLAGS[@]}" "${FFMPEG_X86_64H_FLAGS[@]}"
  
  xcrun make -j$NPROC V=1 VERBOSE=1
  xcrun make install
  )
  
  cp -rf $INSTALL_PREFIX/ffmpeg/lib lib_n
  cp -rf $INSTALL_PREFIX/ffmpeg_h/lib lib_h
  
  for file in libavcodec.a libavdevice.a libavfilter.a libavformat.a libavutil.a libswresample.a libswscale.a; do
    lipo lib_n/$file lib_h/$file -create -output $INSTALL_PREFIX/ffmpeg/lib/$file
  done
  
  rm -rf lib_n lib_h
  rm -rf $INSTALL_PREFIX/ffmpeg_h
)
fi
