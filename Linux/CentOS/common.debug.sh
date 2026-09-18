#!/bin/bash -eux

export CPU_ARCH="${CPU_ARCH:-x86_64}"
if [[ "$CPU_ARCH" != "x86_64" ]]; then
  echo "The Linux debug SDK currently supports only x86_64 (got '$CPU_ARCH')" >&2
  return 1 2>/dev/null || exit 1
fi

export NPROC="${NPROC:-$(nproc)}"
export INSTALL_PREFIX=/opt/ossia-sdk-debug-$CPU_ARCH
export INSTALL_PREFIX_CMAKE=$INSTALL_PREFIX
export SDK_ROOT=$PWD
export ARCH_VARNAME=X86_64
export ARCH=x86_64
export GCC_ARCH=x86-64-v3
export GCC_CPU=x86-64-v3
export LLVM_ARCH=X86
export ARCHFLAGS="-march=x86-64-v3"

# Instrument every object that enters the SDK with the standard ASan and UBSan
# suites. Clang's non-UB unsigned-overflow checks are deliberately excluded:
# LLVM and codecs use defined unsigned wraparound as part of their algorithms.
export SANITIZER_FLAGS="-fsanitize=address,undefined"
export SANITIZER_COMPILE_FLAGS="$SANITIZER_FLAGS -fsanitize-address-use-after-scope -fsanitize-address-use-after-return=always -fno-sanitize-recover=all"
export SANITIZER_LINK_FLAGS="$SANITIZER_FLAGS -fno-sanitize-recover=all"
export DEBUG_COMMON_FLAGS="-D_DEBUG -UNDEBUG -O0 -g3 $ARCHFLAGS -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-common -fstack-protector-strong -fstack-clash-protection -pthread -fPIC"
export CFLAGS="$DEBUG_COMMON_FLAGS $SANITIZER_COMPILE_FLAGS"
export CXXFLAGS="$CFLAGS -DQT_FORCE_ASSERTS -U_LIBCPP_HARDENING_MODE -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG -stdlib=libc++"
export LDFLAGS="$SANITIZER_LINK_FLAGS"
# Sanitized build-time generators intentionally retain process-lifetime caches.
# Keep ASan/UBSan fatal for memory errors and UB, but do not treat those tool
# caches as SDK build failures. Consumer processes retain LeakSanitizer defaults.
export ASAN_OPTIONS="detect_leaks=0:halt_on_error=1"
export UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1"

export LD_LIBRARY_PATH=
if [[ -f "$INSTALL_PREFIX/llvm/bin/clang" ]]; then
  export CC=$INSTALL_PREFIX/llvm/bin/clang
  export CXX=$INSTALL_PREFIX/llvm/bin/clang++
  export PATH=$INSTALL_PREFIX/llvm/bin:$PATH

  if [[ -d "$INSTALL_PREFIX/llvm/lib/x86_64-unknown-linux-gnu" ]]; then
    export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib/x86_64-unknown-linux-gnu
  else
    export LD_LIBRARY_PATH=$INSTALL_PREFIX/llvm/lib
  fi
else
  export CC=clang
  export CXX=clang++
fi

export PATH=$SDK_ROOT/cmake/bin:$PATH
export GIT=/usr/bin/git
export CMAKE=$SDK_ROOT/cmake/bin/cmake
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rh/rh-git218/root/usr/lib:/opt/rh/httpd24/root/usr/lib64

command -v ccache >/dev/null 2>&1 && export CCACHE_LAUNCHER="ccache" || export CCACHE_LAUNCHER=""

export SDK_DEBUG=1
export CMAKE_BUILD_TYPE=Debug
export MESON_BUILD_TYPE=debug
export QT_MODE=debug
export CMAKE_INSTALL_TARGET=install
# Keep the compiler itself fast: it is a build tool, not shipped application
# code. LLVM assertions stay enabled, while libc++ is rebuilt separately below
# with the full sanitizer and hardening flags.
export LLVM_BUILD_TYPE=Release
export LLVM_CFLAGS="-O2 -g0 -fPIC $ARCHFLAGS -fno-omit-frame-pointer"
export LLVM_CXXFLAGS="$LLVM_CFLAGS"
export LLVM_ENABLE_RUNTIMES=""
export LLVM_ENABLE_PROJECTS="clang;lld;lldb;polly"
export COMPILER_RT_BUILD_SANITIZERS=ON
export COMPILER_RT_BUILD_XRAY=ON
export COMPILER_RT_BUILD_LIBFUZZER=ON
export COMPILER_RT_BUILD_PROFILE=ON
export COMPILER_RT_BUILD_MEMPROF=ON
export COMPILER_RT_BUILD_CTX_PROFILE=ON
export COMPILER_RT_BUILD_GWP_ASAN=ON
export COMPILER_RT_BUILD_SHARED_ASAN=ON
export LLVM_USE_SANITIZER=""
export LLVM_ADDITIONAL_FLAGS=" -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_ENABLE_DUMP=ON -DLLVM_ABI_BREAKING_CHECKS=WITH_ASSERTS -DCLANG_ENABLE_STATIC_ANALYZER=ON -DLLDB_ENABLE_PYTHON=ON "

export MESON_COMMON_FLAGS=(
  -Dbuildtype=$MESON_BUILD_TYPE
  -Db_ndebug=false
  -Ddefault_library=static
  -Dglib=disabled
  -Dgobject=disabled
  -Dicu=disabled
  -Ddocs=disabled
  -Dtests=disabled
)
export CMAKE_COMMON_FLAGS=(
  -GNinja
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  "-DCMAKE_EXE_LINKER_FLAGS=$SANITIZER_LINK_FLAGS"
  "-DCMAKE_SHARED_LINKER_FLAGS=$SANITIZER_LINK_FLAGS"
  "-DCMAKE_MODULE_LINKER_FLAGS=$SANITIZER_LINK_FLAGS"
)

export PKG_CONFIG_PATH="$INSTALL_PREFIX/sysroot/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib64/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH:/usr/lib64/pkgconfig"
