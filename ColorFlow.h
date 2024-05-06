#include <UIKit/UIKit.h>

// ColorFlow 2 & 3 & 4 Public SpringBoard API Headers.

@class MPModelSong;

// Analyzed Info struct. Having a struct and Obj-C classes is a bit redundant, but I have no plans
// to change this at the moment. Sorry.
struct AnalyzedInfo {
  int bg;
  int primary;
  int secondary;
  BOOL darkBG;
};

// Contains color info about an analysis.
@interface CFWAnalyzedInfo : NSObject
@property(nonatomic, assign) int bgColor;
@property(nonatomic, assign) int primaryColor;
@property(nonatomic, assign) int secondaryColor;
@property(nonatomic, assign, getter=isDarkBG) BOOL darkBG;

- (struct AnalyzedInfo)analyzedInfo;
@end

// Contains color info in object form.
@interface CFWColorInfo : NSObject
@property(nonatomic, retain, nullable) UIColor *backgroundColor;
@property(nonatomic, retain, nullable) UIColor *primaryColor;
@property(nonatomic, retain, nullable) UIColor *secondaryColor;
@property(nonatomic, assign, getter=isBackgroundDark) BOOL backgroundDark;

+ (nonnull instancetype)colorInfoWithAnalyzedInfo:(struct AnalyzedInfo)info;

- (nonnull instancetype)initWithAnalyzedInfo:(struct AnalyzedInfo)info;
@end

// Your class should implement these methods for use as a CFWSBMediaController delegate.
@protocol CFWAnalysisDelegate<NSObject> //ColorFlow 2 & 3
// Called when color analysis is complete for the current song. The nowPlayingInfo will contain the
// same entries that a MPUNowPlayingController's _currentNowPlayingInfo would.
- (void)nowPlayingInfo:(nullable NSDictionary *)info 
               artwork:(nullable UIImage *)artwork
      analysisComplete:(nullable CFWAnalyzedInfo *)analyzedInfo;

// Called if the current song doesn't have artwork. Note that ColorFlow 2 might wait a second or so
// for artwork to potentially load before this is called.
- (void)nowPlayingInfoHadNoArtwork:(nullable NSDictionary *)info;
@end

// Your class should implement these methods for use as a CFWSBMediaController color delegate.
// You may assume that these methods are called on the main thread.
@protocol CFWColorDelegate<NSObject> //ColorFlow 4
// Called when color analysis is complete for the current song. This will only be called from the
// main thread.
- (void)songAnalysisComplete:(nullable MPModelSong *)song
                     artwork:(nullable UIImage *)artwork
                   colorInfo:(nullable CFWColorInfo *)colorInfo;

// Called if the current song doesn't have artwork. Note that ColorFlow might wait a few seconds for
// the artwork to load before this is called. This will only be called from the main thread.
- (void)songHadNoArtwork:(nullable MPModelSong *)song;
@end

@interface CFWSBMediaController : NSObject
+ (_Nonnull instancetype)sharedInstance;

//ColorFlow 2 & 3

// Adds a delegate, but if a song is already playing, don't notify the delegate of it.
- (void)addAnalysisDelegate:(nonnull id<CFWAnalysisDelegate>)delegate;

// Adds a delegate and notify it if a song is already playing. Note that ColorFlow 2 analysis is
// deferred (lazy), so either:
//   1. The analysis is already complete and this method will immediately notify your delegate.
//   2. The analysis isn't already complete - this method will not immediately notify your delegate.
//      The delegate will be notified asynchronously when analysis is complete (on the main thread).
- (void)addAnalysisDelegateAndNotify:(nonnull id<CFWAnalysisDelegate>)delegate;

// Remove your delegate whenever you don't want analysis to occur - i.e. if your view is hidden.
- (void)removeAnalysisDelegate:(nonnull id<CFWAnalysisDelegate>)delegate;

//ColorFlow 4

// Adds a delegate, but if a song is already playing, don't notify the delegate of it.
- (void)addColorDelegate:(nonnull id<CFWColorDelegate>)delegate;

// Adds a delegate and notify it if a song is already playing. Note that ColorFlow 4 analysis is
// deferred (lazy), so either:
//   1. The analysis is already complete and this method will immediately notify your delegate.
//   2. The analysis isn't already complete - this method will not immediately notify your delegate.
//      The delegate will be notified asynchronously when analysis is complete (on the main thread).
- (void)addColorDelegateAndNotify:(nonnull id<CFWColorDelegate>)delegate;

// Remove your delegate whenever you don't want analysis to occur - i.e. if your view is hidden.
- (void)removeColorDelegate:(nonnull id<CFWColorDelegate>)delegate;
@end

// Allows you to easily colorize media controls. (ColorFlow 2)
/*@interface MPUSystemMediaControlsView : UIView
@end
@interface MPUSystemMediaControlsView (ColorFlow2)
- (void)cfw_colorize:(CFWColorInfo *)colorInfo;
- (void)cfw_revert;
@end

// Allows you to easily colorize media controls. (ColorFlow 3)
@interface MPULockScreenMediaControlsView : UIView
@end
@interface MPULockScreenMediaControlsView (ColorFlow)
- (void)cfw_colorize:(CFWColorInfo *)colorInfo;
- (void)cfw_revert;
@end*/

@interface CFWPrefsManager : NSObject
@property(nonatomic, assign, getter=isLockScreenEnabled) BOOL lockScreenEnabled;
@property(nonatomic, assign, getter=isMusicEnabled) BOOL musicEnabled;
@property(nonatomic, assign, getter=isSpotifyEnabled) BOOL spotifyEnabled;

@property(nonatomic, assign, getter=shouldRemoveArtworkShadow) BOOL removeArtworkShadow;

+ (nonnull instancetype)sharedInstance;

//CoolStar's Additions
- (BOOL)isMetroLockScreenEnabled;

@end