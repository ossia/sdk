# OSSIA/sdk
SDK files for building ossia score and related projects dependencies: FFMPEG, OpenSSL, etc...

The dependencies are built statically on every platform and very up-to-date

- Clang / LLVM with libs
- Qt
- FFMPEG
- Faust
- PortAudio
- FFTW
- JACK
- SDL

The compression, TLS, image and font library release pins live in
[`common/versions.sh`](common/versions.sh). The Linux and Windows SDKs use
zlib-ng in zlib compatibility mode (`libz`), not upstream zlib. When adding
a core dependency, include its pin and recipe in the
[core cache key](.github/actions/core-hash/action.yml) so CI rebuilds the SDK.

