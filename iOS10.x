#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"
#import "CSMetroNotificationsController.h"
#import "CSMetroLockScreenSettingsManager.h"
#import "BBBulletin.h"
#import <dlfcn.h>

static NCNotificationPriorityListViewController *LastPriorityControllerInstance;

%group iOS10
%hook NCNotificationPriorityListViewController
%new;
+ (instancetype)lastInstance {
	return LastPriorityControllerInstance;
}

//8.0+
- (BOOL)insertNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	BOOL ret = %orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return ret;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		BBBulletin *bulletin = request.bulletin;

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
			if (action.behavior == UIUserNotificationActionBehaviorTextInput)
				response = @YES;
			else {
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
	return ret;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		BBBulletin *bulletin = request.bulletin;
		[[CSMetroNotificationsController sharedInstance] removeNotificationWithBulletin:bulletin];
	}
}

- (BOOL)modifyNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	BOOL ret = %orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return ret;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		BBBulletin *bulletin = request.bulletin;
		NSString *bundleID = bulletin.sectionID;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (bulletin.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"action":bulletin.defaultAction, @"response":@NO}];
		for (BBAction *action in [bulletin supplementaryActions]){
			if (action.behavior == UIUserNotificationActionBehaviorTextInput){
				if (action.appearance.title != nil && action != nil){
					[buttons addObject:@{@"title":action.appearance.title, @"action":action, @"response":@YES}];
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
	return ret;
}
%end

%hook SBDashBoardPageControl

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		self.hidden = YES;
	else
		self.hidden = NO;
}

%end

%hook SBScreenFadeAnimationController
- (void)prepareToFadeInForSource:(NSInteger)source timeAlpha:(CGFloat)timeAlpha dateAlpha:(CGFloat)dateAlpha statusBarAlpha:(CGFloat)statusBarAlpha delegate:(id)delegate existingDateView:(id)existingDateView completion:(id)completion {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			statusBarAlpha = 0.0f;
		%orig(source, 0.0, 0.0, statusBarAlpha, delegate, existingDateView, completion);
	}
	else
		%orig;
}
%end

%hook SBDashBoardView
- (void)_layoutDateTimeViewClippingView {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		%orig;
		CGFloat targetX = [self scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - (self.bounds.size.width * [self _indexOfMainPage]))/self.bounds.size.width);

		UIView *dateTimeClippingView = [self valueForKey:@"_dateTimeClippingView"];
		UIView *dateView = [self valueForKey:@"_dateView"];
		dateView.alpha = backgroundChange;
		dateTimeClippingView.alpha = backgroundChange;
	} else {
		%orig;
	}
}

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		CGRect frame = [self bounds];
		frame.origin.x = frame.size.width * [self _indexOfMainPage];
		controller.view.frame = frame;

		[[self delegate] CSMLS_updateStatusBarAlpha];
	}
}
%end

//LockGlyphX Support
%hook SBDashBoardMainPageViewController
- (void)viewWillLayoutSubviews {
	%orig;

	CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
	for (UIView *x in [[self view] subviews]){
		if ([x isKindOfClass:%c(PKGlyphView)]){
			controller.lockScreenView.lockGlyphView = x;
		}
	}
}
%end

%hook SBDashBoardNotificationListViewController

- (instancetype)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
	self = %orig;
	[self view];
	return self;
}

- (void)viewDidLoad {
	%orig;
	NCNotificationPriorityListViewController *priorityController = [self valueForKey:@"_listViewController"];
	LastPriorityControllerInstance = priorityController;

	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		[controller gotNativeNotificationController:priorityController];
	}
}
%end

%hook SBDashBoardScrollGestureController
- (void)setScrollingStrategy:(NSInteger)scrollingStrategy {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0);
	else
		%orig;
}

-(void)_updateForScrollingStrategy:(NSInteger)arg1 fromScrollingStrategy:(NSInteger)arg2 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		%orig(0,0);
	else
		%orig;
}
%end

%hook SBDashBoardPresentationViewController
- (void)presentContentViewControllers:(NSArray *)contentControllers animated:(BOOL)animated completion:(id)completion {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		NSMutableArray *newContentControllers = [NSMutableArray array];
		for (NSObject *controller in contentControllers){
			if ([controller isKindOfClass:objc_getClass("SBDashBoardNowPlayingViewController")])
				continue;
			if ([controller isKindOfClass:objc_getClass("SBDashBoardPluginViewController")])
				continue;
			[newContentControllers addObject:controller];
		}
		%orig(newContentControllers, animated, completion);
	} else {
		%orig;
	}
}
%end

static const char *kCSBackgroundShadeIdentifier;

%hook SBDashBoardView
- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;

	UIView *_backgroundShade = [[UIView alloc] initWithFrame:self.bounds];
	_backgroundShade.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self addSubview:_backgroundShade];
	[self sendSubviewToBack:_backgroundShade];

	[_backgroundShade setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.25]];

	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (!enabled)
		_backgroundShade.alpha = 0.0f;

	objc_setAssociatedObject(self, &kCSBackgroundShadeIdentifier, _backgroundShade, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withContext:(BSUIScrollContext)scrollContext {
	%orig;

	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		UIView *_backgroundShade = (UIView *)objc_getAssociatedObject(self, &kCSBackgroundShadeIdentifier);
		CGFloat targetX = [self scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - (self.bounds.size.width * [self _indexOfMainPage]))/self.bounds.size.width);

		if (backgroundChange < 0.0)
			backgroundChange *= -1.0;

		_backgroundShade.alpha = 1.0f - backgroundChange;

		[[self valueForKey:@"_dateTimeClippingView"] setAlpha:backgroundChange];
		[[self valueForKey:@"_dateView"] setAlpha:backgroundChange];

		[[self delegate] CSMLS_updateStatusBarAlpha];
	}
}

- (BOOL)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)arg2 completion:(id)arg3 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		if (index == [self _indexOfMainPage]){
			UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
			UIView *foregroundView = [statusBar valueForKey:@"_foregroundView"];
			foregroundView.alpha = 0.0f;
		}
	}
	return %orig;
}

- (BOOL)resetScrollViewToMainPageAnimated:(BOOL)arg1 completion:(id)arg2 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
		UIView *foregroundView = [statusBar valueForKey:@"_foregroundView"];
		foregroundView.alpha = 0.0f;
	}
	return %orig;
}
%end

%hook SBDashBoardMainPageView
- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[self subviews][0].alpha = 0.0f;
	} else {
		[self subviews][0].alpha = 1.0f;
	}
}
%end

%hook SBDashBoardViewController

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

- (void)setPasscodeLockVisible:(BOOL)visible animated:(_Bool)animated completion:(id)arg3 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
			CGFloat targetX = [[self dashBoardView] scrollView].contentOffset.x;

			CGFloat backgroundChange = ((targetX - [self dashBoardView].bounds.size.width)/[self dashBoardView].bounds.size.width);

			CGFloat statusBarAlpha = backgroundChange * -1.0f;
			if (statusBarAlpha > 1.0)
				statusBarAlpha = 1.0 - (statusBarAlpha - 1.0);
			else if (statusBarAlpha < 0.0)
				statusBarAlpha = 0.0;
			
			UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
			UIView *foregroundView = [statusBar valueForKey:@"_foregroundView"];
			foregroundView.alpha = visible ? 1.0f : statusBarAlpha;
		}];
	}
	return %orig;
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

	[CSMetroLockScreenViewController setSpringBoardInitialized:YES];
	
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		[controller.view removeFromSuperview];
		controller.view.alpha = 1;
		[controller resetLock];

		CGRect frame = [[self dashBoardView] bounds];
		frame.origin.x = frame.size.width * [self _indexOfMainPage];

		controller.view.frame = frame;
		controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		controller.view.layer.zPosition = 100;
		controller.delegate = self;

		[[[self dashBoardView] scrollView] addSubview:controller.view];
		[[[self dashBoardView] mainPageView] setAlpha:0];
		[[[self dashBoardView] pageControl] setAlpha:0];

		[controller viewDidAppear:NO];
	}
}

- (void)viewDidLoad {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled){
		[self CSMLS_updateStatusBarAlpha];
	}
}

- (void)activate {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];

	if (enabled){
		[[[self dashBoardView] mainPageView] setAlpha:0];
		[[[self dashBoardView] pageControl] setAlpha:0];

		[[CSMetroLockScreenViewController sharedLockScreenController] viewDidAppear:NO];
		[[CSMetroLockScreenViewController sharedLockScreenController] resetLock];

		[self CSMLS_updateStatusBarAlpha];
	}
}

- (BOOL)showsSpringBoardStatusBar {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return NO;
	return %orig;
}

- (BOOL)managesOwnStatusBarAtActivation {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled)
		return YES;
	return %orig;
}

- (void)setInScreenOffMode:(BOOL)arg1 forAutoUnlock:(BOOL)arg2{
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];

	if (enabled){
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[self CSMLS_updateStatusBarAlpha];
		});
	}
}

%new
- (void)CSMLS_updateStatusBarAlpha {
	CGFloat targetX = [[self dashBoardView] scrollView].contentOffset.x;

	CGFloat backgroundChange = ((targetX - ([self dashBoardView].bounds.size.width * [self _indexOfMainPage]))/[self dashBoardView].bounds.size.width);

	CGFloat statusBarAlpha = backgroundChange * -1.0f;
	if (statusBarAlpha > 1.0)
		statusBarAlpha = 1.0 - (statusBarAlpha - 1.0);
	else if (statusBarAlpha < 0.0)
		statusBarAlpha = 0.0;
	
	UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];

	BOOL passcodeVisible = [self isPasscodeLockVisible];

	UIView *foregroundView = [statusBar valueForKey:@"_foregroundView"];
	foregroundView.alpha =  passcodeVisible ? 1.0f : statusBarAlpha;
}
%end
%end

%ctor {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (kCFCoreFoundationVersionNumber > 1300 && kCFCoreFoundationVersionNumber < 1400){
			dlopen("/Library/MobileSubstrate/DynamicLibraries/LockGlyphX.dylib", RTLD_NOW);
			%init(iOS10);
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