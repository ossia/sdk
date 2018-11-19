# FFMPEG

* Download latest ffmpeg source archive
* Download yasm
* Start "native x64 command prompt"
* From it, start a bash shell / msys / mingw / whatever
* Add the path to yasm to PATH
Build command is : 
```
../ffmpeg-4.1/configure --target-os=win64 --arch=x86_64 --toolchain=msvc --cpu=x86_64 --disable-doc --disable-ffmpeg --disable-ffplay --disable-debug --prefix=/c/ffmpeg --pkg-config-flags="--static" --enable-gpl --enable-version3 --disable-openssl --disable-securetransport --disable-videotoolbox --disable-network --disable-iconv --disable-lzma
make
make install
```    
which will install the libraries in `c:\ffmpeg`

# LLVM

# Faust

# SDL

# Qt

Just download the latest Qt

# Boost

Just download the latest boost archive - only header-only libraries are used.
