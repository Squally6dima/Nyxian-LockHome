#!/usr/bin/env python3
"""Apply the NXLockHome host-side source patch to a Nyxian source checkout.

This intentionally edits source only. It does not patch a compiled IPA or ROM.
Run it against a clean/reviewed Nyxian checkout and rebuild with the project's
own build workflow.
"""
from __future__ import annotations

import argparse
import shutil
from pathlib import Path

SOURCE_NAMES = (
    "NXLockHomeOverlayView.h",
    "NXLockHomeOverlayView.m",
    "NXWindowServer+LockHome.h",
    "NXWindowServer+LockHome.m",
)

IMPORT_ANCHOR = "#import <LindChain/WindowServer/NXWindowServer.h>"
FRONT_ANCHOR = "    [_windowLayer setUserInteractionEnabled:YES];"
IMPORT_LINE = '#import "NXWindowServer+LockHome.h"'
HOOK_LINE = "    [self nx_showLockHomeOnFirstPresentation];"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", required=True, type=Path,
                        help="Path to a Nyxian source checkout")
    parser.add_argument("--source-dir", type=Path, default=Path(__file__).resolve().parents[1] / "Integration" / "HostPatch",
                        help="Directory containing NXLockHome source files")
    parser.add_argument("--dry-run", action="store_true",
                        help="Validate compatibility and print planned changes without writing")
    args = parser.parse_args()

    repo = args.repo_root.resolve()
    source_dir = args.source_dir.resolve()
    target = repo / "Nyxian" / "LindChain" / "WindowServer" / "NXWindowServer.m"

    if not target.is_file():
        raise SystemExit(f"ERROR: expected host source not found: {target}")
    missing = [name for name in SOURCE_NAMES if not (source_dir / name).is_file()]
    if missing:
        raise SystemExit("ERROR: missing LockHome source files: " + ", ".join(missing))

    original = target.read_text(encoding="utf-8")
    if IMPORT_LINE in original and HOOK_LINE in original:
        print("Already patched: no changes needed.")
        return 0

    if original.count(IMPORT_ANCHOR) != 1:
        raise SystemExit("ERROR: expected one NXWindowServer import anchor; source version may differ.")
    if original.count(FRONT_ANCHOR) != 1:
        raise SystemExit("ERROR: expected one window-layer presentation anchor; source version may differ.")
    if IMPORT_LINE in original or HOOK_LINE in original:
        raise SystemExit("ERROR: partial/unknown patch detected; inspect NXWindowServer.m manually.")

    patched = original.replace(IMPORT_ANCHOR, IMPORT_ANCHOR + "\n" + IMPORT_LINE, 1)
    patched = patched.replace(FRONT_ANCHOR, FRONT_ANCHOR + "\n" + HOOK_LINE, 1)

    print("Target:", target)
    print("Will copy:")
    for name in SOURCE_NAMES:
        print("  ", source_dir / name, "->", target.parent / name)
    print("Will add import and one-time overlay call in NXWindowServer.m")
    if args.dry_run:
        print("Dry run complete; no files changed.")
        return 0

    # Never silently overwrite an existing user's files.
    conflicts = [name for name in SOURCE_NAMES if (target.parent / name).exists()]
    if conflicts:
        raise SystemExit("ERROR: destination file(s) already exist; refusing to overwrite: " + ", ".join(conflicts))

    for name in SOURCE_NAMES:
        shutil.copy2(source_dir / name, target.parent / name)
    target.write_text(patched, encoding="utf-8")
    print("Patch applied. Review git diff, build Nyxian, and test on a disposable device.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
