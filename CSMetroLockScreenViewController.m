//
//  CSMetroLockScreenViewController.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenViewController.h"
#import "Headers.h"
#import "BBBulletin.h"
#import "CSMetroLockScreenSettingsManager.h"

/*#if TARGET_IPHONE_SIMULATOR
#define passcodeIsEnabled YES
#else*/
#define passcodeIsEnabled [[objc_getClass("MCPasscodeManager") sharedManager] isDeviceLocked] && [[objc_getClass("MCPasscodeManager") sharedManager] isPasscodeSet]
//#endif

@interface CSMetroLockScreenViewController ()

@end

static BOOL springBoardInitialized = NO;
static CSMetroLockScreenViewController *sharedObject = nil;

@implementation CSMetroLockScreenViewController

//iOS 13 fix
- (BOOL)_canShowWhileLocked {
    return YES;
}

+ (BOOL)springBoardInitialized {
    return springBoardInitialized;
}

+ (void)setSpringBoardInitialized:(BOOL)initialized {
    springBoardInitialized = initialized;
}

+ (instancetype)sharedLockScreenController {
    if (!sharedObject)
        sharedObject = [[self alloc] init];
    return sharedObject;
}

- (void)loadView {
    if (!verifyUDID())
        safeMode();

    if (kCFCoreFoundationVersionNumber < 1348)
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    else
        self.view = [[objc_getClass("SBFTouchPassThroughView") alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
#if TARGET_IPHONE_SIMULATOR
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [background setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wallpaper55" ofType:@"jpg"]]];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:background];
#endif
    
    if (kCFCoreFoundationVersionNumber < 1348){
        _backgroundShade = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundShade.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_backgroundShade];
    }
    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mainScrollView setDelegate:self];
    [self.view addSubview:_mainScrollView];

    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnScrollView:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    singleTapGestureRecognizer.enabled = YES;
    singleTapGestureRecognizer.cancelsTouchesInView = NO;
    singleTapGestureRecognizer.delegate = self;
    [_mainScrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    _lockScreenView = [[CSMetroLockScreenView alloc] initWithFrame:self.view.bounds];
    _lockScreenView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_mainScrollView addSubview:_lockScreenView];
    
    /*if (kCFCoreFoundationVersionNumber < 1348){
        _lockScreenPasscodeView = [[CSMetroLockScreenPasscodeView alloc] initWithFrame:self.view.bounds];
        _lockScreenPasscodeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_mainScrollView addSubview:_lockScreenPasscodeView];
    }*/
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![[CSMetroLockScreenSettingsManager sharedInstance] bounceOnTap])
        return NO;
    if (_mainScrollView.contentSize.height == _mainScrollView.bounds.size.height)
        return NO;
    if ([touch.view isDescendantOfView:_lockScreenView.mediaControlsView]) {
        return NO;
    }
    if ([touch.view isKindOfClass:objc_getClass("UITableViewCell")]) {
        return NO;
    }
    if ([touch.view isKindOfClass:objc_getClass("UITextField")]) {
        return NO;
    }
    if ([touch.view isKindOfClass:objc_getClass("UIButton")]) {
        return NO;
    }
    if ([touch.view isKindOfClass:objc_getClass("PKGlyphView")]) {
        return NO;
    }
    return YES;
}

- (void)singleTapOnScrollView:(id)sender {
    if (_mainScrollView.contentOffset.y == 0){
        [_mainScrollView setUserInteractionEnabled:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                [_mainScrollView setContentOffset:CGPointMake(0,75)];
            } completion:^(BOOL completed){
                [UIView animateWithDuration:0.4 animations:^{
                    [_mainScrollView setContentOffset:CGPointZero];
                    [_mainScrollView setUserInteractionEnabled:YES];
                }];
            }];
        });
    }
}

- (void)gotNativeNotificationController:(id)nativeController {
    NCNotificationCombinedListViewController *priorityListViewController = nativeController;
    [priorityListViewController.view removeFromSuperview];
    [priorityListViewController removeFromParentViewController];
    if (nativeController){
        [self addChildViewController:priorityListViewController];
        [_lockScreenView addSubview:priorityListViewController.view];
    }
    _lockScreenView.nativeNotificationView = priorityListViewController.view;

    if ([priorityListViewController isKindOfClass:objc_getClass("NCNotificationStructuredListViewController")]){
        _lockScreenView.nativeNotificationView11 = priorityListViewController.masterListView;
        _lockScreenView.nativeController = priorityListViewController;
    } else if ([priorityListViewController isKindOfClass:objc_getClass("NCNotificationCombinedListViewController")]){
        _lockScreenView.nativeNotificationView11 = priorityListViewController.collectionView;
        _lockScreenView.nativeController = priorityListViewController;
    } else {
        _lockScreenView.nativeNotificationView11 = nil;
        _lockScreenView.nativeController = nil;
    }

    [_lockScreenView layoutSubviews];
}

+ (UIImage *)imageNamed:(NSString *)name {
#if TARGET_IPHONE_SIMULATOR
    NSString *fullName = [@"assets/" stringByAppendingString:name];
    return [UIImage imageNamed:fullName];
#else
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/MetroLockScreen.bundle"];
    return [UIImage imageNamed:name inBundle:bundle];
#endif
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat alpha = 0;
    alpha = scrollView.contentOffset.y/scrollView.bounds.size.height;
    [_lockScreenView setAlpha:MAX(1.0f - alpha * 2.0, 0.0f)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y != scrollView.bounds.size.height)
        return;
    
    __unsafe_unretained CSMetroLockScreenViewController *weakSelf = self;

    if (passcodeIsEnabled){
        [self.delegate setPasscodeLockVisible:YES animated:YES completion:^(BOOL success){
            [weakSelf resetLock];
        }];
    } else {
        [self unlock];
    }
}

- (void)unlock {
    [self.delegate unlock];
    _respondToKeyboard = NO;
}

- (BOOL)unlockWithPasscode:(NSString *)passcode {
    if ([self.delegate unlockWithPasscode:passcode]){
        _respondToKeyboard = NO;
        return YES;
    }
    return NO;
}

- (void)resetLock {
    if (!verifyUDID())
        safeMode();

    [self restartDimTimer];
    
    _mainScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
    _mainScrollView.contentOffset = CGPointZero;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _lockScreenView.alpha = 1.0;
    _lockScreenPasscodeView.alpha = 0;
    [_backgroundShade setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];
    
    _respondToKeyboard = YES;
    
    [_lockScreenView resetLock];
    [_lockScreenPasscodeView resetLock];
#if TARGET_IPHONE_SIMULATOR
#else
    [[objc_getClass("SBWiFiManager") sharedInstance] _updateWiFiState];
    [[objc_getClass("SBTelephonyManager") sharedTelephonyManager] updateSpringBoard];
#endif

    NCNotificationPriorityListViewController *priorityListViewController = [objc_getClass("NCNotificationPriorityListViewController") lastInstance];
    if (priorityListViewController){
        [priorityListViewController.view removeFromSuperview];
        [priorityListViewController removeFromParentViewController];
        [self addChildViewController:priorityListViewController];
        [_lockScreenView addSubview:priorityListViewController.view];
        _lockScreenView.nativeNotificationView = priorityListViewController.view;
        [_lockScreenView layoutSubviews];
    }
}

- (void)cancelDimTimer {
#if TARGET_IPHONE_SIMULATOR
#else
    if ([[objc_getClass("SBBacklightController") sharedInstance] respondsToSelector:@selector(cancelLockScreenIdleTimer)]){
        _dimTimerRunning = NO;
        [[objc_getClass("SBBacklightController") sharedInstance] cancelLockScreenIdleTimer];
    }
#endif
}

- (void)restartDimTimer {
#if TARGET_IPHONE_SIMULATOR
#else
    if ([[objc_getClass("SBBacklightController") sharedInstance] respondsToSelector:@selector(resetLockScreenIdleTimer)]){
        _dimTimerRunning = YES;
        [[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
    } else {
        [_delegate resetLockScreenIdleTimer];
    }
#endif
}

- (void)restartDimTimerIfNeeded {
    if (_dimTimerRunning)
        [self restartDimTimer];
}

- (void)updateData {
    [_lockScreenView updateData];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetLock];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action context:(NSDictionary *)context {
    if (action.activationMode == UIUserNotificationActivationModeForeground){
        SBLockScreenActionContextFactory *actionContextFactory = [objc_getClass("SBLockScreenActionContextFactory") sharedInstance];
        SBLockScreenActionContext *actionContext = nil;
        if ([actionContextFactory respondsToSelector:@selector(lockScreenActionContextForBulletin:action:origin:pluginActionsAllowed:context:completion:)])
            actionContext = [actionContextFactory lockScreenActionContextForBulletin:bulletin action:action origin:0 pluginActionsAllowed:YES context:context completion:nil];
        else {
            actionContext = [[objc_getClass("SBLockScreenActionContext") alloc] initWithLockLabel:[bulletin fullUnlockActionLabel] shortLockLabel:[bulletin unlockActionLabel] action:[action internalBlock] identifier:[action identifier]];
            actionContext.canBypassPinLock = NO;
            actionContext.requiresAuthentication = YES;
            actionContext.deactivateAwayController = YES;
        }

        if ([_delegate respondsToSelector:@selector(setUnlockActionContext:)])
            [_delegate setUnlockActionContext:actionContext];
        else
            [_delegate setCustomLockScreenActionContext:actionContext];

        __unsafe_unretained CSMetroLockScreenViewController *weakSelf = self;

        if (passcodeIsEnabled){
            [self.delegate setPasscodeLockVisible:YES animated:YES completion:^(BOOL success){
                [weakSelf resetLock];
            }];
        } else {
            [self unlock];
        }
    }
}

- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action {
    NCNotificationCombinedListViewController *nativeController = _lockScreenView.nativeController;
    if ([nativeController respondsToSelector:@selector(destinationDelegate)]){
        [nativeController.destinationDelegate notificationListViewController:nativeController requestsExecuteAction:action forNotificationRequest:request requestAuthentication:YES withParameters:[NSDictionary dictionary] completion:nil];
    } else {
        [_nativeController13 notificationStructuredListViewController:nativeController requestsExecuteAction:action forNotificationRequest:request requestAuthentication:YES withParameters:[NSDictionary dictionary] completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
