#!/usr/bin/env python3
"""Fail if the ARB locale files disagree on their message-key set.

Message keys are the top-level keys that do not start with '@' ('@@locale' and
the per-message '@key' descriptors are ARB metadata, not translatable strings).
A missing key in any locale is a runtime MissingStringException waiting to fire.
"""
import json
import sys
from pathlib import Path

ARB_DIR = Path(__file__).resolve().parent.parent / "arb"


def message_keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k for k in data if not k.startswith("@")}


def main() -> int:
    files = sorted(ARB_DIR.glob("intl_*.arb"))
    if len(files) < 2:
        print(f"locale-parity: need >=2 arb files in {ARB_DIR}, found {len(files)}")
        return 1
    keysets = {f.name: message_keys(f) for f in files}
    union: set[str] = set().union(*keysets.values())
    ok = True
    for name, keys in sorted(keysets.items()):
        missing = union - keys
        if missing:
            ok = False
            print(f"{name}: missing {len(missing)} key(s): {', '.join(sorted(missing))}")
    if ok:
        print(f"locale-parity: OK, {len(union)} keys across {len(files)} locales")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
