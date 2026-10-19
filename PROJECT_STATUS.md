# Project status

Updated: 2026-10-19

## Examined input files

- Nyxian.ipa: app version 0.11.5, build 20261014.2.RELEASE, SDK metadata iphoneos27.0.
- procursus-jailed.zip: Procursus Jailed ROM v1.0 manifest, requiring Nyxian 0.11.5; includes ROM/System/Rom/init, bootstrap daemon, wallpaper images, and binpack.

The IPA contains NXWindowServer.h and related headers under Payload/Nyxian.app/Shared/kernel/LindChain/WindowServer/, but the implementation .m files are not shipped in the IPA. The ROM archive has no WindowServer UI source. Therefore neither archive can be directly rebuilt as a source project by itself.

## Added

- A UIKit NXLockHomeOverlayView that draws the lock screen, date/time, optional wallpaper and swipe-up unlock gesture.
- An NXWindowServer category that presents the overlay above Nyxian's managed window layer.
- A guarded patch script for a source checkout. It validates anchors and refuses to overwrite conflicting files.
- Integration documentation and basic patch-script tests.

## Not yet verified

- The public upstream source revision may differ from the supplied beta build.
- The patch has not been compiled against the matching project/SDK and has not been run inside Nyxian.
- No modified IPA, signed installable app, .deb, or ROM image is produced by this source-only patch.

## Next verification

1. Apply the patch to a clean, matching Nyxian source checkout.
2. Review git diff.
3. Build with the project's normal macOS/Xcode workflow.
4. Test startup, orientation, swipe threshold, wallpaper fallback, and recovery/rollback before replacing the installed build.
