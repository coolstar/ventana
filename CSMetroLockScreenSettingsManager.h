#import <Foundation/Foundation.h>

@interface CSMetroLockScreenSettingsManager : NSObject {
	NSUserDefaults *_prefs;
}
+ (instancetype)sharedInstance;
- (BOOL)enabled;
- (BOOL)zuluClock;
- (BOOL)secondsEnabled;
- (BOOL)useNativeNotifications;
- (BOOL)groupNotifications;
- (BOOL)displaySiri;
- (BOOL)bounceOnTap;
- (BOOL)mediaPlayerBackdrop;
- (BOOL)displayMediaControls;
@end