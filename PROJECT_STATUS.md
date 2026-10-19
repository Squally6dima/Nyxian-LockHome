# Project status

Last updated: 2026-10-19

## Implemented in this repository

- UIKit lock-screen controller with large live time and date.
- Optional wallpaper image.
- Upward-swipe gesture that invokes a host-provided callback.
- Integration notes explaining where the component belongs.
- Lightweight source checks and GitHub Actions workflow.

## Not yet implemented / verified

- Integration into the actual Nyxian Beta 0.11.5 WindowServer/root UI.
- Real home/root transition (requires the matching host API).
- A compiled IPA, Debian package, or modified Procursus ROM.
- Runtime testing on the target Nyxian build.

## Why no binary is attached

The matching Beta host project and build environment have not been provided in this repository. Producing a binary without them would be misleading and could not establish compatibility. The next step is to integrate these source files into the matching host target and build/test there.
