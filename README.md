# Nyxian LockHome

A host-side iOS-style lock-screen overlay for Nyxian Beta 0.11.5.

## Features

- Large localized clock and date.
- Lock glyph, home indicator, and optional wallpaper image.
- Swipe-up gesture with an animated reveal of Nyxian's existing UI.
- A source patcher that checks the expected WindowServer insertion point before editing.
- GitHub Actions source checks and patcher tests.

## Repository layout

- `Integration/HostPatch/` — Objective-C overlay and NXWindowServer category.
- `Integration/HostPatch/README.md` — integration and compatibility notes.
- `Tools/apply_nyxian_patch.py` — guarded source patcher.
- `Tests/test_patcher.py` — dry-run, apply, and idempotence tests.
- `PROJECT_STATUS.md` — archive findings and verification status.

## Apply to Nyxian source

Use a clean Nyxian source checkout, not the compiled IPA:

```sh
python3 Tools/apply_nyxian_patch.py /path/to/Nyxian --dry-run
python3 Tools/apply_nyxian_patch.py /path/to/Nyxian
```

The path should contain `Nyxian/LindChain/WindowServer/NXWindowServer.m`. Inspect `git diff`, build using Nyxian's normal Xcode workflow, and test on a disposable install.

## Status

The supplied IPA is Nyxian 0.11.5, build `20261014.2.RELEASE`. It contains WindowServer headers, but not the matching WindowServer implementation source. The Procursus archive contains a compiled ROM init and default wallpapers, not the UIKit host implementation. The patcher uses a source insertion point seen in public upstream source and refuses to proceed if the target source differs.

**No modified IPA, compiled package, or rebuilt ROM is included yet.** The overlay has not been compiled or runtime-tested against the supplied beta build. Without an asset named `LockHomeWallpaper`, the overlay uses a gradient fallback.

## License

Integration files use AGPL-3.0-or-later, consistent with Nyxian upstream. This does not change the license of Nyxian itself.
