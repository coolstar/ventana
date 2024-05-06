//
//  CSMetroNotificationIconsView.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroNotificationIconsView.h"
#import "CSMetroNotificationsController.h"
#import "CSMetroLockScreenButton.h"
#import "Headers.h"

@implementation CSMetroNotificationIconsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        _notificationIcons = [[NSMutableArray alloc] init];
        
        _highlightView = [[UIView alloc] initWithFrame:CGRectZero];
        [_highlightView setBackgroundColor:[UIColor colorWithRed:61.0/255.0 green:93.0/255.0 blue:156.0/255.0 alpha:0.75]];
        _highlightView.layer.cornerRadius = 4;
        [self addSubview:_highlightView];
        
        /*UIImageView *notificationIcon = nil;
        
        notificationIcon = [[UIImageView alloc] init];
        notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/twitter.png"];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];
        
        notificationIcon = [[UIImageView alloc] init];
        notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/snapchat.png"];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];
        
        notificationIcon = [[UIImageView alloc] init];
        notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/skype.png"];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];
        
        notificationIcon = [[UIImageView alloc] init];
        notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/slack.png"];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];
        
        notificationIcon = [[UIImageView alloc] init];
        notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/google inbox.png"];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];*/
    }
    return self;
}

- (void)reloadData {
    CSMetroNotificationsController *nc = [CSMetroNotificationsController sharedInstance];
    _sectionIDs = [nc sectionIDs];

    _selectedSectionID = [nc selectedSectionID];

    for (UIView *notificationIcon in _notificationIcons){
        [notificationIcon removeFromSuperview];
    }
    [_notificationIcons removeAllObjects];

    if (_selectedSectionID){
        _highlightView.alpha = 1.0f;
    } else {
        _highlightView.alpha = 0.0f;
    }

    for (NSString *sectionID in _sectionIDs){
        CSMetroLockScreenButton *notificationIcon = [[CSMetroLockScreenButton alloc] init];

        SBApplication *application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:sectionID];
        SBApplicationIcon *icon = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:application];
        UIImage *image = nil;
        if ([icon respondsToSelector:@selector(generateIconImage:)])
            image = [icon generateIconImage:0];
        else {
            struct SBIconImageInfo imageInfo;
            imageInfo.size = CGSizeMake(24,24);
            imageInfo.scale = [UIScreen mainScreen].scale;
            imageInfo.continuousCornerRadius = 5;
            image = [icon generateIconImageWithInfo:imageInfo];
        }

        //notificationIcon.image = [CSMetroLockScreenViewController imageNamed:@"apps/skype.png"];
        [notificationIcon setImage:image forState:UIControlStateNormal];
        [notificationIcon.layer setMinificationFilter:kCAFilterTrilinear];
        [notificationIcon addTarget:self action:@selector(selectNotificationIcon:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:notificationIcon];
        [_notificationIcons addObject:notificationIcon];
    }
    [self layoutSubviews];
}

- (void)selectNotificationIcon:(CSMetroLockScreenButton *)sender {
    NSInteger idx = [_notificationIcons indexOfObject:sender];
    NSString *sectionID = [_sectionIDs objectAtIndex:idx];

    CSMetroNotificationsController *nc = [CSMetroNotificationsController sharedInstance];

    if ([_selectedSectionID isEqual:sectionID])
        [nc selectedSectionID:nil];
    else
        [nc selectedSectionID:sectionID];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat x = 4;
    for (CSMetroLockScreenButton *icon in _notificationIcons){
        icon.frame = CGRectMake(x, 4, 24, 24);
        x += 34;
    }

    if (_selectedSectionID){
        NSInteger idx = [_sectionIDs indexOfObject:_selectedSectionID];
        CGFloat x = 4;
        x += (idx * 34);

        _highlightView.frame = CGRectMake(x - 4, 0, 32, 32);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
