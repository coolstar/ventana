#import <objc/runtime.h>
#import "CSMetroLockScreenViewControllerDelegate.h"
#import "ColorFlow.h"

// sandbox functions
char *sandbox_extension_issue_file(const char *extension_class, const char *path, uint32_t flags);

@protocol SBUIPasscodeLockView
- (void)setBackgroundAlpha:(CGFloat)alpha;
@end

@interface UIImage (Bundle)
+ (instancetype)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface SBWallpaperEffectView : UIView
-(void)setStyle:(int)style;
-(id)initWithWallpaperVariant:(int)wallpaperVariant;
@end

@interface SBBacklightController : NSObject
+ (instancetype) sharedInstance;
- (void)resetLockScreenIdleTimer;
- (void)cancelLockScreenIdleTimer;
- (void)resetLockScreenIdleTimerWithDuration:(CGFloat)duration;
@end

@interface SBDeviceLockController : NSObject
+ (SBDeviceLockController *)sharedController;
- (BOOL)isPasscodeLocked;
@end

@interface MCPasscodeManager : NSObject
+ (instancetype)sharedManager;
- (NSDictionary *)_passcodeCharacteristics;
- (BOOL)unlockDeviceWithPasscode:(NSString *)passcode outError:(NSError **)error;
- (void)lockDeviceImmediately:(BOOL)lock;
- (BOOL)isPasscodeSet;
- (BOOL)isDeviceLocked;
@end

@interface SBApplication : NSObject
@end

struct SBIconImageInfo {
    CGSize size;
    CGFloat scale;
    CGFloat continuousCornerRadius;
};

@interface SBApplicationIcon : NSObject
- (id)initWithApplication:(SBApplication *)application;
- (UIImage *)generateIconImage:(NSInteger)image; //iOS 7 - 12
- (UIImage *)generateIconImageWithInfo:(struct SBIconImageInfo)info; //iOS 13
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)displayIdentifier;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
@end

@interface SBLockScreenScrollView : UIScrollView
@end

@class BBBulletin;
@interface SBLockScreenActionContext : NSObject
@property (nonatomic, strong) NSString * identifier;                      //@synthesize identifier=_identifier - In the implementation block
@property (nonatomic, strong) NSString * lockLabel;                       //@synthesize lockLabel=_lockLabel - In the implementation block
@property (nonatomic, strong) NSString * shortLockLabel;                  //@synthesize shortLockLabel=_shortLockLabel - In the implementation block
@property (nonatomic, copy) id action;                                    //@synthesize action=_action - In the implementation block
@property (assign, nonatomic) BOOL requiresUIUnlock;                      //@synthesize requiresUIUnlock=_requiresUIUnlock - In the implementation block
@property (assign, nonatomic) BOOL deactivateAwayController;              //@synthesize deactivateAwayController=_deactivateAwayController - In the implementation block
@property (assign, nonatomic) BOOL canBypassPinLock;                      //@synthesize canBypassPinLock=_canBypassPinLock - In the implementation block
@property (nonatomic, readonly) BOOL hasCustomUnlockLabel; 
@property (assign, nonatomic) BOOL requiresAuthentication;                //@synthesize requiresAuthentication=_requiresAuthentication - In the implementation block
@property (nonatomic, weak) BBBulletin *bulletin;               //@synthesize bulletin=_bulletin - In the implementation block
- (SBLockScreenActionContext *)initWithLockLabel:(NSString *)lockLabel shortLockLabel:(NSString *)shortLockLabel action:(/*^block*/id)action identifier:(NSString *)identifier;
@end

@interface SBMutableLockScreenActionContext  : SBLockScreenActionContext
@end

@interface SBLockScreenActionContextFactory : NSObject
+(SBLockScreenActionContextFactory *)sharedInstance;
- (SBLockScreenActionContext *)lockScreenActionContextForBulletin:(BBBulletin *)arg1 action:(id)arg2 origin:(int)arg3 pluginActionsAllowed:(BOOL)arg4 context:(id)arg5 completion:(/*^block*/id)arg6 ;
- (SBLockScreenActionContext *)lockScreenActionContextForAction:(id)arg1 fromPlugin:(id)arg2;
@end

@interface SBLockScreenView : UIView
- (SBLockScreenScrollView *)scrollView;
- (UIView<SBUIPasscodeLockView> *) passcodeView;
- (NSInteger)pageNumberForLockScreenPage:(NSInteger)page;
@end

@interface NCNotificationAction : NSObject
@property (nonatomic, readonly, copy) NSDictionary *behaviorParameters;
@property (nonatomic, readonly) BOOL requiresAuthentication;
@end

@interface NCNotificationContent : NSObject
@property (nonatomic, readonly, copy) NSString *header;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly, copy) NSString *message;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *topic;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic, readonly) BBBulletin *bulletin;
@property (nonatomic, readonly) NCNotificationContent *content;
@property (nonatomic, readonly) NCNotificationAction *defaultAction;
@property (nonatomic, readonly, copy) NSString *sectionIdentifier;
@property (nonatomic,readonly) NSDate *timestamp;
@end

@class NCNotificationPriorityListViewController;
@interface SBDashBoardNotificationListViewController : UIViewController {
	NCNotificationPriorityListViewController *_listViewController;
}
@end

@class NCNotificationCombinedListViewController;
@interface SBDashBoardCombinedListViewController : UIViewController { //iOS 10-12
    NCNotificationCombinedListViewController *_listViewController;
}
- (void)_updateListViewContentInset;
- (void)_layoutListView;
- (void)showMetroLockScreen;
- (void)hideMetroLockScreen;
@end

@class NCNotificationCombinedListViewController;
@interface CSCombinedListViewController : UIViewController { //iOS 13+
    NCNotificationCombinedListViewController *_structuredListViewController;
}
- (void)_updateListViewContentInset;
- (void)_layoutListView;
- (void)showMetroLockScreen;
- (void)hideMetroLockScreen;

-(void)notificationStructuredListViewController:(id)arg1 requestsExecuteAction:(id)arg2 forNotificationRequest:(id)arg3 requestAuthentication:(BOOL)arg4 withParameters:(id)arg5 completion:(/*^block*/id)arg6 ;
@end

@interface SBDashBoardMainPageView : UIView
@end

@interface SBDashBoardMainPageContentViewController : UIViewController
- (SBDashBoardCombinedListViewController *)combinedListViewController;
@end

@interface SBLockScreenViewController : UIViewController <CSMetroLockScreenViewControllerDelegate>
+ (UIView *)getLockGlyphView;
- (SBLockScreenView *) lockScreenView;
- (UIView *) _cameraView;
- (void)activateCameraAnimated:(BOOL)animated;
-(void)finishUIUnlockFromSource:(int)source;
- (SBLockScreenScrollView *)lockScreenScrollView;
- (BOOL)isPasscodeLockVisible;
@end

@interface SBDashBoardPageControl : UIPageControl //iOS 10-12
@end

@interface CSPageControl : UIPageControl //iOS 13+
@end

@interface SBDashBoardIdleTimerProvider : NSObject
- (void)resetIdleTimer; //iOS 10-12
- (void)resetIdleTimerIfTopMost; //iOS 13
@end

@interface SBDashBoardTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UILabel *callToActionLabel;
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@end

@class SBDashBoardViewController;
@interface SBDashBoardView : UIView //iOS 10-12
- (UIView *)mainPageView;
- (UIScrollView *)scrollView;
- (UIView *)fixedFooterView;
- (UIView *)quickActionsView;
- (UIPageControl *)pageControl;
- (NSInteger)_indexOfMainPage;
- (SBDashBoardViewController *)delegate;

@property(retain, nonatomic) SBDashBoardTeachableMomentsContainerView *teachableMomentsContainerView;
@end

@class CSCoverSheetViewController;
@interface CSCoverSheetView : UIView //iOS 13
- (UIView *)mainPageView;
- (UIScrollView *)scrollView;
- (UIView *)fixedFooterView;
- (UIView *)quickActionsView;
- (NSInteger)_indexOfMainPage;
- (SBDashBoardViewController *)delegate;

@property(retain, nonatomic) SBDashBoardTeachableMomentsContainerView *teachableMomentsContainerView;
@end

@interface SBDashBoardViewController : UIViewController <CSMetroLockScreenViewControllerDelegate> //iOS 10-12
- (SBDashBoardView *) dashBoardView;
- (void)finishUIUnlockFromSource:(int)source;
- (BOOL)isPasscodeLockVisible;
- (void)CSMLS_updateStatusBarAlpha;
- (NSInteger)_indexOfMainPage;
- (SBDashBoardMainPageContentViewController *)mainPageContentViewController;
- (UIView *)statusBarBackgroundView;
@end

@interface CSCoverSheetViewController : UIViewController <CSMetroLockScreenViewControllerDelegate> //iOS 13
- (CSCoverSheetView *) coverSheetView;
- (void)finishUIUnlockFromSource:(int)source;
- (BOOL)isPasscodeLockVisible;
- (void)CSMLS_updateStatusBarAlpha;
- (NSInteger)_indexOfMainPage;
- (SBDashBoardMainPageContentViewController *)mainPageContentViewController;
- (UIView *)statusBarBackgroundView;
@end

@interface SBDashBoardMainPageViewController : UIViewController
@end

@interface SBLockScreenManager : NSObject
+ (SBLockScreenManager *)sharedInstance;
- (BOOL)androidlockIsLocked;
- (void) startUIUnlockFromSource:(id)source withOptions:(id)options;
- (void) _finishUIUnlockFromSource:(id)source withOptions:(id)options;
- (BOOL)attemptUnlockWithPasscode:(NSString *)passcode;
- (BOOL) isUILocked;
@property(readonly, assign, nonatomic) SBLockScreenViewController* lockScreenViewController;
@end

@interface SBWiFiManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)wiFiEnabled;
- (BOOL)isAssociated;
- (int)signalStrengthBars;
- (int)signalStrengthRSSI;
- (void)_updateWiFiState;
@end

@interface SBMutableTelephonySubscriptionInfo : NSObject //iOS 12
- (NSUInteger)signalStrengthBars;
@end

@interface SBTelephonySubscriptionContext : NSObject //iOS 12
-(SBMutableTelephonySubscriptionInfo *)subscriptionInfo;
@end

@interface STMutableTelephonySubscriptionInfo : NSObject //iOS 13+
- (NSUInteger)signalStrengthBars;
@end

@interface STTelephonySubscriptionContext : NSObject //iOS 13+
- (STMutableTelephonySubscriptionInfo *)subscriptionInfo;
@end

@interface STTelephonyStateProvider : NSObject //iOS 13+
- (STTelephonySubscriptionContext *)slot1SubscriptionContext;
- (BOOL)isCellularRadioCapabilityActive;
@end

@interface SBTelephonyManager : NSObject
+ (instancetype)sharedTelephonyManager;
- (BOOL)isInAirplaneMode;
- (int)signalStrengthBars; //iOS 8.x -> 11.4
- (BOOL)cellularRadioCapabilityIsActive;
- (void)updateSpringBoard;

- (SBTelephonySubscriptionContext *)subscriptionContext; //iOS 12
- (SBTelephonySubscriptionContext *)slot2SubscriptionContext; //iOS 12

- (STTelephonyStateProvider *)telephonyStateProvider; //iOS 13+
@end

@interface SBAirplaneModeController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isInAirplaneMode;
- (void)airplaneModeChanged;
@end

@interface NCNotificationPriorityListViewController : UIViewController
- (id)init;
+ (instancetype)lastInstance;
@end

@protocol NCNotificationListViewControllerDestinationDelegate
@required
-(void)notificationListViewController:(id)arg1 requestsClearingNotificationRequests:(id)arg2;
-(void)notificationListViewController:(id)arg1 requestPermissionToExecuteAction:(id)arg2 forNotificationRequest:(id)arg3 withParameters:(id)arg4 completion:(/*^block*/id)arg5;
-(void)notificationListViewController:(id)arg1 requestsExecuteAction:(id)arg2 forNotificationRequest:(id)arg3 requestAuthentication:(BOOL)arg4 withParameters:(id)arg5 completion:(/*^block*/id)arg6;
@end

@interface NCNotificationCombinedListViewController : UICollectionViewController
- (id)init;
+ (instancetype)lastInstance;
- (CGFloat)_forcedContentSizeHeight; //iOS 11-12
- (CGSize)effectiveContentSize;
- (UIView *)masterListView; //iOS 13
@property (nonatomic, weak) NSObject <NCNotificationListViewControllerDestinationDelegate>* destinationDelegate; 
@end

@interface NCNotificationStructuredListViewController : UICollectionViewController
@end

@interface SBFTouchPassThroughView : UIView
@end

@interface SpringBoard : UIApplication
- (UIView *)statusBar;
@end

typedef struct {
    NSInteger _field1;
    CGPoint _field2;
    CGPoint _field3;
} BSUIScrollContext;

extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;

@class MPUNowPlayingController;
@protocol MPUNowPlayingDelegate <NSObject>
@optional
- (void)nowPlayingController:(MPUNowPlayingController *)arg1 elapsedTimeDidChange:(CGFloat)arg2;
- (void)nowPlayingController:(MPUNowPlayingController *)arg1 nowPlayingApplicationDidChange:(NSString *)arg2;
- (void)nowPlayingController:(MPUNowPlayingController *)arg1 nowPlayingInfoDidChange:(NSDictionary *)arg2;
- (void)nowPlayingController:(MPUNowPlayingController *)arg1 playbackStateDidChange:(BOOL)arg2;
- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)arg1;
- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)arg1;

@end

@interface MPUNowPlayingController : NSObject {
}

@property (nonatomic, readonly) UIImage *currentNowPlayingArtwork;
@property (nonatomic) NSObject<MPUNowPlayingDelegate> *delegate;
@property (nonatomic, readonly) BOOL isPlaying;

- (void)_registerForNotifications;
- (void)_unregisterForNotifications;
- (id)init;
- (void)startUpdating;
- (void)update;

@end

@interface CSMetroLockScreenNowPlaying14: MPUNowPlayingController {
    //shim for iOS 14+
}
@end

@interface SBMediaController : NSObject
- (BOOL)changeTrack:(int)trackChange;
- (BOOL)togglePlayPause;
- (BOOL)changeTrack:(int)trackChange;
- (BOOL)changeTrack:(int)trackChange eventSource:(long long)eventSource;
- (BOOL)togglePlayPauseForEventSource:(long long)eventSource;
@end

@interface SBAssistantController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)activatePluginForEvent:(int)arg1 eventSource:(int)arg2 context:(void*)arg3; //iOS 8+
- (BOOL)activatePluginForEvent:(int)event context:(void*)context; //7.x
@end

@interface UIStatusBar : UIView
@end

#include "TweakHeaders.h"