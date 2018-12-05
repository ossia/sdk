[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
git clone https://git.assembla.com/portaudio.git

Invoke-WebRequest -Uri http://www.steinberg.net/sdk_downloads/ASIOSDK2.3.2.zip -OutFile asio.zip
Expand-Archive asio.zip -DestinationPath .

mkdir portaudio-build
cd portaudio-build
cmake ../portaudio `
    -G "Visual Studio 15 2017 Win64" `
    -T host=x64 `
    -DCMAKE_BUILD_TYPE=Release `
    -DPA_BUILD_SHARED=Off `
    -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off `
    -DCMAKE_INSTALL_PREFIX=c:\score-sdk\portaudio
cmake --build . --config Release
cmake --build . --config Release --target INSTALL
