#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"

%group TelephonyiOS12
%hook SBTelephonyManager
- (void)updateSpringBoard {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [[[self subscriptionContext] subscriptionInfo] signalStrengthBars];
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	if ([NSThread isMainThread])
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	else {
		dispatch_async(dispatch_get_main_queue(),^{
			[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
		});
	}
}

- (void)_updateState {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [[[self subscriptionContext] subscriptionInfo] signalStrengthBars];
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	if ([NSThread isMainThread])
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	else {
		dispatch_async(dispatch_get_main_queue(),^{
			[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
		});
	}
}

- (void)updateAirplaneMode {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [[[self subscriptionContext] subscriptionInfo] signalStrengthBars];
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	if ([NSThread isMainThread])
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	else {
		dispatch_async(dispatch_get_main_queue(),^{
			[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
		});
	}
}

-(void)_updateRegistrationNowInSubscriptionContext:(SBTelephonySubscriptionContext *)subscriptionContext {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [[[self subscriptionContext] subscriptionInfo] signalStrengthBars];
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	if ([NSThread isMainThread])
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	else {
		dispatch_async(dispatch_get_main_queue(),^{
			[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
		});
	}
}

-(void)_setSignalStrengthBars:(NSUInteger)signalStrengthBars maxBars:(NSUInteger)maxBars inSubscriptionContext:(SBTelephonySubscriptionContext *)subscriptionContext {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [[[self subscriptionContext] subscriptionInfo] signalStrengthBars];
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
		return;
	if ([NSThread isMainThread])
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	else {
		dispatch_async(dispatch_get_main_queue(),^{
			[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
		});
	}
}
%end
%end

%ctor {
	if (kCFCoreFoundationVersionNumber > 1500 && kCFCoreFoundationVersionNumber < 1600){
		%init(TelephonyiOS12);
	}
}