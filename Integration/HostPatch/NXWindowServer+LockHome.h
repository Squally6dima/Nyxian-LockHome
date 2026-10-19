/*
 SPDX-License-Identifier: AGPL-3.0-or-later
 Copyright (C) 2026 Nyxian-LockHome contributors
 */

#import <LindChain/WindowServer/NXWindowServer.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXWindowServer (NXLockHome)

/// Show the lock overlay above the host window and all managed application windows.
- (void)nx_showLockHome;

/// Called by the source patch on first WindowServer presentation only.
- (void)nx_showLockHomeOnFirstPresentation;

@end

NS_ASSUME_NONNULL_END
