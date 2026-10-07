#!/bin/sh
set -eu

PORT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KERNEL_TREE=${TANGORPRO_KERNEL_DIR:-}

if [ -z "$KERNEL_TREE" ]; then
  echo "Set TANGORPRO_KERNEL_DIR to the synced Android kernel source tree" >&2
  exit 2
fi

export TANGORPRO_PORT_ROOT="$PORT_ROOT"
export BUILD_AOSP_KERNEL=${BUILD_AOSP_KERNEL:-0}
if [ "$BUILD_AOSP_KERNEL" = "1" ]; then
  export GKI_DEFCONFIG_FRAGMENT="$PORT_ROOT/droidian/tangorpro-gki-build.config"
else
  unset GKI_DEFCONFIG_FRAGMENT
fi

# Google Clang expects LLD; use Google's matching host OpenSSL headers/libraries
# and the host root as sysroot for this container's Linux host tools.
GOOGLE_HOST_TOOLS="$KERNEL_TREE/prebuilts/kernel-build-tools/linux-x86"
export HOSTCFLAGS=${HOSTCFLAGS:-"-I$GOOGLE_HOST_TOOLS/include"}
export HOSTLDFLAGS=${HOSTLDFLAGS:-"-fuse-ld=lld --sysroot=/ -L$GOOGLE_HOST_TOOLS/lib64 -Wl,-rpath,$GOOGLE_HOST_TOOLS/lib64"}

cd "$KERNEL_TREE"
exec ./build_tangorpro.sh "$@" "HOSTCFLAGS=$HOSTCFLAGS" "HOSTLDFLAGS=$HOSTLDFLAGS"
