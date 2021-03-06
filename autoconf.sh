#!/bin/sh

MAKE="$1"
TOOLCHAIN_TRIPLE="$2"
ANDROID_ARCH_NAME="$3"
ANDROID_PLATFORM_LEVEL="$4"
PREFIX="$5"
ANDROID_NDK="$6"

PWD=`pwd`

echo "TOOLCHAIN_TRIPLE: $TOOLCHAIN_TRIPLE"
echo "ANDROID_ARCH_NAME: $ANDROID_ARCH_NAME"
echo "ANDROID_PLATFORM_LEVEL: $ANDROID_PLATFORM_LEVEL"
echo "PREFIX: $PREFIX"
echo "ANDROID_NDK: $ANDROID_NDK"
echo "PWD: $PWD"

MY_NDK="$PWD/../android-toolchain"

export PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$PATH

"${ANDROID_NDK}/build/tools/make_standalone_toolchain.py" \
    --arch $ANDROID_ARCH_NAME \
    --api $ANDROID_PLATFORM_LEVEL \
    --stl libc++ \
    --install-dir "${MY_NDK}"

SYSROOT="${MY_NDK}/sysroot"
export PATH="${MY_NDK}/bin":$PATH

$(pwd)/autogen.sh

if [ "$ANDROID_ARCH_NAME" == "arm" ]; then
  export LDFLAGS="-Wl,--exclude-libs,libunwind.a -Wl,--exclude-libs,libgcc.a"
fi

if [ "$ANDROID_ARCH_NAME" == "arm64" ] || [[ "$ANDROID_ARCH_NAME" == x86* ]]; then
  $(pwd)/configure --host=$TOOLCHAIN_TRIPLE --with-sysroot=${SYSROOT} --prefix=$PREFIX --disable-neon
else
  $(pwd)/configure --host=$TOOLCHAIN_TRIPLE --with-sysroot=${SYSROOT} --prefix=$PREFIX --enable-fixed-point
fi

${MAKE}
${MAKE} install
