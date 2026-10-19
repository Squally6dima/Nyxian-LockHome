# Integrating LockHome into Nyxian

The supplied Beta IPA and Procursus ROM were inspected. The IPA contains WindowServer headers but not the Objective-C implementation files; the ROM contains a compiled init executable and does not render the host UIKit interface.

For a source-level host-side UIKit patch, use the implementation and guarded patcher in [HostPatch](HostPatch/README.md).

## Quick start

1. Obtain a clean Nyxian source checkout matching the supplied Beta build as closely as possible.
2. Run \`python3 Tools/apply-host-patch.py --repo-root /path/to/Nyxian --dry-run\`.
3. If the expected source anchors match, run the same command without \`--dry-run\`.
4. Review \`git diff\`, build using Nyxian's normal macOS/Xcode workflow, and test on a disposable device.

The patch adds a full-window overlay above NXWindowServer's managed app layer. The overlay shows the date, large clock, optional wallpaper and home indicator, and dismisses on an upward swipe.

## Compatibility warning

The supplied IPA reports Nyxian 0.11.5, build \`20261014.2.RELEASE\`, and SDK metadata \`iphoneos27.0\`. The public upstream source implementation may not exactly match that binary. The patcher deliberately checks unique source anchors and refuses to patch an unfamiliar or partially patched file.

This repository does not yet contain a compiled, signed IPA or modified Procursus ROM. The patch is source code and has not been runtime-tested against the supplied beta build.
