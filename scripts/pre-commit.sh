#!/usr/bin/env bash
# Pre-commit hook: dart format check + flutter analyze on staged Dart files.
# Install: ln -s ../../scripts/pre-commit.sh .git/hooks/pre-commit
#
# Exits non-zero (blocking the commit) on format drift or analyzer findings.
# Bypass for an emergency commit with: git commit --no-verify

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# Resolve flutter binary: PATH first, then common dev install.
if command -v flutter >/dev/null 2>&1; then
  FLUTTER=flutter
elif [ -x "$HOME/dev/flutter/bin/flutter" ]; then
  FLUTTER="$HOME/dev/flutter/bin/flutter"
else
  echo "pre-commit: flutter not found on PATH; skipping checks" >&2
  exit 0
fi

# Only inspect staged, added/modified/copied Dart files.
mapfile -t staged < <(git diff --cached --name-only --diff-filter=ACM | grep -E '\.dart$' || true)
if [ "${#staged[@]}" -eq 0 ]; then
  exit 0
fi

# Drop generated files and l10n outputs — they regenerate from sources.
filtered=()
for f in "${staged[@]}"; do
  case "$f" in
    lib/l10n/intl/*|*/generated/*|*.g.dart|*.freezed.dart) ;;
    *) filtered+=("$f") ;;
  esac
done

if [ "${#filtered[@]}" -eq 0 ]; then
  exit 0
fi

echo "pre-commit: dart format check (${#filtered[@]} file(s))"
if ! dart format --output=none --set-exit-if-changed "${filtered[@]}"; then
  echo "pre-commit: run \`dart format ${filtered[*]}\` and re-stage." >&2
  exit 1
fi

echo "pre-commit: flutter analyze --fatal-infos"
if ! "$FLUTTER" analyze --no-pub --fatal-infos; then
  echo "pre-commit: analyzer findings above. Fix or commit with --no-verify if intentional." >&2
  exit 1
fi
