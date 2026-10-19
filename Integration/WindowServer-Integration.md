# Integrating LockHome into Nyxian

## Important architecture note

This UI is a UIKit component, not a patch to the compiled Procursus `System/Rom/init`. It must be presented by the **host-side process that owns Nyxian's window/app presentation**. A tweak injected into one guest app cannot create a global lock screen over the whole Nyxian environment.

## Host integration steps

1. Open the exact Nyxian Beta 0.11.5 host project and identify the process/controller that owns the app surface and root/home presentation.
2. Add `Sources/NXLockScreenViewController.h` and `.m` to that target. Ensure ARC is enabled.
3. Present the lock screen after the host UI is initialized:
   ```objc
   UIImage *wallpaper = [UIImage imageNamed:@"LockHomeWallpaper"];
   __weak typeof(self) weakSelf = self;
   NXLockScreenViewController *lockVC =
       [[NXLockScreenViewController alloc] initWithWallpaperImage:wallpaper
                                                   unlockHandler:^{
           [weakSelf dismissViewControllerAnimated:YES completion:^{
               // TODO: call Nyxian's actual home/root presentation method here.
           }];
       }];
   [self presentViewController:lockVC animated:NO completion:nil];
   ```
   Replace `self` with the actual host controller and implement the TODO using Nyxian's real home/root API.
4. Add a wallpaper image named `LockHomeWallpaper` to the target's asset catalog, or pass `nil` to use the fallback background.
5. Build for the same deployment target and architectures as the Nyxian host. Do not copy the component into the guest Procursus filesystem expecting it to launch automatically.
6. Test swipe-up, rotation/layout, VoiceOver, and dismissal on a disposable test environment before replacing any existing build.

## What is still needed for a working Nyxian build

- Matching Beta 0.11.5 host source/project (the beta build identifier reported was `20261014.2.RELEASE`).
- The actual root/home presentation API and the correct initialization point.
- A build/test environment for the matching target.

This repository does not currently include those private project files and therefore cannot claim a working integrated IPA/ROM yet.
