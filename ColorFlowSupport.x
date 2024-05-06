#import "Headers.h"
#import "CSMetroLockScreenSettingsManager.h"
#import <dlfcn.h>

static BOOL MetroLockScreenEnabled;

%group ColorFlowHooks
%hook CFWPrefsManager
%new;
- (BOOL)isMetroLockScreenEnabled {
	[self isLockScreenEnabled];
	return MetroLockScreenEnabled;
}

- (BOOL)isLockScreenEnabled {
	BOOL enabled = [[CSMetroLockScreenSettingsManager sharedInstance] enabled];

	MetroLockScreenEnabled = %orig;

	if (enabled)
		return NO;
	return MetroLockScreenEnabled;
}
%end
%end

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorFlow2.dylib", RTLD_NOW);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorFlow3.dylib", RTLD_NOW);
	dlopen("/usr/lib/TweakInject/ColorFlow4.dylib", RTLD_NOW);
	%init(ColorFlowHooks);
}