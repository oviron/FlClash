#!/usr/bin/env bash
# Boot-smoke the freshly built APK on an emulator: install the x86_64 split,
# launch it, fail on a FATAL EXCEPTION / native abort in logcat within 30s, or
# if the process is not alive after. Catches R8-keep and JNI signature drift.
set -euo pipefail
cd "$(dirname "$0")/.."

apk=$(find dist -maxdepth 1 -name '*x86_64*.apk' 2>/dev/null | head -1 || true)
[ -n "${apk:-}" ] || { echo "::error::no x86_64 APK in dist/"; exit 1; }
echo "Smoke target: $apk"

aapt2=$(find "$ANDROID_HOME/build-tools" -maxdepth 2 -name aapt2 2>/dev/null | sort -V | tail -1)
pkg=$("$aapt2" dump packagename "$apk")
echo "Package: $pkg"

adb logcat -c || true
adb install -r -d "$apk"
adb shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null

sleep 30
crash=$({ adb logcat -d -b crash 2>/dev/null || true; adb logcat -d 2>/dev/null || true; } \
  | grep -E "FATAL EXCEPTION|libc: Fatal signal|JNI DETECTED|art] Check failed" || true)
if [ -n "$crash" ]; then
  echo "::error::APK smoke found a crash:"
  printf '%s\n' "$crash" | head -40
  exit 1
fi
if ! adb shell pidof "$pkg" >/dev/null 2>&1; then
  echo "::error::process $pkg not running 30s after launch"
  exit 1
fi
echo "APK smoke OK: $pkg booted and stayed alive, no FATAL in logcat"
