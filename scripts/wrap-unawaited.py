#!/usr/bin/env python3
"""Wrap fire-and-forget Future expressions in unawaited(...).

Parses `flutter analyze` output for unawaited_futures findings and rewrites
each occurrence. For each `file:line:col`:
- read the file
- locate column position on line
- find expression-end (matching parens/braces, terminator ; , or })
- wrap with unawaited(...)
- ensure `dart:async` import exists

Idempotent within a single pass; subsequent runs are no-ops since wrapped
expressions don't match the lint anymore.
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FLUTTER = Path.home() / "dev/flutter/bin/flutter"

def find_findings():
    out = subprocess.run(
        [str(FLUTTER), "analyze", "--no-pub"],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    ).stdout
    pattern = re.compile(r"• (\S+\.dart):(\d+):(\d+) • unawaited_futures")
    findings = []
    for line in out.splitlines():
        m = pattern.search(line)
        if m:
            findings.append((m.group(1), int(m.group(2)), int(m.group(3))))
    return findings

def expression_end(text: str, start: int) -> int:
    """Find end of Dart expression starting at start. Returns index past the
    last character of the expression (exclusive). Stops at unmatched ;/,/}."""
    depth_paren = depth_brace = depth_bracket = 0
    i = start
    n = len(text)
    while i < n:
        c = text[i]
        if c == "'" or c == '"':
            quote = c
            i += 1
            while i < n and text[i] != quote:
                if text[i] == "\\":
                    i += 2
                    continue
                i += 1
            i += 1
            continue
        if c == "(": depth_paren += 1
        elif c == ")":
            if depth_paren == 0:
                return i
            depth_paren -= 1
        elif c == "{": depth_brace += 1
        elif c == "}":
            if depth_brace == 0:
                return i
            depth_brace -= 1
        elif c == "[": depth_bracket += 1
        elif c == "]":
            if depth_bracket == 0:
                return i
            depth_bracket -= 1
        elif c == ";":
            if depth_paren == depth_brace == depth_bracket == 0:
                return i
        elif c == ",":
            if depth_paren == depth_brace == depth_bracket == 0:
                return i
        i += 1
    return n

def ensure_async_import(text: str) -> str:
    if "import 'dart:async';" in text or 'import "dart:async";' in text:
        return text
    # If there's already a dart:something import, group with it
    m = re.search(r"^import 'dart:\w+';", text, re.MULTILINE)
    if m:
        insert = m.end()
        return text[:insert] + "\nimport 'dart:async';" + text[insert:]
    # Otherwise insert before the first import at top
    m = re.search(r"^import ", text, re.MULTILINE)
    if m:
        return text[:m.start()] + "import 'dart:async';\n" + text[m.start():]
    # No imports at all — prepend
    return "import 'dart:async';\n\n" + text

def col_to_index(text: str, line: int, col: int) -> int:
    """Convert 1-based (line, col) to 0-based byte index."""
    idx = 0
    for _ in range(line - 1):
        nl = text.find("\n", idx)
        if nl < 0:
            return idx
        idx = nl + 1
    return idx + (col - 1)

def expression_start(text: str, end: int) -> int:
    """Walk backwards from end (inclusive of the position pointed to by the
    analyzer) through dotted member chain to find the full receiver-start."""
    i = end - 1
    # Walk back over identifier
    while i >= 0 and (text[i].isalnum() or text[i] == '_'):
        i -= 1
    # If preceded by . (with optional ?), the analyzer pointed mid-chain.
    # Continue walking back through the chain to the root.
    while i >= 0 and text[i] in '.?':
        i -= 1
        # skip closing bracket of subscript or paren of call
        while i >= 0 and text[i] in '])':
            depth = 1
            close = text[i]
            opens = {']': '[', ')': '('}[close]
            i -= 1
            while i >= 0 and depth > 0:
                if text[i] == close:
                    depth += 1
                elif text[i] == opens:
                    depth -= 1
                i -= 1
        # skip identifier
        while i >= 0 and (text[i].isalnum() or text[i] == '_'):
            i -= 1
    return i + 1

def fix_file(file_rel: str, locations: list[tuple[int, int]]):
    file = ROOT / file_rel
    text = file.read_text()
    # Process from the END so earlier indices don't shift.
    locations.sort(reverse=True)
    for line, col in locations:
        col_idx = col_to_index(text, line, col)
        start = expression_start(text, col_idx + 1)
        # Skip if already wrapped — caller wrote unawaited(... )
        prefix = text[max(0, start - 11):start]
        if prefix.endswith("unawaited("):
            continue
        end = expression_end(text, col_idx)
        text = text[:start] + "unawaited(" + text[start:end] + ")" + text[end:]
    text = ensure_async_import(text)
    file.write_text(text)

def main():
    findings = find_findings()
    print(f"found {len(findings)} unawaited_futures occurrences")
    by_file: dict[str, list[tuple[int, int]]] = {}
    for f, l, c in findings:
        by_file.setdefault(f, []).append((l, c))
    for f, locs in by_file.items():
        fix_file(f, locs)
        print(f"  wrapped {len(locs):>3} in {f}")

if __name__ == "__main__":
    main()
