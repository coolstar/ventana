#import "CSMetroLockScreenSettingsManager.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "TweakHeaders.h"

@implementation CSMetroLockScreenSettingsManager
+ (instancetype)sharedInstance {
    static CSMetroLockScreenSettingsManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}
- (CSMetroLockScreenSettingsManager *)init {
	self = [super init];
	_prefs = [[NSUserDefaults alloc] initWithSuiteName:@"org.coolstar.metrolockscreen"];
    [_prefs registerDefaults:@{
        @"enabled": @YES,
        @"zuluClock": @NO,
        @"secondsEnabled": @NO,
        @"nativeNotifications": @YES,
        @"groupNotifications":@YES,
        @"displaySiri": @YES,
        //advanced settings
        @"bounceOnTap": @YES,
        @"mediaPlayerBackdrop": @YES,
    }];
	return self;
}

- (BOOL)enabled {
	return [_prefs boolForKey:@"enabled"];
}

- (BOOL)zuluClock {
    return [_prefs boolForKey:@"zuluClock"];
}

- (BOOL)secondsEnabled {
	return [_prefs boolForKey:@"secondsEnabled"];
}

- (BOOL)useNativeNotifications {
    if (kCFCoreFoundationVersionNumber < 1300)
        return NO;
    return [_prefs boolForKey:@"nativeNotifications"];
}

- (BOOL)groupNotifications {
    return [_prefs boolForKey:@"groupNotifications"];
}

- (BOOL)displaySiri {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return [_prefs boolForKey:@"displaySiri"];
    else
        return NO;
}

//advanced settings
- (BOOL)bounceOnTap {
    return [_prefs boolForKey:@"bounceOnTap"];
}

- (BOOL)mediaPlayerBackdrop {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return [_prefs boolForKey:@"mediaPlayerBackdrop"];
}

//3rd party tweaks
- (BOOL)displayMediaControls {
    if (objc_getClass("HBCZPreferences")){
        if ([[objc_getClass("HBCZPreferences") sharedInstance] hideLockMusicControls])
            return NO;
    }
    return YES;
}
@end