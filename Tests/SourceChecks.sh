#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OVERLAY_H="$ROOT/Integration/HostPatch/NXLockHomeOverlayView.h"
OVERLAY_M="$ROOT/Integration/HostPatch/NXLockHomeOverlayView.m"
SERVER_M="$ROOT/Integration/HostPatch/NXWindowServer+LockHome.m"
PATCHER="$ROOT/Tools/apply_nyxian_patch.py"
GUIDE="$ROOT/Integration/HostPatch/README.md"

test -s "$OVERLAY_H"
test -s "$OVERLAY_M"
test -s "$SERVER_M"
test -s "$PATCHER"
test -s "$GUIDE"

grep -q 'unlockHandler' "$OVERLAY_H"
grep -q 'handleSwipePan' "$OVERLAY_M"
grep -q 'nx_showLockHomeOnFirstPresentation' "$SERVER_M"
grep -q 'makeKeyAndVisible' "$PATCHER"
grep -q 'runtime-tested against the supplied IPA' "$GUIDE"

echo "PASS: LockHome overlay and source patcher checks passed."
