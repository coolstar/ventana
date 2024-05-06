//
//  CSMetroLockScreenViewController.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSMetroLockScreenView.h"
#import "CSMetroLockScreenPasscodeView.h"
#import "CSMetroLockScreenViewControllerDelegate.h"

@class BBBulletin, BBAction, CSCombinedListViewController;
@interface CSMetroLockScreenViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	NSObject <CSMetroLockScreenViewControllerDelegate> *_delegate;
    UIView *_backgroundShade;
    UIScrollView *_mainScrollView;
    CSMetroLockScreenView *_lockScreenView;
    CSMetroLockScreenPasscodeView *_lockScreenPasscodeView;
    
    BOOL _respondToKeyboard;
    BOOL _dimTimerRunning;

    CSCombinedListViewController *_nativeController13;
}

@property (nonatomic, strong) NSObject <CSMetroLockScreenViewControllerDelegate> *delegate;
@property (nonatomic, readonly) CSMetroLockScreenView *lockScreenView;
@property (nonatomic, strong) CSCombinedListViewController *nativeController13;

+ (BOOL)springBoardInitialized;
+ (void)setSpringBoardInitialized:(BOOL)initialized;
+ (instancetype)sharedLockScreenController;
+ (UIImage *)imageNamed:(NSString *)name;

- (void)resetLock;
- (void)updateData;

- (void)unlock;
- (BOOL)unlockWithPasscode:(NSString *)passcode;

- (void)cancelDimTimer;
- (void)restartDimTimer;
- (void)restartDimTimerIfNeeded;

- (void)gotNativeNotificationController:(id)nativeController;

- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action context:(NSDictionary *)context;
- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action;
@end

