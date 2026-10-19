#import "NXLockScreenViewController.h"

@interface NXLockScreenViewController ()
@property (nonatomic, strong) UIImageView *wallpaperView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, nullable) NSTimer *clockTimer;
@end

@implementation NXLockScreenViewController

- (instancetype)initWithWallpaperImage:(UIImage *)wallpaperImage unlockHandler:(dispatch_block_t)unlockHandler {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _wallpaperImage = wallpaperImage;
        _unlockHandler = [unlockHandler copy];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.timeStyle = NSDateFormatterShortStyle;
        _timeFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale currentLocale];
        _dateFormatter.dateFormat = @"EEEE, d MMMM";
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.12 blue:0.22 alpha:1.0];

    self.wallpaperView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.wallpaperView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wallpaperView.image = self.wallpaperImage;
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    self.wallpaperView.clipsToBounds = YES;
    [self.view addSubview:self.wallpaperView];

    UIView *shade = [[UIView alloc] initWithFrame:CGRectZero];
    shade.translatesAutoresizingMaskIntoConstraints = NO;
    shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.20];
    shade.userInteractionEnabled = NO;
    [self.view addSubview:shade];

    self.dateLabel = [self labelWithSize:19 weight:UIFontWeightMedium];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dateLabel];

    self.timeLabel = [self labelWithSize:88 weight:UIFontWeightLight];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.minimumScaleFactor = 0.65;
    [self.view addSubview:self.timeLabel];

    self.hintLabel = [self labelWithSize:14 weight:UIFontWeightMedium];
    self.hintLabel.text = @"Swipe up to continue";
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.alpha = 0.88;
    [self.view addSubview:self.hintLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.wallpaperView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.wallpaperView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.wallpaperView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.wallpaperView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [shade.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [shade.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [shade.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [shade.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.dateLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.dateLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:34],
        [self.dateLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.dateLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.timeLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.timeLabel.topAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:2],
        [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.hintLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.hintLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-22]
    ]];

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipe];

    [self updateClock];
}

- (UILabel *)labelWithSize:(CGFloat)size weight:(UIFontWeight)weight {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.numberOfLines = 1;
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.25];
    label.shadowOffset = CGSizeMake(0, 1);
    return label;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.clockTimer invalidate];
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                       target:self
                                                     selector:@selector(updateClock)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.clockTimer invalidate];
    self.clockTimer = nil;
}

- (void)updateClock {
    NSDate *now = [NSDate date];
    self.timeLabel.text = [self.timeFormatter stringFromDate:now];
    self.dateLabel.text = [self.dateFormatter stringFromDate:now];
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateRecognized) return;
    if (self.unlockHandler) self.unlockHandler();
}

- (void)setWallpaperImage:(UIImage *)wallpaperImage {
    _wallpaperImage = wallpaperImage;
    if (self.isViewLoaded) self.wallpaperView.image = wallpaperImage;
}

- (void)dealloc {
    [_clockTimer invalidate];
}

@end
