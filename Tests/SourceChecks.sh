#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
HEADER="$ROOT/Sources/NXLockScreenViewController.h"
IMPL="$ROOT/Sources/NXLockScreenViewController.m"
GUIDE="$ROOT/Integration/WindowServer-Integration.md"

test -s "$HEADER"
test -s "$IMPL"
test -s "$GUIDE"

grep -q 'unlockHandler' "$HEADER"
grep -q 'UISwipeGestureRecognizerDirectionUp' "$IMPL"
grep -q 'updateClock' "$IMPL"
grep -q 'host-side' "$GUIDE"

echo "PASS: source files and expected integration hooks are present."
