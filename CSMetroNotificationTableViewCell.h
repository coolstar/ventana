//
//  CSMetroNotificationTableViewCell.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBulletin.h"

@class NCNotificationRequest, NCNotificationAction;
@protocol CSMetroNotificationTableViewCellDelegate
- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action context:(NSDictionary *)context;
- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action;
- (void)handleResponseWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action response:(BBResponse *)response;
@end

@interface CSMetroNotificationTableViewCell : UITableViewCell <UITextFieldDelegate> {
    UIButton *_closeButton;
    UIButton *_replyButton;
    NSArray *_actionButtonTitles;
    UITextField *_replyField;
    BOOL _showsReplyField;
    
    NSMutableArray *_actionButtons;
    
    BBBulletin *_bulletin;
    BBAction *_currentAction;
}

@property (nonatomic, strong) NSArray *actionButtonItems;
@property (nonatomic, assign) BOOL showsReplyField;
@property (nonatomic, strong) BBBulletin *bulletin;
@property (nonatomic, strong) NCNotificationRequest *request;
@property (nonatomic, assign) BOOL hasTitle;

@property (nonatomic, weak) NSObject<CSMetroNotificationTableViewCellDelegate> *actionDelegate;

- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action;
- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action isReply:(BOOL)reply;

@end
