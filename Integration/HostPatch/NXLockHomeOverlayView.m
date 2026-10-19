/*
 SPDX-License-Identifier: AGPL-3.0-or-later
 Copyright (C) 2026 Nyxian-LockHome contributors
 */

#import "NXLockHomeOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@interface NXLockHomeOverlayView ()
@property (nonatomic, strong) CAGradientLayer *fallbackGradient;
@property (nonatomic, strong) UIImageView *wallpaperView;
@property (nonatomic, strong) UIView *shadeView;
@property (nonatomic, strong) UIImageView *lockIconView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIView *homeIndicatorView;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, nullable) NSTimer *clockTimer;
@property (nonatomic) BOOL unlockTriggered;
@end

@implementation NXLockHomeOverlayView

- (instancetype)initWithWallpaperImage:(UIImage *)wallpaperImage
                         unlockHandler:(dispatch_block_t)unlockHandler {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _wallpaperImage = wallpaperImage;
        _unlockHandler = [unlockHandler copy];
        self.backgroundColor = [UIColor colorWithRed:0.07 green:0.10 blue:0.17 alpha:1.0];
        self.clipsToBounds = YES;
        self.accessibilityViewIsModal = YES;

        [self buildViews];
        [self updateClock];
    }
    return self;
}

- (void)buildViews {
    self.fallbackGradient = [CAGradientLayer layer];
    self.fallbackGradient.colors = @[
        (id)[UIColor colorWithRed:0.15 green:0.23 blue:0.40 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.04 green:0.07 blue:0.14 alpha:1.0].CGColor
    ];
    self.fallbackGradient.startPoint = CGPointMake(0.15, 0.0);
    self.fallbackGradient.endPoint = CGPointMake(0.85, 1.0);
    [self.layer insertSublayer:self.fallbackGradient atIndex:0];

    self.wallpaperView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.wallpaperView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wallpaperView.image = self.wallpaperImage;
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    self.wallpaperView.clipsToBounds = YES;
    [self addSubview:self.wallpaperView];

    self.shadeView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shadeView.translatesAutoresizingMaskIntoConstraints = NO;
    self.shadeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.24];
    self.shadeView.userInteractionEnabled = NO;
    [self addSubview:self.shadeView];

    self.lockIconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"lock.fill"]];
    self.lockIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.lockIconView.tintColor = [UIColor colorWithWhite:1 alpha:0.94];
    self.lockIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.lockIconView];

    self.dateLabel = [self makeLabelWithSize:19 weight:UIFontWeightMedium];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
    [self addSubview:self.dateLabel];

    self.timeLabel = [self makeLabelWithSize:88 weight:UIFontWeightUltraLight];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.58;
    self.timeLabel.accessibilityTraits = UIAccessibilityTraitStaticText;
    [self addSubview:self.timeLabel];

    self.hintLabel = [self makeLabelWithSize:14 weight:UIFontWeightMedium];
    self.hintLabel.text = NSLocalizedString(@"Swipe up to unlock", @"Lock screen swipe hint");
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.alpha = 0.9;
    [self addSubview:self.hintLabel];

    self.homeIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.homeIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.homeIndicatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.92];
    self.homeIndicatorView.layer.cornerRadius = 2.5;
    self.homeIndicatorView.userInteractionEnabled = NO;
    [self addSubview:self.homeIndicatorView];

    [NSLayoutConstraint activateConstraints:@[
        [self.wallpaperView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.wallpaperView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.wallpaperView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.wallpaperView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.shadeView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.shadeView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.shadeView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.shadeView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [self.lockIconView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.lockIconView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:26],
        [self.lockIconView.widthAnchor constraintEqualToConstant:16],
        [self.lockIconView.heightAnchor constraintEqualToConstant:18],

        [self.dateLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.lockIconView.bottomAnchor constant:24],
        [self.dateLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:18],
        [self.dateLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-18],

        [self.timeLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.timeLabel.topAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:2],
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],

        [self.homeIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.homeIndicatorView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:9],
        [self.homeIndicatorView.widthAnchor constraintEqualToConstant:134],
        [self.homeIndicatorView.heightAnchor constraintEqualToConstant:5],

        [self.hintLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.hintLabel.bottomAnchor constraintEqualToAnchor:self.homeIndicatorView.topAnchor constant:-18],
        [self.hintLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:20],
        [self.hintLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-20]
    ]];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipePan:)];
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    pan.cancelsTouchesInView = YES;
    [self addGestureRecognizer:pan];
}

- (UILabel *)makeLabelWithSize:(CGFloat)size weight:(UIFontWeight)weight {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 1;
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.22];
    label.shadowOffset = CGSizeMake(0, 1);
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fallbackGradient.frame = self.bounds;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self.clockTimer invalidate];
    self.clockTimer = nil;

    if (self.window != nil) {
        [self updateClock];
        __weak typeof(self) weakSelf = self;
        self.clockTimer = [NSTimer timerWithTimeInterval:15.0 repeats:YES block:^(NSTimer *timer) {
            [weakSelf updateClock];
        }];
        [[NSRunLoop mainRunLoop] addTimer:self.clockTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updateClock {
    NSDate *now = [NSDate date];
    if (!self.timeFormatter) {
        self.timeFormatter = [[NSDateFormatter alloc] init];
        self.timeFormatter.timeStyle = NSDateFormatterShortStyle;
        self.timeFormatter.dateStyle = NSDateFormatterNoStyle;
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.locale = [NSLocale currentLocale];
        self.dateFormatter.dateStyle = NSDateFormatterFullStyle;
        self.dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.timeLabel.text = [self.timeFormatter stringFromDate:now];

    // The date formatter is allowed to localize the date instead of hardcoding English.
    self.dateLabel.text = [self.dateFormatter stringFromDate:now];
}

- (void)handleSwipePan:(UIPanGestureRecognizer *)pan {
    if (self.unlockTriggered) return;

    CGPoint translation = [pan translationInView:self];
    CGPoint velocity = [pan velocityInView:self];

    if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat upwardOffset = MIN(0, translation.y);
        self.transform = CGAffineTransformMakeTranslation(0, upwardOffset * 0.45);
        self.alpha = MAX(0.72, 1.0 + upwardOffset / 1100.0);
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        if (translation.y < -90.0 || velocity.y < -550.0) {
            self.unlockTriggered = YES;
            if (self.unlockHandler) {
                self.unlockHandler();
            }
        } else {
            [self resetSwipePosition];
        }
    } else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        [self resetSwipePosition];
    }
}

- (void)resetSwipePosition {
    [UIView animateWithDuration:0.22
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1.0;
    } completion:nil];
}

- (void)setWallpaperImage:(UIImage *)wallpaperImage {
    _wallpaperImage = wallpaperImage;
    if (self.wallpaperView != nil) {
        self.wallpaperView.image = wallpaperImage;
    }
}

- (void)dealloc {
    [self.clockTimer invalidate];
}

@end
