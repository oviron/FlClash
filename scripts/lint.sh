#!/usr/bin/env bash
# lint.sh — Kotlin + Dart static analysis.
#
# Usage:
#   ./scripts/lint.sh          # both stacks
#   ./scripts/lint.sh kotlin
#   ./scripts/lint.sh dart

set -uo pipefail
cd "$(dirname "$0")/.."

run="${1:-all}"
status=0

section() { printf '\n\033[1;34m── %s ──\033[0m\n' "$*"; }
ok()      { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
fail()    { printf '\033[1;31m✗\033[0m %s\n' "$*"; status=1; }

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

case "$run" in
  kotlin)  run_kotlin ;;
  dart)    run_dart ;;
  all|"")  run_kotlin; run_dart ;;
  *) echo "Unknown target: $run (try: all|kotlin|dart)" >&2; exit 2 ;;
esac

echo
[[ $status -eq 0 ]] && ok "all checks passed" || fail "one or more checks failed"
exit $status
