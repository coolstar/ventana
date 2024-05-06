//
//  CSMetroNotificationsController.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBulletin.h"
#import "CSMetroNotificationTableViewCell.h"
#import "CSMetroNotificationIconsView.h"

@class CSMetroLockScreenView, NCNotificationRequest;
@interface CSMetroNotificationsController : NSObject <UITableViewDelegate, UITableViewDataSource, CSMetroNotificationTableViewCellDelegate> {
    NSMutableArray *_notifications;
    NSMutableArray *_notificationsForSelectedSectionID;
    UITableView *_tableView;
    CSMetroLockScreenView *_lockScreenView;
    NSString *_selectedSectionID;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CSMetroNotificationIconsView *notificationIconsView;
@property (nonatomic, strong) CSMetroLockScreenView *lockScreenView;
@property (nonatomic, strong, readonly) NSString *selectedSectionID;

+ (id)sharedInstance;

- (void)selectedSectionID:(NSString *)sectionID;

- (NSMutableArray *)sectionIDs;

- (void)addNotificationWithIcon:(UIImage *)icon sectionID:(NSString *)sectionID title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin request:(NCNotificationRequest *)request buttons:(NSArray *)buttons;
- (void)modifyNotificationWithIcon:(UIImage *)icon sectionID:(NSString *)sectionID title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin request:(NCNotificationRequest *)request buttons:(NSArray *)buttons;
- (void)removeNotificationWithBulletin:(BBBulletin *)bulletin;
- (void)clearNotifications;

- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action context:(NSDictionary *)context;
- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action;
- (void)handleResponseWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action response:(BBResponse *)response;
@end
