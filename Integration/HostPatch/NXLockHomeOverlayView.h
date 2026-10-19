/*
 SPDX-License-Identifier: AGPL-3.0-or-later
 Copyright (C) 2026 Nyxian-LockHome contributors
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A full-window lock overlay. The host owns the meaning of the unlock callback.
@interface NXLockHomeOverlayView : UIView

@property (nonatomic, copy, nullable) dispatch_block_t unlockHandler;
@property (nonatomic, strong, nullable) UIImage *wallpaperImage;

/// Pass nil for a dark gradient fallback when no wallpaper asset is installed.
- (instancetype)initWithWallpaperImage:(nullable UIImage *)wallpaperImage
                         unlockHandler:(nullable dispatch_block_t)unlockHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
