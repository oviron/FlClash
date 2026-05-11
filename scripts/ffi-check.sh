#!/usr/bin/env bash
# ffi-check.sh — verify Kotlin↔Go JNI binding consistency.
#
# Fails when any of:
#   * Kotlin `external fun NAME(...)` has no matching Go `//export NAME`
#   * A Go `//export` wrapper references a Go function that no longer exists
#     (would surface as `undefined: handleX` at cgo build time)
#
# Run from repo root: ./scripts/ffi-check.sh
# Designed for fast pre-push gating without needing the Android NDK toolchain.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

kotlin_externals="$(grep -rohE 'external fun [a-zA-Z_][a-zA-Z0-9_]*' android/ 2>/dev/null \
  | awk '{print $3}' | sort -u)"

go_exports="$(grep -rohE '^//export [a-zA-Z_][a-zA-Z0-9_]*' core/ 2>/dev/null \
  | awk '{print $2}' | sort -u)"

missing_in_go=$(comm -23 <(echo "$kotlin_externals") <(echo "$go_exports"))

orphan_exports=$(comm -13 <(echo "$kotlin_externals") <(echo "$go_exports"))

# Validate every //export Go function body references symbols that are defined.
# Parse Go source for function definitions, then for each //export check that the
# wrapper body's first non-comment line references a callable.
declare -a dangling=()
while IFS= read -r line; do
  file="${line%%:*}"
  remainder="${line#*:}"
  lineno="${remainder%%:*}"
  symbol="$(awk '{print $2}' <<<"${remainder#*:}")"
  # Lookup body — usually the function definition starts on the next line.
  body_start=$((lineno + 1))
  body=$(sed -n "${body_start},$((body_start + 8))p" "$file")
  # Extract called handle* identifiers from the body
  for callee in $(grep -oE 'handle[A-Z][a-zA-Z0-9_]*' <<<"$body" | sort -u); do
    if ! grep -qE "^func ${callee}\\b" core/*.go 2>/dev/null; then
      dangling+=("$file:$lineno //export $symbol calls undefined Go function: $callee")
    fi
  done
done < <(grep -rn '^//export ' core/ 2>/dev/null)

status=0

if [[ -n "$missing_in_go" ]]; then
  echo "❌ Kotlin external fun without matching Go //export:"
  echo "$missing_in_go" | sed 's/^/   /'
  status=1
fi

if [[ -n "$orphan_exports" ]]; then
  echo "⚠️  Go //export with no Kotlin caller (informational, may be Dart FFI):"
  echo "$orphan_exports" | sed 's/^/   /'
fi

if [[ ${#dangling[@]} -gt 0 ]]; then
  echo "❌ Go //export wrappers referencing undefined functions:"
  printf '   %s\n' "${dangling[@]}"
  status=1
fi

if [[ $status -eq 0 ]]; then
  echo "✓ Kotlin↔Go JNI bindings consistent ($(echo "$kotlin_externals" | wc -l | tr -d ' ') Kotlin externals, $(echo "$go_exports" | wc -l | tr -d ' ') Go exports)"
fi

exit $status
