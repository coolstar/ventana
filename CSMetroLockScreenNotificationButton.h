//
//  CSMetroLockScreenNotificationButton.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/17/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSMetroNotificationTableViewCell, BBBulletin, BBAction, NCNotificationRequest, NCNotificationAction;
@interface CSMetroLockScreenNotificationButton : UIButton
- (void)setupHandler;

@property (nonatomic, strong) BBBulletin *bulletin;
@property (nonatomic, strong) BBAction *bulletinAction;

@property (nonatomic, strong) NCNotificationRequest *request;
@property (nonatomic, strong) NCNotificationAction *requestAction;

@property (nonatomic, assign) BOOL bulletinIsReply;
@property (nonatomic, weak) CSMetroNotificationTableViewCell *cell;
@end
