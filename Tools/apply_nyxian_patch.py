#!/usr/bin/env python3
"""Apply the NXLockHome overlay to a Nyxian source checkout.

Usage:
  python3 Tools/apply_nyxian_patch.py /path/to/Nyxian

The patch is deliberately source-only. It does not modify a signed IPA or ROM.
"""
from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPONENTS = (
    "NXLockHomeOverlayView.h",
    "NXLockHomeOverlayView.m",
    "NXWindowServer+LockHome.h",
    "NXWindowServer+LockHome.m",
)
IMPORT_LINE = '#import <LindChain/WindowServer/LockHome/NXWindowServer+LockHome.h>'
HOOK_LINE = '    [self nx_showLockHomeOnFirstPresentation];'
ANCHOR = '    [_windowLayer setUserInteractionEnabled:YES];'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("nyxian_root", type=Path, help="Nyxian source checkout root (contains Nyxian/LindChain)")
    parser.add_argument("--dry-run", action="store_true", help="validate the patch without writing files")
    args = parser.parse_args()

    root = args.nyxian_root.expanduser().resolve()
    target = root / "Nyxian" / "LindChain" / "WindowServer"
    server_source = target / "NXWindowServer.m"
    if not server_source.is_file():
        print(f"ERROR: can't find {server_source}; expected the Nyxian source checkout root.", file=sys.stderr)
        return 2

    source_text = server_source.read_text(encoding="utf-8")
    if IMPORT_LINE not in source_text and "NXWindowServer+LockHome.h" in source_text:
        print("ERROR: found a LockHome import with an unexpected path; inspect the source manually.", file=sys.stderr)
        return 3

    has_import = IMPORT_LINE in source_text
    has_hook = HOOK_LINE in source_text
    if has_import != has_hook:
        print("ERROR: partial patch detected (import and hook do not agree). No files changed.", file=sys.stderr)
        return 4

    if not has_import and source_text.count(ANCHOR) != 1:
        print("ERROR: expected exactly one makeKeyAndVisible anchor. This Nyxian version may differ; no files changed.", file=sys.stderr)
        return 5

    for name in COMPONENTS:
        if not (ROOT / "Integration" / "HostPatch" / name).is_file():
            print(f"ERROR: missing component file: Integration/HostPatch/{name}", file=sys.stderr)
            return 6

    if args.dry_run:
        print("PASS: target structure and insertion point found.")
        print("Patch status:", "already applied" if has_import else "ready to apply")
        return 0

    if has_import:
        print("Already patched; no changes made.")
        return 0

    target_dir = target / "LockHome"
    target_dir.mkdir(parents=True, exist_ok=True)
    for name in COMPONENTS:
        shutil.copy2(ROOT / "Integration" / "HostPatch" / name, target_dir / name)

    # Add the import after the existing WindowServer imports.
    lines = source_text.splitlines(keepends=True)
    last_import_index = max((i for i, line in enumerate(lines) if line.startswith("#import ")), default=-1)
    if last_import_index < 0:
        print("ERROR: no import statements found; copied component files but did not modify NXWindowServer.m.", file=sys.stderr)
        return 7
    lines.insert(last_import_index + 1, IMPORT_LINE + "\n")

    patched = "".join(lines)
    if patched.count(ANCHOR) != 1:
        print("ERROR: expected exactly one makeKeyAndVisible insertion anchor. Component files copied; source file not modified.", file=sys.stderr)
        return 8
    patched = patched.replace(ANCHOR, ANCHOR + "\n\n    // NXLockHome: show once over the host WindowServer.\n" + HOOK_LINE, 1)
    server_source.write_text(patched, encoding="utf-8")
    print("PATCHED:", server_source)
    print("ADDED:", target_dir)
    print("Next: build the Nyxian target in Xcode and test on a disposable install.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
