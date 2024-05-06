#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"
#import "CSMetroNotificationsController.h"
#import "CSMetroLockScreenSettingsManager.h"
#import "BBBulletin.h"

static char *PasscodeBlurView;

%group iOS9
%hook SBLockScreenScrollView
- (void)setPasscodeView:(UIView *)passcodeView {
	%orig;
	SBWallpaperEffectView *wallpaperEffectView = (SBWallpaperEffectView *)objc_getAssociatedObject(self, &PasscodeBlurView);
	if (!wallpaperEffectView){
		wallpaperEffectView = [[%c(SBWallpaperEffectView) alloc] initWithFrame:passcodeView.frame];
		[self addSubview:wallpaperEffectView];
		[self sendSubviewToBack:wallpaperEffectView];
		objc_setAssociatedObject(self, &PasscodeBlurView, wallpaperEffectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	wallpaperEffectView.frame = passcodeView.frame;
	[wallpaperEffectView setStyle:3];
}
%end

%hook SBScreenFadeAnimationController
- (void) prepareToFadeInWithTimeAlpha:(float)timeAlpha dateAlpha:(float)alpha statusBarAlpha:(float)alpha3 lockScreenView:(id)view existingDateView:(id)view5 completion:(id)completion{
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0.0,0.0,alpha3,view,view5,completion);
	else
		%orig;
}
%end

%hook SBLockScreenNotificationListController
-(void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (bulletin.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"action":bulletin.defaultAction, @"response":@NO}];

		NSString *message = bulletin.message;
		if (bulletin.suppressesMessageForPrivacy)
			message = @"Message hidden.";

		NSString *sectionID = bulletin.sectionID;
		if (![sectionID isKindOfClass:[NSString class]]){
			sectionID = @"com.apple.springboard";
		}

		[[CSMetroNotificationsController sharedInstance] addNotificationWithIcon:image sectionID:sectionID title:bulletin.title message:message bulletin:bulletin request:nil buttons:buttons];
	}
}

//8.0+
- (void)observer:(id)observer addBulletin:(BBBulletin *)bulletin forFeed:(unsigned)feed playLightsAndSirens:(BOOL)sirens withReply:(id)reply {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (bulletin.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"action":bulletin.defaultAction, @"response":@NO}];
		for (BBAction *action in [bulletin supplementaryActions]){
			if ([action hasPluginAction])
				continue;
			if ([action hasRemoteViewAction])
				continue;

			NSNumber *response = @NO;
			if ([action respondsToSelector:@selector(behavior)]){
				if (action.behavior == UIUserNotificationActionBehaviorTextInput)
					response = @YES;
				else {
					if (action.activationMode == UIUserNotificationActivationModeBackground)
						continue;
				}
			} else {
				if (action.activationMode == UIUserNotificationActivationModeBackground)
						continue;
			}
			if (action.appearance.title != nil && action != nil && response != nil){
				[buttons addObject:@{@"title":action.appearance.title, @"action":action, @"response":response}];
			}
		}

		NSString *message = bulletin.message;
		if (bulletin.suppressesMessageForPrivacy)
			message = @"Message hidden.";

		NSString *sectionID = bulletin.sectionID;
		if (![sectionID isKindOfClass:[NSString class]]){
			sectionID = @"com.apple.springboard";
		}

		[[CSMetroNotificationsController sharedInstance] addNotificationWithIcon:image sectionID:sectionID title:bulletin.title message:message bulletin:bulletin request:nil buttons:buttons];
	}
}

-(void)observer:(id)observer removeBulletin:(BBBulletin *)bulletin {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[[CSMetroNotificationsController sharedInstance] removeNotificationWithBulletin:bulletin];
	}
}

-(void)observer:(id)observer modifyBulletin:(BBBulletin *)bulletin {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (bulletin.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"action":bulletin.defaultAction, @"response":@NO}];
		if ([bulletin respondsToSelector:@selector(supplementaryActions)]){
			for (BBAction *action in [bulletin supplementaryActions]){
				if ([action respondsToSelector:@selector(behavior)]){
					if (action.behavior == UIUserNotificationActionBehaviorTextInput){
						if (action.appearance.title != nil && action != nil){
							[buttons addObject:@{@"title":action.appearance.title, @"action":action, @"response":@YES}];
						}
					}
				}
			}
		}

		NSString *message = bulletin.message;
		if (bulletin.suppressesMessageForPrivacy)
			message = @"Message hidden.";

		NSString *sectionID = bulletin.sectionID;
		if (![sectionID isKindOfClass:[NSString class]]){
			sectionID = @"com.apple.springboard";
		}
	
		[[CSMetroNotificationsController sharedInstance] modifyNotificationWithIcon:image sectionID:sectionID title:bulletin.title message:message bulletin:bulletin request:nil buttons:buttons];
	}
}
%end

%hook SBLockScreenViewController

-(void)setInScreenOffMode:(BOOL)screenOffMode {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
		if ([self isPasscodeLockVisible]){
			statusBar.alpha = 1.0f;
		} else {
			statusBar.alpha = 0.0f;
		}
	}
}

- (CGFloat)_effectiveVisibleStatusBarAlpha {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		if ([self isPasscodeLockVisible]){
			return %orig;
		} else {
			return 0.0f;
		}
	}
    return %orig;
}

- (BOOL)prefersStatusBarHidden {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
    	return YES;
    return %orig;
}

- (int)statusBarStyle {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}

- (BOOL)showsSpringBoardStatusBar {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return NO;
	return %orig;
}

%new
- (BOOL)unlockWithPasscode:(NSString *)passcode {
	BOOL success = [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:passcode];
	if (success){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		[controller.view removeFromSuperview];
		controller.delegate = nil;
	}
	return success;
}

%new
- (BOOL)unlock {
	BOOL success = [[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:nil];
	if (success){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		[controller.view removeFromSuperview];
		controller.delegate = nil;
	}
	return success;
}

- (void)loadView {
	%orig;

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (!selfVerify()){
			safeMode();
		}
		if (!deepVerifyUDID()){
			safeMode();
		}
	});
	
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *x in [self lockScreenView].subviews){
			[x setAlpha:0];
		}
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		[controller.view removeFromSuperview];
		controller.view.alpha = 1;
		[controller resetLock];
		controller.view.frame = [self lockScreenView].bounds;
		controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		controller.view.layer.zPosition = 100;
		controller.delegate = self;
		[[self lockScreenView] addSubview:controller.view];
		[controller viewDidAppear:NO];

		[self setPasscodeLockVisible:NO animated:NO completion:nil];
	}
}

-(void)_handleDisplayTurnedOff {
	[self setPasscodeLockVisible:NO animated:NO completion:nil];
	%orig;
}

- (void)activate {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *view in self.view.subviews){
			if (view != [[CSMetroLockScreenViewController sharedLockScreenController] view]){
				view.alpha = 0;
			}
		}
	}
	CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
	[controller viewDidAppear:NO];
	controller.view.alpha = 1;
	[controller resetLock];

	[self setPasscodeLockVisible:NO animated:NO completion:nil];
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end

%hook SBLockScreenView

-(void)setTopBottomGrabbersHidden:(BOOL)hidden forRequester:(NSString *)requester {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		return;
	}
	%orig;
}

-(void)setForegroundHidden:(BOOL)hidden forRequester:(id)requester {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		return;
	}
	%orig;
}

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		for (UIView *view in self.subviews){
			if (view != [[CSMetroLockScreenViewController sharedLockScreenController] view]){
				view.alpha = 0;
			}
		}

		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		if (controller.view.alpha == 0){
			[[[self scrollView] superview] setAlpha:1.0f];
		}
	}
	[[CSMetroLockScreenViewController sharedLockScreenController] viewDidAppear:NO];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];

		NSInteger pageNumber = page;
		if ([self respondsToSelector:@selector(pageNumberForLockScreenPage:)])
			pageNumber = [self pageNumberForLockScreenPage:page];
		BOOL visible = (pageNumber == 0);
		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
		if (visible) {
			%orig(page, NO, nil);
			[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
				[[[self scrollView] superview] setAlpha:1.0f];
				[self scrollView].scrollEnabled = NO;
				controller.view.alpha = 0.0f;
				statusBar.alpha = 1.0f;
				[[self passcodeView] setBackgroundAlpha:0.73];
			} completion:completion];
		} else {
			[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
				[[[self scrollView] superview] setAlpha:0.0f];
				[self scrollView].scrollEnabled = YES;
				controller.view.alpha = 1.0f;
				statusBar.alpha = 0.0f;
			} completion:^(BOOL finished2){
				%orig(page, NO, completion);
			}];
		}
	} else {
		%orig;
	}
}
%end

%hook SBLockScreenHintManager
- (CGRect)_cameraGrabberZone {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return CGRectZero;
	else
		return %orig;
}
%end

%hook SBLockOverlayStyleProperties
- (float)blurRadius {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}

- (float)tintAlpha {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return 0;
	return %orig;
}
%end
%end

%ctor {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (kCFCoreFoundationVersionNumber < 1300){
			%init(iOS9);
			if (!selfVerify()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.metrolockscreen.license");
				unlink("/usr/lib/cslicenses/org.coolstar.metrolockscreen.license");
#if __LP64__
#else
				unlink("/var/mobile/Library/Preferences/org.coolstar.metrolockscreen.license.signed");
				unlink("/usr/lib/cslicenses/org.coolstar.metrolockscreen.license.signed");
#endif
				safeMode();
			}
			if (!deepVerifyUDID()){
				unlink("/var/mobile/Library/Preferences/org.coolstar.metrolockscreen.license");
				unlink("/usr/lib/cslicenses/org.coolstar.metrolockscreen.license");
#if __LP64__
#else
				unlink("/var/mobile/Library/Preferences/org.coolstar.metrolockscreen.license.signed");
				unlink("/usr/lib/cslicenses/org.coolstar.metrolockscreen.license.signed");
#endif
				safeMode();
			}
		}
	});
}