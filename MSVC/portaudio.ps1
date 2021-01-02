[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# git clone https://git.assembla.com/portaudio.git

# Invoke-WebRequest -Uri http://www.steinberg.net/sdk_downloads/ASIOSDK2.3.2.zip -OutFile asio.zip
# Expand-Archive asio.zip -DestinationPath .

mkdir portaudio-build
cd portaudio-build

# note: wdmks disabled as it conflicts with ffmpeg :
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: ENCAPIPARAM_BITRATE déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: ENCAPIPARAM_PEAK_BITRATE déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: ENCAPIPARAM_BITRATE_MODE déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_CHANGELISTS déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_VIDEO_ENCODER déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_AUDIO_ENCODER déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_SETALLDEFAULTS déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_ALLSETTINGS déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_SUPPORTSEVENTS déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]
# portaudio_static_x64.lib(pa_win_wdmks.obj) : error LNK2005: CODECAPI_CURRENTCHANGELIST déjà défini(e) dans strmiids.lib(strmiids.obj) [C:\dev\build-msvc\src\app\score.vcxproj]

cmake ../portaudio `
    -G "Visual Studio 16 2019" `
    -A x64 `
    -T host=x64 `
    -DCMAKE_BUILD_TYPE=Release `
    -DPA_BUILD_SHARED=Off `
    -DPA_USE_WDMKS=Off `
    -DPA_DLL_LINK_WITH_STATIC_RUNTIME=Off `
    -DCMAKE_INSTALL_PREFIX=c:\score-sdk-msvc\portaudio
cmake --build . --config Release
cmake --build . --config Release --target INSTALL
