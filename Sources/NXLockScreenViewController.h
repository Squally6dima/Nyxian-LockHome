#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A host-side lock-screen view. The host application owns the unlock transition.
@interface NXLockScreenViewController : UIViewController

/// Called after the user completes an upward swipe. The host must implement the real transition.
@property (nonatomic, copy, nullable) dispatch_block_t unlockHandler;

/// Optional wallpaper image. If nil, a dark gradient-like fallback background is used.
@property (nonatomic, strong, nullable) UIImage *wallpaperImage;

- (instancetype)initWithWallpaperImage:(nullable UIImage *)wallpaperImage
                         unlockHandler:(nullable dispatch_block_t)unlockHandler NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
