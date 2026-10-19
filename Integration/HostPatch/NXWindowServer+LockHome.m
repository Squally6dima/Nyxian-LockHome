/*
 SPDX-License-Identifier: AGPL-3.0-or-later
 Copyright (C) 2026 Nyxian-LockHome contributors
 */

#import "NXWindowServer+LockHome.h"
#import "NXLockHomeOverlayView.h"
#import <objc/runtime.h>

static char NXLockHomeOverlayAssociationKey;
static char NXLockHomeShownOnceAssociationKey;

@implementation NXWindowServer (NXLockHome)

- (void)nx_showLockHomeOnFirstPresentation {
    NSAssert([NSThread isMainThread], @"NXLockHome must be shown on the main thread");

    NSNumber *shown = objc_getAssociatedObject(self, &NXLockHomeShownOnceAssociationKey);
    if (shown.boolValue) return;

    objc_setAssociatedObject(self, &NXLockHomeShownOnceAssociationKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self nx_showLockHome];
}

- (void)nx_showLockHome {
    NSAssert([NSThread isMainThread], @"NXLockHome must be shown on the main thread");

    NXLockHomeOverlayView *existing = objc_getAssociatedObject(self, &NXLockHomeOverlayAssociationKey);
    if (existing && existing.superview == self) {
        [self bringSubviewToFront:existing];
        return;
    }

    UIImage *wallpaper = [UIImage imageNamed:@"LockHomeWallpaper"];
    NXLockHomeOverlayView *overlay = [[NXLockHomeOverlayView alloc] initWithWallpaperImage:wallpaper
                                                                           unlockHandler:nil];
    __weak typeof(self) weakWindowServer = self;
    __weak NXLockHomeOverlayView *weakOverlay = overlay;

    overlay.unlockHandler = ^{
        NXWindowServer *windowServer = weakWindowServer;
        NXLockHomeOverlayView *lockView = weakOverlay;
        if (!windowServer || !lockView) return;

        [UIView animateWithDuration:0.28
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            lockView.alpha = 0.0;
            lockView.transform = CGAffineTransformMakeTranslation(0, -MAX(80.0, CGRectGetHeight(lockView.bounds) * 0.16));
        } completion:^(BOOL finished) {
            [lockView removeFromSuperview];
            if (objc_getAssociatedObject(windowServer, &NXLockHomeOverlayAssociationKey) == lockView) {
                objc_setAssociatedObject(windowServer, &NXLockHomeOverlayAssociationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }];
    };

    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    overlay.alpha = 1.0;
    overlay.transform = CGAffineTransformIdentity;
    objc_setAssociatedObject(self, &NXLockHomeOverlayAssociationKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:overlay];
    [NSLayoutConstraint activateConstraints:@[
        [overlay.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [overlay.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [overlay.topAnchor constraintEqualToAnchor:self.topAnchor],
        [overlay.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    [self bringSubviewToFront:overlay];
}

@end
