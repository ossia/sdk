#!/bin/bash

source ../common/versions.sh

# Apply a Gerrit change to the repo we are currently in.
#
# We carry a dozen-odd unmerged changes against a moving Qt branch, so a change
# regularly stops being a change: it lands upstream, or gets listed here twice.
# Either way the cherry-pick comes out empty, and plain `git cherry-pick` then
# stops mid-operation and exits 1 -- which used to take down every core leg at
# once. Nothing left to apply is success; keep going. A real conflict still
# fails hard, because that one does need a human.
qt_pick() {
  local repo=$1 ref=$2
  git fetch $SDK_FETCH_DEPTH "https://codereview.qt-project.org/qt/$repo" "$ref"
  if git cherry-pick --keep-redundant-commits FETCH_HEAD; then
    return 0
  fi
  git cherry-pick --abort || true
  echo "clone-qt: cherry-pick of $repo $ref conflicts with $QT_VERSION" >&2
  return 1
}

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
    qt_pick qtbase refs/changes/65/658065/1
     # Enable exports on static builds
    qt_pick qtbase refs/changes/66/658066/1
     # missing qstringlist include
    qt_pick qtbase refs/changes/67/658067/1
     # link to brotlicommon
    qt_pick qtbase refs/changes/68/658068/1
     # stylesheet missing include
    qt_pick qtbase refs/changes/69/658069/1
     # qfsm disable sorting
    qt_pick qtbase refs/changes/75/658075/1
    # qsimd.cpp: add missing stdlib.h for getenv -- merged upstream (6.11/dev), now in 6.12.0
    # win32 fontdatabase unity build fix
    qt_pick qtbase refs/changes/04/686804/1
    # win32 Font api clash
    qt_pick qtbase refs/changes/05/686805/1

    # 6.12: QTipLabel::styleSheetParentDestroyed() definition is not guarded by
    # QT_CONFIG(style_stylesheet) while its declaration/members are, so the build
    # breaks with -no-feature-style-stylesheet. Guard the out-of-line definition.
    perl -0pi -e 's/\nvoid QTipLabel::styleSheetParentDestroyed\(\)\n\{\n    setProperty\("_q_stylesheet_parent", QVariant\(\)\);\n    styleSheetParent = nullptr;\n\}\n/\n#if QT_CONFIG(style_stylesheet)\nvoid QTipLabel::styleSheetParentDestroyed()\n{\n    setProperty("_q_stylesheet_parent", QVariant());\n    styleSheetParent = nullptr;\n}\n#endif\n/' src/widgets/kernel/qtooltip.cpp

    # 6.12: the windows platform plugin's cpp_winrt path needs
    # windows.graphics.display.interop.h (HDR per-monitor), a Windows-SDK-only
    # header that mingw-w64 does not ship. Gate those blocks on the header being
    # available so the build degrades gracefully on mingw (no-op off Windows).
    perl -pi -e 's/#if QT_CONFIG\(cpp_winrt\)/#if QT_CONFIG(cpp_winrt) && __has_include(<windows.graphics.display.interop.h>)/g' src/plugins/platforms/windows/qwindowsscreen.cpp

    # qversiontagging.cpp unconditionally emits versioned qt_version_tag symbols
    # (.symver qt_version_tag@Qt_6.x on ELF) whose version nodes are only defined
    # by the shared-lib version script. In a -static build there is no version
    # script at the consumer's link, so lld (--no-undefined-version by default
    # since LLD 17) errors with "qt_version_tag@Qt_6.x has undefined version".
    # Qt already auto-defines QT_NO_VERSION_TAGGING for core-lib/static builds in
    # qversiontagging.h; honour it in the .cpp so the symbols aren't emitted.
    perl -0pi -e 's/#if QT_VERSION_MINOR > 0/#ifndef QT_NO_VERSION_TAGGING\n#if QT_VERSION_MINOR > 0/; s/make_versioned_symbol\(SYM, QT_VERSION_MAJOR, QT_VERSION_MINOR, "\@\@"\);/make_versioned_symbol(SYM, QT_VERSION_MAJOR, QT_VERSION_MINOR, "\@\@");\n#endif/' src/corelib/global/qversiontagging.cpp

    # macos iconengine protection
    qt_pick qtbase refs/changes/10/723510/3
    # macos crash when screen goes off and on
    qt_pick qtbase refs/changes/89/729289/1
    # qyieldcpu: Fix compilation with macOS 26.4 SDK (QTBUG-145239)
    qt_pick qtbase refs/changes/70/725070/3
    # # link to cppwinrt
    # git fetch https://jcelerier@codereview.qt-project.org/a/qt/qtbase refs/changes/77/658077/1 && git cherry-pick FETCH_HEAD
    # # syncqt build error
    # git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtbase refs/changes/49/662349/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtdeclarative
    git config user.email "you@example.com"
    git config user.name "Your Name"
    qt_pick qtdeclarative refs/changes/68/464668/1

    # ci: fix missing include for std::terminate
    # git fetch $SDK_FETCH_DEPTH https://codereview.qt-project.org/qt/qtdeclarative refs/changes/54/662354/1 && git cherry-pick FETCH_HEAD
  )

  (
    cd qtshadertools
    git config user.email "you@example.com"
    git config user.name "Your Name"
    qt_pick qtshadertools refs/changes/63/464663/2
  )

  (
    cd qtquick3d
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # openxr missing iterator -- already present in 6.12.0-beta1 (vendored OpenXR updated upstream)
    # QSSGLightmapBaker: add missing QGuiApplication include
    qt_pick qtquick3d refs/changes/07/686807/1
  )

  (
    cd qtquick3d/src/3rdparty/assimp/src
    git config user.email "you@example.com"
    git config user.name "Your Name"
    # assimp missing ostream
    qt_pick qtquick3d-assimp refs/changes/32/687132/1

  )
)
fi
