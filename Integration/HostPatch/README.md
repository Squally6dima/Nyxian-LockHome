# Host patch for Nyxian LockHome

These files are designed for the Nyxian host's UIKit-based NXWindowServer, not for ROM/System/Rom/init.

## What it does

- Adds a full-window overlay above Nyxian's managed app layer.
- Shows a localized date, large live clock, lock symbol, optional wallpaper, and home indicator.
- Requires an upward pan gesture to dismiss the overlay.
- Keeps the actual window/root manager intact; unlock reveals the existing Nyxian UI.

## Apply to a source checkout

From the root of this repository, use a clean Nyxian source checkout:

\`\`\`sh
python3 Tools/apply-host-patch.py --repo-root /path/to/Nyxian --dry-run
python3 Tools/apply-host-patch.py --repo-root /path/to/Nyxian
\`\`\`

The script copies the four Objective-C files into Nyxian/LindChain/WindowServer/, then adds an import and one hook call to NXWindowServer.m. It refuses to overwrite files or patch an unfamiliar/partially patched source file.

The upstream project uses a synchronized Xcode source group, so new source files under the Nyxian folder should be discovered by Xcode automatically. Verify this in the project file and inspect git diff before building.

## Wallpaper

The overlay looks for an asset named LockHomeWallpaper. If it is absent, the overlay uses a built-in gradient background. Add the image to the Nyxian asset catalog manually if you want a custom wallpaper.

## Important limitations

- The supplied Nyxian.ipa contains the WindowServer headers but not its .m implementation source. The implementation is available in the public upstream repository, but its current source revision may not be byte-for-byte identical to the supplied Beta (0.11.5, build 20261014.2.RELEASE).
- This patch has not been compiled or runtime-tested against the supplied Beta IPA.
- The script modifies a source checkout only. It does not re-sign or modify a compiled IPA and does not modify the Procursus ROM.
- The first successful build must be done with the matching Xcode project, SDK and dependency setup. Review the diff and retain a clean rollback copy.
