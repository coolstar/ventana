#include <dlfcn.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@class CSMetroLockScreenNowPlaying14;
@protocol MPUNowPlayingDelegate <NSObject>
@optional
- (void)nowPlayingController:(CSMetroLockScreenNowPlaying14 *)arg1 nowPlayingInfoDidChange:(NSDictionary *)arg2;
- (void)nowPlayingController:(CSMetroLockScreenNowPlaying14 *)arg1 playbackStateDidChange:(BOOL)arg2;
@end

typedef void (^MRMediaRemoteGetNowPlayingInfoBlock)(NSDictionary *info);
typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock)(BOOL playing);

static void (*MRMediaRemoteRegisterForNowPlayingNotifications)(dispatch_queue_t queue);
static void (*MRMediaRemoteGetNowPlayingInfo)(dispatch_queue_t queue,
	MRMediaRemoteGetNowPlayingInfoBlock block);
static void (*MRMediaRemoteGetNowPlayingApplicationIsPlaying)(dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationIsPlayingBlock block);


@interface CSMetroLockScreenNowPlaying14: NSObject {
	NSDictionary *_lastInfo;
}
@property (nonatomic) NSObject<MPUNowPlayingDelegate> *delegate;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, readonly) UIImage *currentNowPlayingArtwork;

- (void)_registerForNotifications;
- (void)_unregisterForNotifications;
- (id)init;
- (void)startUpdating;
- (void)update;
@end

@implementation CSMetroLockScreenNowPlaying14 //shim for MPUNowPlayingController
- (id)init {
	self = [super init];
	if (self){
		void *mediaRemote = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_NOW);
		MRMediaRemoteRegisterForNowPlayingNotifications = dlsym(mediaRemote, "MRMediaRemoteRegisterForNowPlayingNotifications");
		MRMediaRemoteGetNowPlayingInfo = dlsym(mediaRemote, "MRMediaRemoteGetNowPlayingInfo");
		MRMediaRemoteGetNowPlayingApplicationIsPlaying = dlsym(mediaRemote, "MRMediaRemoteGetNowPlayingApplicationIsPlaying");

		_currentNowPlayingArtwork = nil;

		[self _registerForNotifications];
		[self update];
	}
	return self;
}

- (void)_registerForNotifications {
	MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());

	//shotgun
	[[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(update)
        name:@"kMRMediaRemoteNowPlayingApplicationDidChangeNotification"
        object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(update)
        name:@"kMRMediaRemoteNowPlayingApplicationClientStateDidChange"
        object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(update)
        name:@"kMRNowPlayingPlaybackQueueChangedNotification"
        object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(update)
        name:@"kMRPlaybackQueueContentItemsChangedNotification"
        object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(update)
        name:@"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"
        object:nil];
}

- (void)_unregisterForNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startUpdating {
	//nop
}

- (void)update {
	MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(),
    ^(BOOL isPlaying)
    {
		if (self.isPlaying != isPlaying)
		{
			self.isPlaying = isPlaying;

			if ([[self delegate] respondsToSelector:@selector(nowPlayingController:playbackStateDidChange:)]){
				[[self delegate] nowPlayingController:self playbackStateDidChange:isPlaying];
			}
		}
    });
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(),
        ^(NSDictionary *info)
        {
        	if (![info isEqual:_lastInfo]){
        		_lastInfo = info;
        		_currentNowPlayingArtwork = nil;
        		if ([info objectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"]){
        			_currentNowPlayingArtwork = [UIImage imageWithData:[info objectForKey:@"kMRMediaRemoteNowPlayingInfoArtworkData"] scale:1];
        		}

	        	if ([[self delegate] respondsToSelector:@selector(nowPlayingController:nowPlayingInfoDidChange:)]){
	        		[[self delegate] nowPlayingController:self nowPlayingInfoDidChange:info];
	        	}
	        }
        });
}
@end