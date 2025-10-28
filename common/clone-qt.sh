#!/bin/bash

source ../common/versions.sh

if [[ ! -d qt ]]; then
git clone https://github.com/qt/qt5 qt -b $QT_VERSION

(
  cd qt
  git submodule update --init --recursive $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git config user.email "you@example.com"
    git config user.name "Your Name"

    # between 6.10.0 and 6.10.1
    git checkout 136d9aa2807619dd9602a97651278296b0690277 
    # qarraydata: prevent a -fsanitize=integer warning
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/65/658065/1 && git cherry-pick FETCH_HEAD
     # Enable exports on static builds
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/66/658066/1 && git cherry-pick FETCH_HEAD
     # missing qstringlist include
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/67/658067/1 && git cherry-pick FETCH_HEAD
     # link to brotlicommon
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/68/658068/1 && git cherry-pick FETCH_HEAD
     # stylesheet missing include
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/69/658069/1 && git cherry-pick FETCH_HEAD
     # qfsm disable sorting
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/75/658075/1 && git cherry-pick FETCH_HEAD
    # qxcbatom.cpp: add missing cstdlib include for free
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/68/686468/1 && git cherry-pick FETCH_HEAD
    # qsimd.cpp: add missing stdlib.h for getenv
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/75/686475/1 && git cherry-pick FETCH_HEAD
    # win32 fontdatabase unity build fix
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/04/686804/1 && git cherry-pick FETCH_HEAD
    # win32 Font api clash
    git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/05/686805/1 && git cherry-pick FETCH_HEAD
    # # link to cppwinrt
    # git fetch https://jcelerier@codereview.qt-project.org/a/qt/qtbase refs/changes/77/658077/1 && git cherry-pick FETCH_HEAD
    # # syncqt build error
    # git fetch https://codereview.qt-project.org/qt/qtbase refs/changes/49/662349/1 && git cherry-pick FETCH_HEAD
    
    # missing cstdlib in qalloc.h
    git cherry-pick 2200b5c098b3ec301ac1b41a9f65f6a4d71eec73
  )

  (
    cd qtdeclarative
    # Between 6.10.0: 
    git checkout 6caacc07a3270b862652e8aa5f4f0cb73a801633 
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch https://codereview.qt-project.org/qt/qtdeclarative refs/changes/68/464668/1 && git cherry-pick FETCH_HEAD

    # ci: fix missing include for std::terminate
    # git fetch https://codereview.qt-project.org/qt/qtdeclarative refs/changes/54/662354/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtshadertools
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch https://codereview.qt-project.org/qt/qtshadertools refs/changes/63/464663/2 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtquick3d
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # openxr missing iterator
    git fetch https://codereview.qt-project.org/qt/qtquick3d refs/changes/06/686806/1 && git cherry-pick FETCH_HEAD
    # QSSGLightmapBaker: add missing QGuiApplication include
    git fetch https://codereview.qt-project.org/qt/qtquick3d refs/changes/07/686807/1 && git cherry-pick FETCH_HEAD

  )
)
fi
