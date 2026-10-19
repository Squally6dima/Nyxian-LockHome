# Host patch integration

These files target Nyxian's host-side UIKit `NXWindowServer`, not `ROM/System/Rom/init`.

## What it does

- Adds a full-window overlay above the WindowServer and managed app windows.
- Shows a localized date, large clock, lock icon, optional wallpaper, and home indicator.
- Detects an upward pan gesture and animates the overlay away, revealing the existing Nyxian UI.
- Does not add authentication or change Procursus binaries.

## Apply

From this repository root, point the patcher at a clean Nyxian source checkout:

```sh
python3 Tools/apply_nyxian_patch.py /path/to/Nyxian --dry-run
python3 Tools/apply_nyxian_patch.py /path/to/Nyxian
```

The script copies four Objective-C files into `Nyxian/LindChain/WindowServer/LockHome/`, adds the LockHome import to `NXWindowServer.m`, and inserts one hook after the window layer is made interactive. It is idempotent and rejects a partial patch or a missing/ambiguous insertion point.

Nyxian's current public project uses a synchronized Xcode source group, so new source files under `Nyxian/` should be discovered automatically. Still inspect the project and `git diff` before building.

## Wallpaper

The overlay looks for an image named `LockHomeWallpaper`. If it is absent, a built-in gradient is used. Add a wallpaper image to the host app's asset catalog if desired.

## What the supplied archives confirm

- The uploaded IPA identifies itself as Nyxian 0.11.5, build `20261014.2.RELEASE`, with SDK metadata `iphoneos27.0`.
- It includes WindowServer headers, but not the matching WindowServer implementation source in the bundled kernel tree.
- The Procursus archive includes a ROM manifest, compiled init/bootstrap binaries, and default light/dark wallpaper PNGs.

The public upstream source has the candidate `makeKeyAndVisible` insertion point, but it may differ from the user's beta build. This patch has **not** been built or runtime-tested against the supplied IPA. The patcher only edits source; it does not re-sign or alter an IPA or ROM.
