# Nyxian LockHome

iOS-style lock-screen prototype for **Nyxian Beta 0.11.5**.

> Status: source prototype / integration work in progress. This repository does not contain a verified build for the user's private Nyxian Beta build. The component must be integrated into Nyxian's own WindowServer/root presentation layer; injecting a tweak into a guest app alone will not add a lock screen to the whole environment.

## Goals

- Full-screen lock screen with a large live clock, date, and wallpaper.
- Swipe-up gesture to invoke the host's unlock callback.
- No private device data, credentials, or serial numbers.
- Safe integration seam: the host decides what "unlock" means and presents its own home/root UI.
- Build and integration notes for Nyxian Beta 0.11.5.

## Repository layout

- `Sources/NXLockScreenViewController.h/.m` — UIKit lock-screen component, including swipe-up detection.
- `Integration/WindowServer-Integration.md` — host integration checklist.
- `Tests/SourceChecks.sh` — basic source sanity checks.

## Integration model

The feature belongs in Nyxian's **host-side WindowServer presentation layer**. Present `NXLockScreenViewController` as a full-screen view/controller over the host's app surface. Provide an unlock handler that dismisses the lock screen and switches to Nyxian's home/root presentation. Do not assume UIKit/SwiftUI APIs can be called directly from the compiled ROM `System/Rom/init`; that executable is not the place to render this UI.

This repository deliberately avoids pretending an ordinary jailed-app tweak can modify Nyxian's global WindowServer. The exact integration point must be confirmed against the matching 0.11.5 Beta source/build.

## Requirements

- Xcode / iOS SDK compatible with the Nyxian host app's deployment target.
- The matching Nyxian Beta 0.11.5 host source and its build settings.
- A wallpaper image supplied by the integrator (the controller can also render without one).

## Current limitations

- This is not a compiled `.deb`, IPA, or modified Procursus ROM.
- Camera/flashlight shortcuts are not shown because no Nyxian host callbacks are defined for those actions.
- The component has not been tested inside the private Beta build. Run the source checks and build in the matching host project before deploying.

## License

No upstream Nyxian code is copied into this repository at this stage. The original prototype files in this repository are licensed under MIT; that license does not apply to Nyxian itself.
