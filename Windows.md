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

https://github.com/mstorsjo/llvm-mingw should be the way to go
* Download https://martin.st/temp/llvm-mingw-x86_64-full.zip
* Follow instructions here:  https://github.com/mstorsjo/llvm-mingw/issues/24#issuecomment-444276294

# Faust

# SDL

* Download latest source archive
* With CMake: `cmake -DSDL_STATIC=1 -DCMAKE_BUILD_TYPE=Release path/to/sdl`

# Qt

 * Put ActivePerl in PATH
 * ../qt5/configure -opensource -confirm-license -nomake examples -nomake tests -prefix /c/score-sdk/qt5-dynamic -platform win32-clang-g++ -opengl desktop -release

# Boost

Just download the latest boost archive - only header-only libraries are used.
