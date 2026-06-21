#!/bin/bash

source ../common/versions.sh

if [[ ! -d qt ]]; then
git clone $SDK_CLONE_DEPTH https://github.com/qt/qt5 qt -b $QT_VERSION

(
  cd qt
  git submodule update --init --recursive $SDK_CLONE_DEPTH $(cat "$SDK_COMMON_ROOT/common/qtmodules")

  (
    cd qtbase
    git config user.email "you@example.com"
    git config user.name "Your Name"

    # qarraydata: prevent a -fsanitize=integer warning
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/65/658065/1 && git cherry-pick FETCH_HEAD
     # Enable exports on static builds
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/66/658066/1 && git cherry-pick FETCH_HEAD
     # missing qstringlist include
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/67/658067/1 && git cherry-pick FETCH_HEAD
     # link to brotlicommon
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/68/658068/1 && git cherry-pick FETCH_HEAD
     # stylesheet missing include
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/69/658069/1 && git cherry-pick FETCH_HEAD
     # qfsm disable sorting
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/75/658075/1 && git cherry-pick FETCH_HEAD
    # qsimd.cpp: add missing stdlib.h for getenv -- merged upstream (6.11/dev), now in 6.12.0
    # win32 fontdatabase unity build fix
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/04/686804/1 && git cherry-pick FETCH_HEAD
    # win32 Font api clash
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/05/686805/1 && git cherry-pick FETCH_HEAD

    # 6.12: QTipLabel::styleSheetParentDestroyed() definition is not guarded by
    # QT_CONFIG(style_stylesheet) while its declaration/members are, so the build
    # breaks with -no-feature-style-stylesheet. Guard the out-of-line definition.
    perl -0pi -e 's/\nvoid QTipLabel::styleSheetParentDestroyed\(\)\n\{\n    setProperty\("_q_stylesheet_parent", QVariant\(\)\);\n    styleSheetParent = nullptr;\n\}\n/\n#if QT_CONFIG(style_stylesheet)\nvoid QTipLabel::styleSheetParentDestroyed()\n{\n    setProperty("_q_stylesheet_parent", QVariant());\n    styleSheetParent = nullptr;\n}\n#endif\n/' src/widgets/kernel/qtooltip.cpp

    # 6.12: the windows platform plugin's cpp_winrt path needs
    # windows.graphics.display.interop.h (HDR per-monitor), a Windows-SDK-only
    # header that mingw-w64 does not ship. Gate those blocks on the header being
    # available so the build degrades gracefully on mingw (no-op off Windows).
    perl -pi -e 's/#if QT_CONFIG\(cpp_winrt\)/#if QT_CONFIG(cpp_winrt) && __has_include(<windows.graphics.display.interop.h>)/g' src/plugins/platforms/windows/qwindowsscreen.cpp

    # # link to cppwinrt
    # git fetch https://jcelerier@codereview.qt-project.org/a/qt/qtbase refs/changes/77/658077/1 && git cherry-pick FETCH_HEAD
    # # syncqt build error
    # git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/49/662349/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtdeclarative
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtdeclarative refs/changes/68/464668/1 && git cherry-pick FETCH_HEAD

    # ci: fix missing include for std::terminate
    # git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtdeclarative refs/changes/54/662354/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtshadertools
    git config user.email "you@example.com"
    git config user.name "Your Name"
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtshadertools refs/changes/63/464663/2 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtquick3d
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # openxr missing iterator -- already present in 6.12.0-beta1 (vendored OpenXR updated upstream)
    # QSSGLightmapBaker: add missing QGuiApplication include
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtquick3d refs/changes/07/686807/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtquick3d/src/3rdparty/assimp/src
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # assimp missing ostream
    git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtquick3d-assimp refs/changes/32/687132/1 && git cherry-pick FETCH_HEAD

  )
)
fi
