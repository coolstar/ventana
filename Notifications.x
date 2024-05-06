#import "CSMetroLockScreenViewController.h"
#import "CSMetroNotificationsController.h"

%hook SBLockScreenManager
-(void)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	[[CSMetroNotificationsController sharedInstance] clearNotifications];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[CSMetroLockScreenViewController sharedLockScreenController] resetLock];
	});
	%orig;
}
%end