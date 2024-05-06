//
//  CSMetroLockScreenView.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenView.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroNotificationsController.h"
#import "CSMetroNotificationIconsView.h"
#import "CSMetroLockScreenDataHandler.h"
#import "CSMetroLockScreenGradientView.h"
#import "CSMetroLockScreenSettingsManager.h"
#import "Headers.h"
#import "Siri.h"

@implementation CSMetroLockScreenView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!verifyUDID())
        safeMode();

    self = [super initWithFrame:frame];
    if (self){
        UIFont *timeFont = nil;
        UIFont *dateFont = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            timeFont = [UIFont systemFontOfSize:100 weight:UIFontWeightThin];
            dateFont = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
        } else {
            timeFont = [UIFont systemFontOfSize:75 weight:UIFontWeightThin];
            dateFont = [UIFont systemFontOfSize:25 weight:UIFontWeightLight];
        }

        _mediaControlsView = [[CSMetroLockScreenGradientView alloc] initWithFrame:CGRectZero];
        [_mediaControlsView setAlpha:0.0f];
        [self addSubview:_mediaControlsView];

        _mediaImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_mediaImageView setBackgroundColor:[UIColor whiteColor]];
        [_mediaImageView setUserInteractionEnabled:NO];
        [_mediaControlsView addSubview:_mediaImageView];

        _mediaTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        UIFont *mediaTitleLabelFont = [UIFont systemFontOfSize:25 weight:UIFontWeightThin];

        [_mediaTitleLabel setFont:mediaTitleLabelFont];
        [_mediaTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [_mediaTitleLabel setTextColor:[UIColor whiteColor]];
        [_mediaTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [_mediaTitleLabel setUserInteractionEnabled:NO];
        [_mediaControlsView addSubview:_mediaTitleLabel];

        _mediaArtistLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        UIFont *mediaArtistLabelFont = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];

        [_mediaArtistLabel setFont:mediaArtistLabelFont];

        [_mediaArtistLabel setTextAlignment:NSTextAlignmentLeft];
        [_mediaArtistLabel setTextColor:[UIColor whiteColor]];
        [_mediaArtistLabel setAdjustsFontSizeToFitWidth:YES];
        [_mediaArtistLabel setUserInteractionEnabled:NO];
        [_mediaControlsView addSubview:_mediaArtistLabel];

        _mediaPreviousButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_mediaPreviousButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_previous"] forState:UIControlStateNormal];
        [_mediaPreviousButton addTarget:self action:@selector(_mediaPrevious:) forControlEvents:UIControlEventTouchUpInside];
        [_mediaControlsView addSubview:_mediaPreviousButton];

        _mediaPlayPauseButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play"] forState:UIControlStateNormal];
        [_mediaPlayPauseButton addTarget:self action:@selector(_mediaPlayPause:) forControlEvents:UIControlEventTouchUpInside];
        [_mediaControlsView addSubview:_mediaPlayPauseButton];

        _mediaForwardButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_mediaForwardButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_forward"] forState:UIControlStateNormal];
        [_mediaForwardButton addTarget:self action:@selector(_mediaForward:) forControlEvents:UIControlEventTouchUpInside];
        [_mediaControlsView addSubview:_mediaForwardButton];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setFont:timeFont];
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel setUserInteractionEnabled:NO];
        [self addSubview:_timeLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_dateLabel setFont:dateFont];
        [_dateLabel setTextColor:[UIColor whiteColor]];
        [_dateLabel setTextAlignment:NSTextAlignmentLeft];
        [_dateLabel setUserInteractionEnabled:NO];
        [self addSubview:_dateLabel];
        
        _cellularIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_cellularIcon setUserInteractionEnabled:NO];
        _cellularIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:_cellularIcon];
        
        _wifiIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _wifiIcon.image = [CSMetroLockScreenViewController imageNamed:@"wifi_3"];
        [_wifiIcon setUserInteractionEnabled:NO];
        _wifiIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:_wifiIcon];
        
        _batteryIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_batteryIcon setUserInteractionEnabled:NO];
        _batteryIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:_batteryIcon];
        
#pragma mark Begin Custom Notifications
        _notificationIcons = [[CSMetroNotificationIconsView alloc] initWithFrame:CGRectZero];
        [self addSubview:_notificationIcons];
        
        _notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_notificationLabel setText:@"Notifications"];
        [_notificationLabel setFont:[UIFont systemFontOfSize:26]];
        [_notificationLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:_notificationLabel];
        _notificationLabel.alpha = 0;
        
        _notificationView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_notificationView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_notificationView setBackgroundColor:[UIColor clearColor]];
        [_notificationView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [self addSubview:_notificationView];
        
        CSMetroNotificationsController *notificationsController = [CSMetroNotificationsController sharedInstance];
        _notificationView.dataSource = notificationsController;
        _notificationView.delegate = notificationsController;
        notificationsController.tableView = _notificationView;
        notificationsController.notificationIconsView = _notificationIcons;
        notificationsController.lockScreenView = self;
#pragma mark End Custom Notifications

#pragma mark Begin Siri
        _siriButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_siriButton setImage:[CSMetroLockScreenViewController imageNamed:@"siri"] forState:UIControlStateNormal];
        [_siriButton addTarget:self action:@selector(activateSiri:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_siriButton];

        _siriLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_siriLabel setTextColor:[UIColor whiteColor]];
        UIFont *siriFont = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
        [_siriLabel setFont:siriFont];
        [self addSubview:_siriLabel];
#pragma mark End Siri
        
        [self updateTime];
        [self startUpdatingTime];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStatusChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [self batteryStatusChanged:nil];

        _nowPlayingController = [[objc_getClass("MPUNowPlayingController") alloc] init]; // iOS 7 -> iOS 13
        if (!_nowPlayingController){
            _nowPlayingController = [[CSMetroLockScreenNowPlaying14 alloc] init]; // shim for iOS 14+
        }
        [_nowPlayingController setDelegate:self];
        [_nowPlayingController _registerForNotifications];
        [_nowPlayingController startUpdating];

        //ColorFlow support
        _useDarkMediaButtons = NO;
        CFWSBMediaController *colorFlowController = [objc_getClass("CFWSBMediaController") sharedInstance];
        if ([colorFlowController respondsToSelector:@selector(addAnalysisDelegateAndNotify:)]) //ColorFlow 2 & 3
            [colorFlowController addAnalysisDelegateAndNotify:self];
        else //ColorFlow 4
            [colorFlowController addColorDelegate:self];
    }
    return self;
}

- (UIImage *)batteryImageForPercentage:(CGFloat)percentage isCharging:(BOOL)charging {
    if (!verifyUDID())
        safeMode();

    UIImage *origOutside = nil;
    UIImage *origInside = nil;
    if (charging){
        origOutside = [CSMetroLockScreenViewController imageNamed:@"battery_outside_charging"];
        origInside = [CSMetroLockScreenViewController imageNamed:@"battery_inside_charging"];
    } else {
        origOutside = [CSMetroLockScreenViewController imageNamed:@"battery_outside"];
        origInside = [CSMetroLockScreenViewController imageNamed:@"battery_inside"];
    }
    
    CGRect croppedRect = CGRectMake(0, 0, origInside.size.width, origInside.size.height);
    croppedRect.size.width *= origInside.scale;
    croppedRect.size.height *= origInside.scale;
    croppedRect.size.width *= (percentage/100.f);
    CGImageRef cgCroppedInside = CGImageCreateWithImageInRect(origInside.CGImage, croppedRect);
    UIImage *croppedInside = [[UIImage alloc] initWithCGImage:cgCroppedInside scale:origInside.scale orientation:origInside.imageOrientation];
    CGImageRelease(cgCroppedInside);
    
    UIGraphicsBeginImageContextWithOptions(origOutside.size, NO, 0.f);
    [origOutside drawAtPoint:CGPointZero];
    [croppedInside drawInRect:CGRectMake(2, charging ? 4 : 2, origInside.size.width * (percentage/100.f), origInside.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)batteryStatusChanged:(id)sender {
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
#if TARGET_IPHONE_SIMULATOR
    batteryLevel = 1.f;
#endif
    BOOL isCharging = NO;
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    if (state == UIDeviceBatteryStateFull || state == UIDeviceBatteryStateCharging)
        isCharging = YES;

    _batteryIcon.image = [self batteryImageForPercentage:batteryLevel * 100.f isCharging:isCharging];    
}

- (void)setShouldShowNotificationLabel:(BOOL)shouldShowNotificationLabel {
    _shouldShowNotificationLabel = shouldShowNotificationLabel;
    [self layoutSubviews];
}

- (void)setLockGlyphView:(UIView *)glyphView {
    [_lockGlyphView removeFromSuperview];
    _lockGlyphView = nil;

    _lockGlyphView = glyphView;
    [_lockGlyphView removeFromSuperview];
    [self addSubview:_lockGlyphView];
    [self layoutSubviews];
}

- (void)layoutSubviews {  
    [super layoutSubviews];
    CGRect frame = self.bounds;
    
    CGRect timeLabelFrame = CGRectZero;
    CGRect dateLabelFrame = CGRectZero;

    CGFloat adjustmentForNotch = 0;
    if (@available(iOS 11.0, *)){
        adjustmentForNotch = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].top;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        _mediaControlsView.frame = CGRectMake(frame.size.width - 360, frame.size.height - 210, 360, 110);

        CGFloat mediaControlsWidth = _mediaControlsView.bounds.size.width;

        _mediaImageView.frame = CGRectMake(0, 0, 110, 110);

        _mediaTitleLabel.frame = CGRectMake(120, 8, mediaControlsWidth - 120, 27);
        _mediaArtistLabel.frame = CGRectMake(120, 35, mediaControlsWidth - 120, 17);

        CGFloat mediaControlsUsableSize = mediaControlsWidth - 120;

        _mediaPreviousButton.frame = CGRectMake(120.f + (mediaControlsUsableSize * 0.25f) - 14.f, 77, 28, 17);

        _mediaPlayPauseButton.frame = CGRectMake(120.f + (mediaControlsUsableSize * 0.50f) - 14.f, 75, 28, 21);

        _mediaForwardButton.frame = CGRectMake(120.f + (mediaControlsUsableSize * 0.75f) - 14.f, 77, 28, 17);
    } else {
        _mediaControlsView.frame = CGRectMake(0, 0, frame.size.width, 112 + adjustmentForNotch);

        CGFloat mediaControlsWidth = _mediaControlsView.bounds.size.width;

        _mediaImageView.frame = CGRectMake(8, 10 + adjustmentForNotch, 94, 94);

        _mediaTitleLabel.frame = CGRectMake(117, 8 + adjustmentForNotch, mediaControlsWidth - 125, 27);
        _mediaArtistLabel.frame = CGRectMake(117, 35 + adjustmentForNotch, mediaControlsWidth - 125, 17);

        CGFloat mediaControlsUsableSize = mediaControlsWidth - 122;

        _mediaPreviousButton.frame = CGRectMake(117.f + (mediaControlsUsableSize * 0.25f) - 14.f, 82 + adjustmentForNotch, 28, 17);

        _mediaPlayPauseButton.frame = CGRectMake(117.f + (mediaControlsUsableSize * 0.50f) - 14.f, 80 + adjustmentForNotch, 28, 21);

        _mediaForwardButton.frame = CGRectMake(117.f + (mediaControlsUsableSize * 0.75f) - 14.f, 82 + adjustmentForNotch, 28, 17);
    }

    [_mediaControlsView refreshGradient];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        timeLabelFrame = CGRectMake(30, frame.size.height - 250, 400, 100);
        dateLabelFrame = CGRectMake(30, frame.size.height - 150, 500, 50);
    } else {
        timeLabelFrame = CGRectMake(30, frame.size.height - 200, 320, 75);
        dateLabelFrame = CGRectMake(30, frame.size.height - 125, 320, 30);
        if (self.frame.size.height <= 568){
            timeLabelFrame = CGRectMake(20, frame.size.height - 175, 320, 75);
            dateLabelFrame = CGRectMake(20, frame.size.height - 100, 320, 30);
        }
    }
    _timeLabel.frame = timeLabelFrame;
    _dateLabel.frame = dateLabelFrame;

    if (_lockGlyphView){
        CGRect lockGlyphFrame = _lockGlyphView.frame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            _lockGlyphView.alpha = 0.0f;
        else
            _lockGlyphView.frame = CGRectMake(frame.size.width - (lockGlyphFrame.size.width + 10), timeLabelFrame.origin.y + 15, lockGlyphFrame.size.width, lockGlyphFrame.size.height);
    }
    
    [self updateData];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        _notificationLabel.frame = CGRectMake(self.frame.size.width - 470, 50, 200, 40);

        _notificationView.frame = CGRectMake(self.frame.size.width - 470, 100, 400, self.frame.size.height - 320);
        _nativeNotificationView.frame = CGRectMake(self.frame.size.width - 470, 100, 400, self.frame.size.height - 320);
    } else {
        if (self.frame.size.height > 568){ //iPhone 6/6+
            //_notificationLabel.frame = CGRectMake(10, 75, self.frame.size.width - 20, 40);
        
            if (_mediaControlsView.alpha > 0){
                _notificationView.frame = CGRectMake(10, 125 + adjustmentForNotch, self.frame.size.width - 20, (self.frame.size.height - 330) - adjustmentForNotch);
                _nativeNotificationView.frame = CGRectMake(0, 125 + adjustmentForNotch, self.frame.size.width, (self.frame.size.height - 330) - adjustmentForNotch);
            } else {
                _notificationView.frame = CGRectMake(10, 10 + adjustmentForNotch, self.frame.size.width - 20, (self.frame.size.height - 215) - adjustmentForNotch);
                _nativeNotificationView.frame = CGRectMake(0, 10 + adjustmentForNotch, self.frame.size.width, (self.frame.size.height - 215) - adjustmentForNotch);
            }
        } else { //iPhone 5
            //_notificationLabel.frame = CGRectMake(20, 40, self.frame.size.width - 40, 40);
            
            if (_mediaControlsView.alpha > 0){
                _notificationView.frame = CGRectMake(10, 110, self.frame.size.width - 20, self.frame.size.height - 285);
                _nativeNotificationView.frame = CGRectMake(0, 110, self.frame.size.width, self.frame.size.height - 285);
            } else {
                _notificationView.frame = CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 185);
                _nativeNotificationView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height - 185);
            }
        }
    }

    if (_nativeNotificationView11){
        _nativeNotificationView11.frame = _nativeNotificationView.bounds;

        BOOL updateOffset = false;
        UIEdgeInsets newInsets = UIEdgeInsetsMake(20, 0, 66, 0);
        updateOffset = !UIEdgeInsetsEqualToEdgeInsets(_nativeNotificationView11.contentInset, newInsets);

        _nativeNotificationView11.contentInset = newInsets;
        if ([_nativeController respondsToSelector:@selector(_forcedContentSizeHeight)])
            _nativeNotificationView11.contentSize = CGSizeMake(_nativeNotificationView.bounds.size.width, [_nativeController _forcedContentSizeHeight]);
        else {
            _nativeNotificationView11.contentSize = CGSizeMake(_nativeNotificationView.bounds.size.width, [_nativeController effectiveContentSize].height - 50.f);
            if (updateOffset)
                _nativeNotificationView11.contentOffset = CGPointMake(0, 0);
        }
    }
    _nativeNotificationView.clipsToBounds = YES;

    _notificationIcons.frame = CGRectMake(30, frame.size.height - 80, 200, 32);
    if (self.frame.size.height <= 568)
        _notificationIcons.frame = CGRectMake(20, frame.size.height - 60, 200, 32);
    
    if ([[CSMetroLockScreenSettingsManager sharedInstance] useNativeNotifications]){
        _nativeNotificationView.alpha = 1;
        _notificationIcons.alpha = 0;
        _notificationView.alpha = 0;
    } else {
        _nativeNotificationView.alpha = 0;
        if ([[CSMetroLockScreenSettingsManager sharedInstance] groupNotifications])
            _notificationIcons.alpha = 1;
        else
            _notificationIcons.alpha = 0;
        _notificationView.alpha = 1;
    }

    _siriButton.frame = CGRectMake(40, 40, 50, 50);
    _siriLabel.frame = CGRectMake(100, 42, 440, 40);

    if ([[CSMetroLockScreenSettingsManager sharedInstance] displaySiri]){
        _siriButton.alpha = 1.0f;
        _siriLabel.alpha = 1.0f;
        if (self.bounds.size.width > 768){
            if (_shouldShowNotificationLabel)
                _notificationLabel.alpha = 1.0f;
            else
                _notificationLabel.alpha = 0.0f;
        } else {
            _notificationLabel.alpha = 0.0f;
        }
    } else {
        _siriButton.alpha = 0.0f;
        _siriLabel.alpha = 0.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            if (_shouldShowNotificationLabel)
                _notificationLabel.alpha = 1.0f;
            else
                _notificationLabel.alpha = 0.0f;
        } else {
            _notificationLabel.alpha = 0.0f;
        }
    }
}

- (void)updateData {
    CGRect frame = self.bounds;
    
    CSMetroLockScreenDataHandler *data = [CSMetroLockScreenDataHandler sharedObject];
    
    NSArray *icons = @[_wifiIcon, _cellularIcon];
    
    if (data.inAirplaneMode) {
        _cellularIcon.alpha = 1;
        _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"airplane"];
    } else if (data.hasCellSignal){
        _cellularIcon.alpha = 1;
        
        switch (data.cellSignalBars){
            case 1: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_1"];
                break;
            }
            case 2: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_2"];
                break;
            }
            case 3: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_3"];
                break;
            }
            case 4: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_4"];
                break;
            }
            case 5: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_5"];
                break;
            }
            default: {
                _cellularIcon.image = [CSMetroLockScreenViewController imageNamed:@"cellular_0"];
                break;
            }
        }
    } else
        _cellularIcon.alpha = 0;
    
    if (data.wifiConnectedAndAssociated){
        _wifiIcon.alpha = 1;
        
        switch (data.wifiSignalStrengthBars){
            case 3:
                _wifiIcon.image = [CSMetroLockScreenViewController imageNamed:@"wifi_4"];
                break;
            case 2:
                _wifiIcon.image = [CSMetroLockScreenViewController imageNamed:@"wifi_3"];
                break;
            case 1:
                _wifiIcon.image = [CSMetroLockScreenViewController imageNamed:@"wifi_2"];
                break;
            case 0:
                _wifiIcon.image = [CSMetroLockScreenViewController imageNamed:@"wifi_1"];
                break;
        }
    } else
        _wifiIcon.alpha = 0;
    
    CGFloat x = 100;
    if (self.frame.size.height < 568)
        x = 90;

    for (UIImageView *icon in icons){
        if (icon.alpha == 0)
            continue;
        if (self.frame.size.height > 568)
            icon.frame = CGRectMake(frame.size.width - x, frame.size.height - 60, 30, 30);
        else
            icon.frame = CGRectMake(frame.size.width - x, frame.size.height - 50, 30, 30);
        x += 40;
    }
    if (self.frame.size.height > 568)
        _batteryIcon.frame = CGRectMake(frame.size.width - 60, frame.size.height - 60, 30, 30);
    else
        _batteryIcon.frame = CGRectMake(frame.size.width - 50, frame.size.height - 50, 30, 30);
}

- (void)resetLock {
    if ([[CSMetroLockScreenSettingsManager sharedInstance] displaySiri]){
        if (kCFCoreFoundationVersionNumber > 1400){
            NSArray *suggestedUtterances = [NSArray arrayWithContentsOfFile:@"/var/mobile/Library/Caches/org.coolstar.sirisuggestions.plist"];
            NSString *suggestion = suggestedUtterances.count == 0 ? nil : suggestedUtterances[arc4random_uniform(suggestedUtterances.count)];
            if (!suggestion)
                _siriLabel.text = [NSString stringWithFormat:@"Please open Siri and tap the '?' button for suggestions."];
            else
                _siriLabel.text = [NSString stringWithFormat:@"Tap and say \"%@\"", suggestion];
        } else {
            NSString *languageCode = [[objc_getClass("AFPreferences") sharedPreferences] languageCode];
            __block NSArray *suggestedUtterances = nil;
            if (objc_getClass("SUICSuggestions")){
                //iOS 9
                SUICSuggestions *suggestions = [[objc_getClass("SUICSuggestions") alloc] initWithLanguageCode:languageCode delegate:nil];
                [suggestions getSuggestionsWithCompletion:^{
                    suggestedUtterances = [suggestions valueForKey:@"_suggestedUtterances"];
                    NSString *suggestion = suggestedUtterances.count == 0 ? nil : suggestedUtterances[arc4random_uniform(suggestedUtterances.count)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _siriLabel.text = [NSString stringWithFormat:@"Tap and say \"%@\"", suggestion];
                    });
                }];
            } else if (objc_getClass("AFUtteranceSuggestions")){
                //iOS 10
                AFUtteranceSuggestions *suggestions = [[objc_getClass("AFUtteranceSuggestions") alloc] initWithLanguageCode:languageCode delegate:nil];
                [suggestions getSuggestedUtterancesWithCompletion:^{
                    suggestedUtterances = [suggestions valueForKey:@"_suggestedUtterances"];
                    NSString *suggestion = suggestedUtterances.count == 0 ? nil : suggestedUtterances[arc4random_uniform(suggestedUtterances.count)];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _siriLabel.text = [NSString stringWithFormat:@"Tap and say \"%@\"", suggestion];
                    });
                }];
            } else {
                NSString *filePath = [NSString stringWithFormat:@"/var/mobile/Library/Assistant/Suggestions-%@.plist", languageCode];
                suggestedUtterances = [NSArray arrayWithContentsOfFile:filePath];
                NSString *suggestion = suggestedUtterances.count == 0 ? nil : suggestedUtterances[arc4random_uniform(suggestedUtterances.count)];
                _siriLabel.text = [NSString stringWithFormat:@"Tap and say \"%@\"", suggestion];
            }
        }
    }

    if ([objc_getClass("SBLockScreenViewController") respondsToSelector:@selector(getLockGlyphView)]){
        [self setLockGlyphView:[objc_getClass("SBLockScreenViewController") getLockGlyphView]];
    }
}

- (void)updateTime {
    [_nowPlayingController update];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    [formatter setLocale:enUSPOSIXLocale];

    BOOL secondsEnabled = [[CSMetroLockScreenSettingsManager sharedInstance] secondsEnabled];
    BOOL zuluTime = [[CSMetroLockScreenSettingsManager sharedInstance] zuluClock];
    if (!secondsEnabled){
        if (zuluTime)
            [formatter setDateFormat:@"H:mm"];
        else
            [formatter setDateFormat:@"h:mm"];
    }
    else {
        if (zuluTime)
            [formatter setDateFormat:@"H:mm:ss"];
        else
            [formatter setDateFormat:@"h:mm:ss"];
    }
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:time];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 30.f;
    paragraphStyle.lineSpacing = 0.f;
    paragraphStyle.minimumLineHeight = 30.f;
    paragraphStyle.maximumLineHeight = 30.f;
    
    [attributedString setAttributes:@{NSFontAttributeName:_timeLabel.font} range:NSMakeRange(0, time.length)];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-UltraLight" size:_timeLabel.font.pointSize]} range:[time rangeOfString:@":"]];
    if (secondsEnabled)
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-UltraLight" size:_timeLabel.font.pointSize]} range:[time rangeOfString:@":" options:NSBackwardsSearch]];
    [_timeLabel setAttributedText:attributedString];
    
    [formatter setLocale:[NSLocale currentLocale]];

    [formatter setDateFormat:@"EEEE, MMMM d"];
    _dateLabel.text = [formatter stringFromDate:[NSDate date]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [[CSMetroLockScreenViewController sharedLockScreenController] restartDimTimerIfNeeded];
    return [super hitTest:point withEvent:event];
}

- (void)startUpdatingTime {
    [self updateTime];
    [_timeUpdater invalidate];
    _timeUpdater = nil;
    _timeUpdater = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self selector:@selector(updateTime) userInfo:nil
                                                   repeats:YES];
}

- (void)stopUpdatingTime {
    [_timeUpdater invalidate];
    _timeUpdater = nil;
}

//iOS 8 -> 13 media controls
- (void)nowPlayingController:(MPUNowPlayingController *)nowPlayingController playbackStateDidChange:(BOOL)isPlaying {
    if (_useDarkMediaButtons){
        if (isPlaying)
            [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_pause_dark"] forState:UIControlStateNormal];
        else
            [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play_dark"] forState:UIControlStateNormal];
    } else {
        if (isPlaying)
            [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_pause"] forState:UIControlStateNormal];
        else
            [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play"] forState:UIControlStateNormal];
    }
}

- (void)nowPlayingController:(MPUNowPlayingController *)nowPlayingController nowPlayingInfoDidChange:(NSDictionary *)nowPlayingInfo {
    if ([nowPlayingInfo count] > 0){
        _mediaImageView.image = [nowPlayingController currentNowPlayingArtwork];
        NSString *title = [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
        NSString *artist = [nowPlayingInfo objectForKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
        _mediaTitleLabel.text = title;
        _mediaArtistLabel.text = artist;
        [UIView animateWithDuration:0.25 animations:^{
            if ([[CSMetroLockScreenSettingsManager sharedInstance] displayMediaControls])
                _mediaControlsView.alpha = 1.0f;
            [self layoutSubviews];
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            _mediaControlsView.alpha = 0.0f;
            [self layoutSubviews];
        }];
    }
}

- (void)activateSiri:(id)sender {
    SBAssistantController *assistantController = [objc_getClass("SBAssistantController") sharedInstance];
    if ([assistantController respondsToSelector:@selector(activatePluginForEvent:eventSource:context:)])
        [assistantController activatePluginForEvent:1 eventSource:1 context:nil];
    else
        [assistantController activatePluginForEvent:1 context:nil];
    [self resetLock];
}

- (void)_mediaPrevious:(id)sender {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    if ([mediaController respondsToSelector:@selector(changeTrack:)]) //9.x - 11.1
        [mediaController changeTrack:-1];
    else
        [mediaController changeTrack:-1 eventSource:0];
}

- (void)_mediaPlayPause:(id)sender {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    if ([mediaController respondsToSelector:@selector(togglePlayPause:)]) //9.x - 11.1
        [mediaController togglePlayPause];
    else
        [mediaController togglePlayPauseForEventSource:0];
}

- (void)_mediaForward:(id)sender {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    if ([mediaController respondsToSelector:@selector(changeTrack:)]) //9.x - 11.1
        [mediaController changeTrack:1];
    else
        [mediaController changeTrack:1 eventSource:0];
}

//ColorFlow Support

- (void)songAnalysisComplete:(nullable MPModelSong *)song
                     artwork:(nullable UIImage *)artwork
                   colorInfo:(nullable CFWColorInfo *)colorInfo { //ColorFlow 4
    // Color your UI here.
    if ([[objc_getClass("CFWPrefsManager") sharedInstance] isMetroLockScreenEnabled]){
        if ([colorInfo isBackgroundDark])
            [_mediaControlsView setGradientColor:[[colorInfo backgroundColor] colorWithAlphaComponent:0.75]];
        else
            [_mediaControlsView setLightGradientColor:[[colorInfo backgroundColor] colorWithAlphaComponent:0.75]];
        [_mediaTitleLabel setTextColor:[colorInfo primaryColor]];
        [_mediaArtistLabel setTextColor:[colorInfo secondaryColor]];

        _useDarkMediaButtons = ![colorInfo isBackgroundDark];
        if (![CSMetroLockScreenViewController imageNamed:@"media_previous_dark"]){
            _useDarkMediaButtons = NO; //Asset not present
        }

        if (_useDarkMediaButtons){
            [_mediaPreviousButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_previous_dark"] forState:UIControlStateNormal];
            if (_nowPlayingController.isPlaying)
                [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_pause_dark"] forState:UIControlStateNormal];
            else
                [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play_dark"] forState:UIControlStateNormal];
            [_mediaForwardButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_forward_dark"] forState:UIControlStateNormal];
        } else {
            [_mediaPreviousButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_previous"] forState:UIControlStateNormal];
            if (_nowPlayingController.isPlaying)
                [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_pause"] forState:UIControlStateNormal];
            else
                [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play"] forState:UIControlStateNormal];
            [_mediaForwardButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_forward"] forState:UIControlStateNormal];
        }
    } else {
        [self nowPlayingInfoHadNoArtwork:nil];
    }
}

- (void)nowPlayingInfo:(NSDictionary *)info 
               artwork:(UIImage *)artwork
      analysisComplete:(CFWAnalyzedInfo *)analyzedInfo { //ColorFlow 2 & 3
    CFWColorInfo *colorInfo = [objc_getClass("CFWColorInfo") colorInfoWithAnalyzedInfo:analyzedInfo.analyzedInfo];
    [self songAnalysisComplete:nil artwork:artwork colorInfo:colorInfo];
}

- (void)songHadNoArtwork:(nullable MPModelSong *)song { //ColorFlow 4
    [self nowPlayingInfoHadNoArtwork:nil];
}

- (void)nowPlayingInfoHadNoArtwork:(NSDictionary *)info {
  // Revert your UI here.
    [_mediaControlsView resetGradient];
    [_mediaTitleLabel setTextColor:[UIColor whiteColor]];
    [_mediaArtistLabel setTextColor:[UIColor whiteColor]];

    [_mediaPreviousButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_previous"] forState:UIControlStateNormal];
    if (_nowPlayingController.isPlaying)
        [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_pause"] forState:UIControlStateNormal];
    else
        [_mediaPlayPauseButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_play"] forState:UIControlStateNormal];
    [_mediaForwardButton setImage:[CSMetroLockScreenViewController imageNamed:@"media_forward"] forState:UIControlStateNormal];

    _useDarkMediaButtons = NO;
}

@end
