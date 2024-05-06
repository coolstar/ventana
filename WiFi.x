#import "Headers.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenDataHandler.h"

%hook SBWiFiManager
- (void)_linkDidChange {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.wifiConnectedAndAssociated = ([self wiFiEnabled] && [self isAssociated]);
	if (data.wifiConnectedAndAssociated)
		data.wifiSignalStrengthBars = [self signalStrengthBars];
	else
		data.wifiSignalStrengthBars = 0;
	if (![CSMetroLockScreenViewController springBoardInitialized])
		return;
	dispatch_async(dispatch_get_main_queue(),^{
		if (![CSMetroLockScreenViewController springBoardInitialized])
			return;
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			return;
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	});
}

- (void)_updateCurrentNetwork {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.wifiConnectedAndAssociated = ([self wiFiEnabled] && [self isAssociated]);
	if (data.wifiConnectedAndAssociated)
		data.wifiSignalStrengthBars = [self signalStrengthBars];
	else
		data.wifiSignalStrengthBars = 0;
	dispatch_async(dispatch_get_main_queue(),^{
		if (![CSMetroLockScreenViewController springBoardInitialized])
			return;
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			return;
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	});
}

- (void)_updateWiFiState {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.wifiConnectedAndAssociated = ([self wiFiEnabled] && [self isAssociated]);
	if (data.wifiConnectedAndAssociated)
		data.wifiSignalStrengthBars = [self signalStrengthBars];
	else
		data.wifiSignalStrengthBars = 0;
	dispatch_async(dispatch_get_main_queue(),^{
		if (![CSMetroLockScreenViewController springBoardInitialized])
			return;
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			return;
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	});
}

- (void)updateSignalStrength {
	%orig;
	CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
	data.wifiConnectedAndAssociated = ([self wiFiEnabled] && [self isAssociated]);
	if (data.wifiConnectedAndAssociated)
		data.wifiSignalStrengthBars = [self signalStrengthBars];
	else
		data.wifiSignalStrengthBars = 0;
	dispatch_async(dispatch_get_main_queue(),^{
		if (![CSMetroLockScreenViewController springBoardInitialized])
			return;
		if (![[%c(SBLockScreenManager) sharedInstance] isUILocked])
			return;
		[[CSMetroLockScreenViewController sharedLockScreenController] updateData];
	});
}
%end