#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"
#import "CSMetroNotificationsController.h"
#import "CSMetroLockScreenSettingsManager.h"
#import "BBBulletin.h"
#import <dlfcn.h>

static NCNotificationCombinedListViewController *LastPriorityControllerInstance;

@interface SBDashBoardView()
- (void)updateBackgroundShade;
@end

@interface SBDashBoardViewController()
- (void)displayMetroLockScreen;
- (void)hideMetroLockScreen;
@end

%group iOS11

static BOOL MLS_UIisReallyLocked;
static SBDashBoardViewController *MLS_dashBoardViewController;
static NSDate *SB_initDate;

//iPhone X
%hook SBCoverSheetScreenEdgePanGestureRecognizer
- (BOOL)_shouldBegin {
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return %orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		return NO;
	}
	return %orig;
}
%end

%hook SBLockScreenManager
- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 completion:(id)arg3 {
	%orig;
	[MLS_dashBoardViewController displayMetroLockScreen];
}

- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 {
	[MLS_dashBoardViewController hideMetroLockScreen];
	return %orig;
}
%end

%hook NCNotificationCombinedListViewController
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
	if (enabled && MLS_UIisReallyLocked){
		if ([request.timestamp compare:SB_initDate] != NSOrderedDescending)
			return ret;

		BBBulletin *bulletin = request.bulletin;
		NSString *bundleID = request.sectionIdentifier;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (request.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"raction":request.defaultAction, @"response":@NO}];

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

		NSString *message = request.content.message;
		if (bulletin.suppressesMessageForPrivacy)
			message = @"Message hidden.";

		NSString *sectionID = request.sectionIdentifier;
		if (![sectionID isKindOfClass:[NSString class]]){
			sectionID = @"com.apple.springboard";
		}

		[[CSMetroNotificationsController sharedInstance] addNotificationWithIcon:image sectionID:sectionID title:bulletin.title message:message bulletin:bulletin request:request buttons:buttons];
	}
	return ret;
}

- (void)removeNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	%orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		BBBulletin *bulletin = request.bulletin;
		[[CSMetroNotificationsController sharedInstance] removeNotificationWithBulletin:bulletin];
	}
}

- (BOOL)modifyNotificationRequest:(NCNotificationRequest *)request forCoalescedNotification:(id)arg2 {
	BOOL ret = %orig;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return ret;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		BBBulletin *bulletin = request.bulletin;
		NSString *bundleID = request.sectionIdentifier;
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
		SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
		UIImage *image = [icon generateIconImage:0];

		NSMutableArray *buttons = [NSMutableArray array];
		if (request.defaultAction)
			[buttons addObject:@{@"title":@"Open", @"raction":request.defaultAction, @"response":@NO}];
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

		NSString *message = request.content.message;
		if (bulletin.suppressesMessageForPrivacy)
			message = @"Message hidden.";

		NSString *sectionID = request.sectionIdentifier;
		if (![sectionID isKindOfClass:[NSString class]]){
			sectionID = @"com.apple.springboard";
		}
	
		[[CSMetroNotificationsController sharedInstance] modifyNotificationWithIcon:image sectionID:sectionID title:bulletin.title message:message bulletin:bulletin request:request buttons:buttons];
	}
	return ret;
}
%end

%hook SBDashBoardPageControl

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked)
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
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		CGFloat targetX = [self scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - (self.bounds.size.width * [self _indexOfMainPage]))/self.bounds.size.width);

		UIView *dateTimeClippingView = [self valueForKey:@"_dateTimeClippingView"];
		UIView *dateView = [self valueForKey:@"_dateView"];
		dateView.alpha = backgroundChange;
		dateTimeClippingView.alpha = backgroundChange;
	} else {
		UIView *dateTimeClippingView = [self valueForKey:@"_dateTimeClippingView"];
		UIView *dateView = [self valueForKey:@"_dateView"];
		dateView.alpha = 1.0f;
		dateTimeClippingView.alpha = 1.0f;
	}
}

- (void)_layoutQuickActionsView {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		[[self quickActionsView] setAlpha:0.0f];
	}
}

- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
		CGRect frame = [self bounds];
		frame.origin.x = frame.size.width * [self _indexOfMainPage];
		controller.view.frame = frame;

		[[self delegate] CSMLS_updateStatusBarAlpha];
	}
}
%end

//LockGlyphX Support
%hook SBDashBoardMainPageContentViewController
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

%hook SBDashBoardCombinedListViewController

- (void)notificationListViewController:(id)arg1 requestsExecuteAction:(id)arg2 forNotificationRequest:(id)arg3 requestAuthentication:(_Bool)arg4 withParameters:(id)arg5 completion:(id)arg6 {
	NSLog(@"notificationListViewController:%@ requestsExecuteAction:%@ forNotificationRequest%@ requestAuthentication:%d withParameters:%@ completion:%@", arg1, arg2, arg3, arg4, arg5, arg6);
	%orig;
}

- (void)notificationListViewController:(id)arg1 requestPermissionToExecuteAction:(id)arg2 forNotificationRequest:(id)arg3 withParameters:(id)arg4 completion:(id)arg5 {
	NSLog(@"notificationListViewController:%@ requestPermissionToExecuteAction:%@ forNotificationRequest:%@ withParameters:%@ completion:%@", arg1, arg2, arg3, arg4, arg5);
	%orig;
}

- (void)viewDidAppear:(BOOL)animated {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		[self showMetroLockScreen];
	} else {
		[self hideMetroLockScreen];
	}
	%orig;
}

%new;
- (void)showMetroLockScreen {
	NCNotificationCombinedListViewController *priorityController = [self valueForKey:@"_listViewController"];
	LastPriorityControllerInstance = priorityController;

	CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
	[controller gotNativeNotificationController:priorityController];
}

%new;
- (void)hideMetroLockScreen {
	NCNotificationCombinedListViewController *priorityController = [self valueForKey:@"_listViewController"];
	LastPriorityControllerInstance = priorityController;

	CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];
	[controller gotNativeNotificationController:nil];

	[priorityController.view removeFromSuperview];
	[priorityController removeFromParentViewController];
	[self addChildViewController:priorityController];
	[self.view addSubview:priorityController.view];
	priorityController.view.alpha = 1.0f;

	[self _updateListViewContentInset];
	[self _layoutListView];
}

- (void)_updateListViewContentInset {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (!enabled|| !MLS_UIisReallyLocked){
		%orig;
	}
}

- (void)_layoutListView {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (!enabled || !MLS_UIisReallyLocked){
		%orig;
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
	if (enabled && MLS_UIisReallyLocked){
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
	if (!(enabled && MLS_UIisReallyLocked))
		_backgroundShade.alpha = 0.0f;

	objc_setAssociatedObject(self, &kCSBackgroundShadeIdentifier, _backgroundShade, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView withContext:(BSUIScrollContext)scrollContext {
	%orig;

	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		UIView *_backgroundShade = (UIView *)objc_getAssociatedObject(self, &kCSBackgroundShadeIdentifier);
		CGFloat targetX = [self scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - (self.bounds.size.width * [self _indexOfMainPage]))/self.bounds.size.width);

		if (backgroundChange < 0.0)
			backgroundChange *= -1.0;

		_backgroundShade.alpha = 1.0f - backgroundChange;

		[[self valueForKey:@"_dateTimeClippingView"] setAlpha:backgroundChange];
		[[self valueForKey:@"_dateView"] setAlpha:backgroundChange];

		[[self delegate] CSMLS_updateStatusBarAlpha];
	} else {
		UIView *_backgroundShade = (UIView *)objc_getAssociatedObject(self, &kCSBackgroundShadeIdentifier);
		_backgroundShade.alpha = 0.0f;

		[[self valueForKey:@"_dateTimeClippingView"] setAlpha:1.0f];
		[[self valueForKey:@"_dateView"] setAlpha:1.0f];
	}
}

- (BOOL)scrollToPageAtIndex:(NSInteger)index animated:(BOOL)arg2 completion:(id)arg3 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		if (index == [self _indexOfMainPage]){
			UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
			UIView *foregroundView = nil;
			UIView *backgroundView = nil;
			if ([statusBar isKindOfClass:[UIStatusBar class]]){
				foregroundView = [statusBar valueForKey:@"_foregroundView"];
				backgroundView = [statusBar valueForKey:@"_backgroundView"];
			} else
				foregroundView = [statusBar valueForKey:@"_statusBar"];

			foregroundView.alpha = 0.0f;
			backgroundView.alpha = 0.0f;
		}
	}
	return %orig;
}

- (BOOL)resetScrollViewToMainPageAnimated:(BOOL)arg1 completion:(id)arg2 {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
		UIView *foregroundView = nil;
		UIView *backgroundView = nil;
		if ([statusBar isKindOfClass:[UIStatusBar class]]){
			foregroundView = [statusBar valueForKey:@"_foregroundView"];
			backgroundView = [statusBar valueForKey:@"_backgroundView"];
		} else
			foregroundView = [statusBar valueForKey:@"_statusBar"];

		foregroundView.alpha = 0.0f;
		backgroundView.alpha = 0.0f;
	}
	return %orig;
}

%new
- (void)updateBackgroundShade {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		UIView *_backgroundShade = (UIView *)objc_getAssociatedObject(self, &kCSBackgroundShadeIdentifier);
		CGFloat targetX = [self scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - (self.bounds.size.width * [self _indexOfMainPage]))/self.bounds.size.width);

		if (backgroundChange < 0.0)
			backgroundChange *= -1.0;

		_backgroundShade.alpha = 1.0f - backgroundChange;

		[[self valueForKey:@"_dateTimeClippingView"] setAlpha:backgroundChange];
		[[self valueForKey:@"_dateView"] setAlpha:backgroundChange];

		[[self delegate] CSMLS_updateStatusBarAlpha];
	} else {
		UIView *_backgroundShade = (UIView *)objc_getAssociatedObject(self, &kCSBackgroundShadeIdentifier);
		_backgroundShade.alpha = 0.0f;

		[[self valueForKey:@"_dateTimeClippingView"] setAlpha:1.0f];
		[[self valueForKey:@"_dateView"] setAlpha:1.0f];
	}
}
%end

%hook SBDashBoardMainPageView
- (void)layoutSubviews {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if ([[self subviews] count] > 0){
		if (enabled && MLS_UIisReallyLocked){
			[self subviews][0].alpha = 0.0f;
		} else {
			[self subviews][0].alpha = 1.0f;
		}
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
	if (enabled && MLS_UIisReallyLocked){
		[UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
			CGFloat targetX = [[self dashBoardView] scrollView].contentOffset.x;

			CGFloat backgroundChange = ((targetX - [self dashBoardView].bounds.size.width)/[self dashBoardView].bounds.size.width);

			CGFloat statusBarAlpha = backgroundChange * -1.0f;
			if (statusBarAlpha > 1.0)
				statusBarAlpha = 1.0 - (statusBarAlpha - 1.0);
			else if (statusBarAlpha < 0.0)
				statusBarAlpha = 0.0;
			
			UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
			UIView *foregroundView = nil;
			UIView *backgroundView = nil;
			if ([statusBar isKindOfClass:[UIStatusBar class]]){
				foregroundView = [statusBar valueForKey:@"_foregroundView"];
				backgroundView = [statusBar valueForKey:@"_backgroundView"];
			}
			else
				foregroundView = [statusBar valueForKey:@"_statusBar"];

			foregroundView.alpha = visible ? 1.0f : statusBarAlpha;
			backgroundView.alpha = visible ? 1.0f : statusBarAlpha;
		}];
	}
	return %orig;
}

%new;
- (void)displayMetroLockScreen {
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (!selfVerify()){
			safeMode();
		}
		if (!deepVerifyUDID()){
			safeMode();
		}
	});

	MLS_UIisReallyLocked = YES;

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
		[[[self dashBoardView] fixedFooterView] setAlpha:0];
		if ([[self dashBoardView] respondsToSelector:@selector(quickActionsView)])
			[[[self dashBoardView] quickActionsView] setAlpha:0];
		[[self dashBoardView] updateBackgroundShade];

		if ([[self dashBoardView] respondsToSelector:@selector(teachableMomentsContainerView)])
			[[[self dashBoardView] teachableMomentsContainerView] setAlpha:0];

		[[[self mainPageContentViewController] combinedListViewController] showMetroLockScreen];

		[self statusBarBackgroundView].alpha = 0;
	}
}

%new;
- (void)hideMetroLockScreen {
	[UIView animateWithDuration:0.25 animations:^{
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];

		[controller.view setAlpha:0];
		[[[self dashBoardView] mainPageView] setAlpha:1];
		[[[self dashBoardView] fixedFooterView] setAlpha:1];
		if ([[self dashBoardView] respondsToSelector:@selector(quickActionsView)])
			[[[self dashBoardView] quickActionsView] setAlpha:1];
		if ([[self dashBoardView] respondsToSelector:@selector(teachableMomentsContainerView)])
			[[[self dashBoardView] teachableMomentsContainerView] setAlpha:1];
		[[self dashBoardView] updateBackgroundShade];

		[[[self mainPageContentViewController] combinedListViewController] hideMetroLockScreen];
	} completion:^(BOOL finished){
		CSMetroLockScreenViewController *controller = [CSMetroLockScreenViewController sharedLockScreenController];

		[controller.view removeFromSuperview];
		[controller.view setAlpha:1];

		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];
		UIView *foregroundView = nil;
		UIView *backgroundView = nil;
		if ([statusBar isKindOfClass:[UIStatusBar class]]){
			foregroundView = [statusBar valueForKey:@"_foregroundView"];
			backgroundView = [statusBar valueForKey:@"_backgroundView"];
		} else
			foregroundView = [statusBar valueForKey:@"_statusBar"];

		foregroundView.alpha = 1.0f;
		backgroundView.alpha = 1.0f;
		MLS_UIisReallyLocked = NO;

		[[self dashBoardView] updateBackgroundShade];
	}];
}

- (void)_updateStatusBarBackground {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		[self statusBarBackgroundView].alpha = 0;
	}
}

%new;
- (void)resetLockScreenIdleTimer {
	SBDashBoardIdleTimerProvider *idleTimeProvider = [self valueForKey:@"_idleTimerProvider"];
	[idleTimeProvider resetIdleTimer];
}

- (void)_updateQuickActions {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		[[[self dashBoardView] quickActionsView] setAlpha:0.0f];
	}
}

- (void)updateQuickActionsVisibility {
	%orig;
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		[[[self dashBoardView] quickActionsView] setAlpha:0.0f];
	}
}

- (void)loadView {
	%orig;

	MLS_dashBoardViewController = self;

	[CSMetroLockScreenViewController setSpringBoardInitialized:YES];
	[[CSMetroNotificationsController sharedInstance] clearNotifications];
	SB_initDate = [NSDate date];
}

- (BOOL)showsSpringBoardStatusBar {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked)
		return NO;
	return %orig;
}

- (BOOL)managesOwnStatusBarAtActivation {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked)
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
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];
	if (enabled && MLS_UIisReallyLocked){
		CGFloat targetX = [[self dashBoardView] scrollView].contentOffset.x;

		CGFloat backgroundChange = ((targetX - ([self dashBoardView].bounds.size.width * [self _indexOfMainPage]))/[self dashBoardView].bounds.size.width);

		CGFloat statusBarAlpha = backgroundChange * -1.0f;
		if (statusBarAlpha > 1.0)
			statusBarAlpha = 1.0 - (statusBarAlpha - 1.0);
		else if (statusBarAlpha < 0.0)
			statusBarAlpha = 0.0;
		
		UIView *statusBar = [(SpringBoard *)[UIApplication sharedApplication] statusBar];

		BOOL passcodeVisible = [self isPasscodeLockVisible];

		UIView *foregroundView = nil;
		UIView *backgroundView = nil;
		if ([statusBar isKindOfClass:[UIStatusBar class]]){
			foregroundView = [statusBar valueForKey:@"_foregroundView"];
			backgroundView = [statusBar valueForKey:@"_backgroundView"];
		} else
			foregroundView = [statusBar valueForKey:@"_statusBar"];

		foregroundView.alpha = passcodeVisible ? 1.0f : statusBarAlpha;
		backgroundView.alpha = passcodeVisible ? 1.0f : statusBarAlpha;

		[self statusBarBackgroundView].alpha = 0;
	}
}
%end
%end

%ctor {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (kCFCoreFoundationVersionNumber > 1400 && kCFCoreFoundationVersionNumber < 1600){
			dlopen("/Library/MobileSubstrate/DynamicLibraries/LockGlyphX.dylib", RTLD_NOW);
			dlopen("/System/Library/PrivateFrameworks/AssistantServices.framework/AssistantServices", RTLD_NOW);
			%init(iOS11);
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

			char *sandboxExtension = sandbox_extension_issue_file("com.apple.app-sandbox.read-write", "/var/mobile/Library/Caches/org.coolstar.sirisuggestions.plist", 0);
			NSString *sandboxExtensionStr = [NSString stringWithUTF8String:sandboxExtension];
			[sandboxExtensionStr writeToFile:@"/var/mobile/Library/Caches/org.coolstar.sirisndbox.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
	});
}