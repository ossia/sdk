ln -s /opt/rh/rh-git218/root/usr/bin/git /usr/bin/git
yum install alsa-lib-devel
cmake ../score -DSCORE_CONFIGURATION=static-release -DCMAKE_INSTALL_PREFIX=toto -DCMAKE_PREFIX_PATH=/opt/score-sdk/qt5-dynamic/lib/cmake/Qt5 -DOSSIA_SDK=/opt/score-sdk
