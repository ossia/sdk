[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://www.libsdl.org/release/SDL2-2.0.9.zip -OutFile sdl2.zip

Expand-Archive sdl2.zip

mkdir sdl-build
cd sdl-build
cmake ../sdl2/SDL2-2.0.9 `
    -G "Visual Studio 15 2017 Win64" `
    -T host=x64 `
    -DCMAKE_BUILD_TYPE=Release `
    -DSDL_STATIC=1 `
    -DCMAKE_INSTALL_PREFIX=c:\score-sdk\SDL2
cmake --build . --config Release
cmake --build . --config Release --target INSTALL
