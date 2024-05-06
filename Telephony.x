#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"

%group TelephonyiOS11
%hook SBTelephonyManager
- (void)updateSpringBoard {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	if ([self respondsToSelector:@selector(isInAirplaneMode)]){
		data.inAirplaneMode = [self isInAirplaneMode];
	} else {
		data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	}
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [self signalStrengthBars];
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
	if ([self respondsToSelector:@selector(isInAirplaneMode)]){
		data.inAirplaneMode = [self isInAirplaneMode];
	} else {
		data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	}
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [self signalStrengthBars];
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
	if ([self respondsToSelector:@selector(isInAirplaneMode)]){
		data.inAirplaneMode = [self isInAirplaneMode];
	} else {
		data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	}
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [self signalStrengthBars];
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

- (void)_updateRegistrationNow {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	if ([self respondsToSelector:@selector(isInAirplaneMode)]){
		data.inAirplaneMode = [self isInAirplaneMode];
	} else {
		data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	}
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [self signalStrengthBars];
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

-(void)_setSignalStrength:(int)arg1 andBars:(int)arg2 {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	if ([self respondsToSelector:@selector(isInAirplaneMode)]){
		data.inAirplaneMode = [self isInAirplaneMode];
	} else {
		data.inAirplaneMode = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];
	}
	data.hasCellSignal = [self cellularRadioCapabilityIsActive];
	data.cellSignalBars = [self signalStrengthBars];
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
	if (kCFCoreFoundationVersionNumber < 1500){
		%init(TelephonyiOS11);
	}
}