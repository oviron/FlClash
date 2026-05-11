#!/usr/bin/env bash
# ffi-check.sh — verify Go //export wrappers reference defined Go functions.
#
# Kotlin↔Go is bridged via android/core/src/main/cpp/core.cpp where
# Java_com_follow_clash_core_Core_X functions translate JNI calls into our
# //export X targets in core/. Direct Kotlin↔Go name comparison is therefore
# meaningless (Kotlin `startTun` → C++ Java_..._startTun → Go //export startTUN).
#
# What this script *does* catch:
#   1. Go //export wrappers calling Go functions that no longer exist
#      (e.g. `//export getTraffic` body calls deleted `handleGetTraffic`).
#   2. Go //export symbols missing a C++ bridge entry (would link-fail).
#
# Run from repo root: ./scripts/ffi-check.sh

set -euo pipefail

cd "$(dirname "$0")/.."

go_exports="$(grep -rohE '^//export [a-zA-Z_][a-zA-Z0-9_]*' core/ 2>/dev/null \
  | awk '{print $2}' | sort -u)"

# Names referenced by the C++ JNI bridge (the C function called from each
# Java_..._X wrapper is the unprefixed name). Skip the bridge file itself.
cpp_refs="$(grep -hE 'Java_com_follow_clash_core_Core_' android/core/src/main/cpp/core.cpp 2>/dev/null \
  | grep -oE '[a-zA-Z_][a-zA-Z0-9_]*\(' \
  | sed 's/($//' \
  | grep -vE '^(jstring|JNIEnv|env)$' \
  | sort -u)"

# 1. Bridge symbols missing from Go //export.
missing_in_go=$(comm -23 <(echo "$cpp_refs") <(echo "$go_exports") | grep -vE '^(JNI_OnLoad|NewStringUTF|GetStringUTFChars|ReleaseStringUTFChars|free|Java_)' || true)

status=0

if [[ -n "$missing_in_go" ]]; then
  echo "❌ C++ bridge references symbols missing from Go //export:"
  echo "$missing_in_go" | sed 's/^/   /'
  status=1
fi

# 2. Validate every //export Go function body's handle* calls resolve.
declare -a dangling=()
while IFS= read -r line; do
  file="${line%%:*}"
  remainder="${line#*:}"
  lineno="${remainder%%:*}"
  symbol="$(awk '{print $2}' <<<"${remainder#*:}")"
  body_start=$((lineno + 1))
  body=$(sed -n "${body_start},$((body_start + 8))p" "$file")
  for callee in $(grep -oE 'handle[A-Z][a-zA-Z0-9_]*' <<<"$body" | sort -u); do
    if ! grep -qE "^func ${callee}\\b" core/*.go 2>/dev/null; then
      dangling+=("$file:$lineno //export $symbol calls undefined Go function: $callee")
    fi
  done
done < <(grep -rn '^//export ' core/ 2>/dev/null)

if [[ ${#dangling[@]} -gt 0 ]]; then
  echo "❌ Go //export wrappers referencing undefined functions:"
  printf '   %s\n' "${dangling[@]}"
  status=1
fi

if [[ $status -eq 0 ]]; then
  go_count=$(echo "$go_exports" | wc -l | tr -d ' ')
  cpp_count=$(echo "$cpp_refs" | wc -l | tr -d ' ')
  echo "✓ FFI bindings consistent: $go_count Go //export, $cpp_count C++ bridge refs"
fi

exit $status
