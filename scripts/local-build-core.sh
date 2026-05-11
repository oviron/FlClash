#!/usr/bin/env bash
# local-build-core.sh — build Go core .so locally via Android NDK.
#
# Verifies that `core/` compiles for android/arm64 (default) without pushing to
# CI. Catches the same class of errors as the CI Setup step (undefined Go funcs
# in //export wrappers, mihomo upstream API mismatches under -tags cmfa, etc).
#
# Usage:
#   ./scripts/local-build-core.sh           # arm64-v8a (matches OnePlus 15)
#   ./scripts/local-build-core.sh armv7     # 32-bit arm
#   ./scripts/local-build-core.sh x86_64    # emulator

set -euo pipefail
cd "$(dirname "$0")/.."

: "${ANDROID_NDK:=/opt/homebrew/share/android-commandlinetools/ndk/26.3.11579264}"
if [[ ! -d "$ANDROID_NDK" ]]; then
  echo "ANDROID_NDK not set or missing: $ANDROID_NDK" >&2
  echo "Install via: sdkmanager 'ndk;26.3.11579264'" >&2
  exit 1
fi

arch="${1:-arm64}"
case "$arch" in
  arm64|arm64-v8a)
    goarch=arm64
    cc=aarch64-linux-android21-clang
    out=arm64-v8a ;;
  armv7|armeabi-v7a)
    goarch=arm
    cc=armv7a-linux-androideabi21-clang
    out=armeabi-v7a ;;
  x86_64)
    goarch=amd64
    cc=x86_64-linux-android21-clang
    out=x86_64 ;;
  *)
    echo "Unknown arch: $arch (try arm64 | armv7 | x86_64)" >&2
    exit 1 ;;
esac

ndk_host="darwin-x86_64"
[[ -d "$ANDROID_NDK/toolchains/llvm/prebuilt/$ndk_host" ]] \
  || ndk_host="linux-x86_64"

out_dir="libclash/android/$out"
mkdir -p "$out_dir"

cd core
GOOS=android GOARCH="$goarch" CGO_ENABLED=1 \
  CC="$ANDROID_NDK/toolchains/llvm/prebuilt/$ndk_host/bin/$cc" \
  CFLAGS="-O3 -Werror" \
  go build -ldflags='-w -s' -tags 'with_gvisor,cmfa' \
    -buildmode=c-shared -o "../$out_dir/libclash.so" .
cd - >/dev/null

echo "✓ Built $out_dir/libclash.so ($(du -h "$out_dir/libclash.so" | cut -f1))"
nm -D "$out_dir/libclash.so" | grep -E " T (invokeAction|getControllerEndpoint|getTraffic|getTotalTraffic|startTUN|setEventListener)" | sed 's/^/   /'
