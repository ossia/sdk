FROM schachr/raspbian-stretch

COPY qemu-arm-static /usr/bin/qemu-arm-static

RUN apt -y update && \
    apt -y install build-essential git wget bzip2 bison flex ruby python perl texinfo debhelper chrpath sharutils libffi-dev patchutils diffstat xz-utils libedit-dev procps zlib1g-dev  "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev gperf libxslt-dev libasound2-dev libfontconfig1-dev libx11-dev libxext-dev libxfixes-dev libxcb1-dev libxcb-glx0-dev libdbus-1-dev libssl-dev openssl libgles2-mesa-dev
    
ADD gcc-deps.sh /image/gcc-deps.sh
RUN /image/gcc-deps.sh
ADD gcc.sh /image/gcc.sh
RUN /image/gcc.sh

ADD qt-deps.sh /image/qt-deps.sh
RUN /image/qt-deps.sh

ADD config.sh /image/config.sh

ADD llvm.sh /image/llvm.sh
RUN /image/llvm.sh

ADD qt.sh /image/qt.sh
RUN /image/qt.sh

ADD cmake.sh /image/cmake.sh
RUN /image/cmake.sh

ADD ffmpeg.sh /image/ffmpeg.sh
RUN /image/ffmpeg.sh

ADD faust.sh /image/faust.sh
RUN /image/faust.sh

ADD portaudio.sh /image/portaudio.sh
RUN /image/portaudio.sh



