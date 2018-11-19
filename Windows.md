# General requirements

* msys2 
* Visual Studio (for now)

# FFMPEG

* Download latest ffmpeg source archive
* Start "native x64 command prompt"
* From it, start a MSYS2 shell
* `pacman -S diffutils yasm`

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
