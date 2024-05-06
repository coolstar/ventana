//
//  CSMetroLockScreenView.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Headers.h"

@class CSMetroNotificationIconsView, CSMetroLockScreenGradientView;
@interface CSMetroLockScreenView : UIView <MPUNowPlayingDelegate, CFWAnalysisDelegate, CFWColorDelegate> {
	CSMetroLockScreenGradientView *_mediaControlsView;
	UIImageView *_mediaImageView;
	UILabel *_mediaTitleLabel;
	UILabel *_mediaArtistLabel;

    BOOL _useDarkMediaButtons;
	UIButton *_mediaPreviousButton, *_mediaPlayPauseButton, *_mediaForwardButton;

    UILabel *_timeLabel, *_dateLabel;
    
    UIImageView *_cellularIcon, *_wifiIcon, *_batteryIcon;
    
    CSMetroNotificationIconsView *_notificationIcons;
    UILabel *_notificationLabel;
    
    UITableView *_notificationView;

    UIView *_nativeNotificationView;
    UICollectionView *_nativeNotificationView11;
    NCNotificationCombinedListViewController *_nativeController;
    
    NSTimer *_timeUpdater;

    MPUNowPlayingController *_nowPlayingController;

    UIButton *_siriButton;
    UILabel *_siriLabel;

    UIView *_lockGlyphView;

    BOOL _shouldShowNotificationLabel;
}

@property (nonatomic, readonly) UIView *mediaControlsView;
@property (nonatomic, strong) UIView *nativeNotificationView;
@property (nonatomic, strong) UIView *nativeNotificationView11;
@property (nonatomic, strong) NCNotificationCombinedListViewController *nativeController;
@property (nonatomic, assign) BOOL shouldShowNotificationLabel;
@property (nonatomic, strong) UIView *lockGlyphView;

- (void)updateData;
- (void)resetLock;

@end
