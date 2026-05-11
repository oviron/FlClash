#!/usr/bin/env bash
# lint.sh — run static analysis for all three FlClash language stacks.
#
# Each stack is independent; failures from one don't short-circuit the others.
# Exit code is non-zero if any stack reported errors.
#
# Usage:
#   ./scripts/lint.sh          # all stacks
#   ./scripts/lint.sh go       # just Go
#   ./scripts/lint.sh kotlin   # just Kotlin
#   ./scripts/lint.sh dart     # just Dart
#   ./scripts/lint.sh fast     # quick subset (dart analyze + ffi-check)

set -uo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"

run="${1:-all}"
status=0

section() { printf '\n\033[1;34m── %s ──\033[0m\n' "$*"; }
ok()      { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
fail()    { printf '\033[1;31m✗\033[0m %s\n' "$*"; status=1; }

run_go() {
  # cgo symbols (bride.c/bride.h) only resolve under the Android NDK toolchain.
  # Without these env vars, typecheck on lib.go fails and every linter cascades.
  local ndk="${ANDROID_NDK:-/opt/homebrew/share/android-commandlinetools/ndk/26.3.11579264}"
  local cc="$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang"
  [[ -x "$cc" ]] || cc="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang"

  if [[ ! -x "$cc" ]]; then
    fail "NDK clang not found at $cc — install via sdkmanager 'ndk;26.3.11579264'"
    return
  fi

  export GOOS=android GOARCH=arm64 CGO_ENABLED=1 CC="$cc"

  section "Go (golangci-lint)"
  if ! command -v golangci-lint >/dev/null 2>&1; then
    fail "golangci-lint not installed (brew install golangci-lint)"
    return
  fi
  (cd core && golangci-lint run --build-tags 'with_gvisor cmfa' ./...) \
    && ok "golangci-lint clean" \
    || fail "golangci-lint reported issues"

  # deadcode operates from main() entry points but FlClash builds c-shared
  # libraries with no main — every //export is its own entry point.
  # Run with -filter to skip the cgo bridge file and our cgo entry points.
  section "Go (deadcode)"
  if command -v deadcode >/dev/null 2>&1; then
    cd core
    out="$(deadcode -tags 'with_gvisor cmfa' -filter '^core/(controller|action|common|constant|hub)$' . 2>&1 \
      | grep -v '^lib\.go\|^platform/\|^tun/\|_cgoexp_\|^bride\|runtime_throw\|_cgo_cmalloc' || true)"
    cd - >/dev/null
    if [[ -z "$out" ]]; then
      ok "no dead Go functions in core package"
    else
      printf '%s\n' "$out"
      fail "deadcode found unreachable Go functions"
    fi
  else
    printf '  deadcode not installed (go install golang.org/x/tools/cmd/deadcode@latest)\n'
  fi

  unset GOOS GOARCH CGO_ENABLED CC
}

run_kotlin() {
  section "Kotlin (detekt)"
  if ! command -v detekt >/dev/null 2>&1; then
    fail "detekt not installed (brew install detekt)"
    return
  fi
  detekt \
    --config detekt.yml \
    --input android/app/src/main/kotlin,android/core/src/main/java,android/service/src/main/java,android/common/src/main/java \
    --build-upon-default-config \
    2>&1 \
    && ok "detekt clean" \
    || fail "detekt reported issues"
}

run_dart() {
  section "Dart (flutter analyze)"
  local flutter="$HOME/dev/flutter/bin/flutter"
  if [[ ! -x "$flutter" ]]; then
    fail "flutter not found at $flutter"
    return
  fi
  out="$("$flutter" analyze --no-pub 2>&1)"
  filtered="$(printf '%s\n' "$out" | grep -E '^\s+(error|warning)' | grep -v 'plugins/' || true)"
  printf '%s\n' "$out" | tail -3
  if [[ -z "$filtered" ]]; then
    ok "flutter analyze clean (app code)"
  else
    fail "flutter analyze reported issues in app code"
  fi
}

run_ffi() {
  section "FFI bindings (Kotlin ↔ Go //export)"
  "$ROOT/scripts/ffi-check.sh" \
    && true \
    || fail "ffi-check.sh reported mismatches"
}

case "$run" in
  go)     run_go ;;
  kotlin) run_kotlin ;;
  dart)   run_dart ;;
  ffi)    run_ffi ;;
  fast)   run_dart; run_ffi ;;
  all|"") run_go; run_kotlin; run_dart; run_ffi ;;
  *) echo "Unknown target: $run (try: all|go|kotlin|dart|ffi|fast)" >&2; exit 2 ;;
esac

echo
[[ $status -eq 0 ]] && ok "all checks passed" || fail "one or more checks failed"
exit $status
