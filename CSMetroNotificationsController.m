//
//  CSMetroNotificationsController.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroNotificationsController.h"
#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenView.h"
#import "Headers.h"

static CSMetroNotificationsController *sharedNCObject;

@implementation CSMetroNotificationsController

- (id)init {
    self = [super init];
    if (self){
        _notifications = [[NSMutableArray alloc] init];
        _notificationsForSelectedSectionID = nil;
        _selectedSectionID = nil;
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    dispatch_once(&p, ^{
        sharedNCObject = [[self alloc] init];
    });
    return sharedNCObject;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_notificationsForSelectedSectionID count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSMetroNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSMetroNotificationCellIdentifier"];
    if (!cell){
        cell = [[CSMetroNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CSMetroNotificationCellIdentifier"];
    }
    NSDictionary *notification = [_notificationsForSelectedSectionID objectAtIndex:indexPath.section];
    cell.textLabel.text = [notification objectForKey:@"title"];
    cell.detailTextLabel.text = [notification objectForKey:@"message"];
    cell.imageView.image = [notification objectForKey:@"icon"];
    cell.bulletin = [notification objectForKey:@"bulletin"];
    cell.request = [notification objectForKey:@"request"];
    cell.actionButtonItems = [notification objectForKey:@"buttons"];
    cell.actionDelegate = self;

    if (!([notification objectForKey:@"title"] == nil || 
        [[notification objectForKey:@"title"] isEqualToString:@""] || 
        [[notification objectForKey:@"title"] isEqualToString:@" "]))
        cell.hasTitle = YES;
    else
        cell.hasTitle = NO;
    [cell layoutSubviews];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [_notificationsForSelectedSectionID objectAtIndex:indexPath.section];
    CGFloat height = 10;
    if (!([notification objectForKey:@"title"] == nil || 
        [[notification objectForKey:@"title"] isEqualToString:@""] || 
        [[notification objectForKey:@"title"] isEqualToString:@" "]))
        height = 30;
    height += [[notification objectForKey:@"message"] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(_tableView.frame.size.width - 74, 999.0) lineBreakMode:NSLineBreakByWordWrapping].height;
    if (height < 60)
        height = 60;
    if ([notification objectForKey:@"buttons"] != nil)
        height += 50;
    return height;
}

#pragma clang diagnostic pop

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSMutableArray *)sectionIDs {
    NSMutableArray *sectionIDs = [NSMutableArray array];
    for (NSDictionary *notification in _notifications){
        NSString *sectionID = [notification objectForKey:@"sectionID"];
        if (![sectionIDs containsObject:sectionID])
            [sectionIDs addObject:sectionID];
    }
    return sectionIDs;
}

- (void)selectedSectionID:(NSString *)sectionID {
    _selectedSectionID = sectionID;

    _notificationsForSelectedSectionID = [NSMutableArray array];
    for (NSDictionary *notification in _notifications){
        if (_selectedSectionID){
            if ([[notification objectForKey:@"sectionID"] isEqual:_selectedSectionID])
                [_notificationsForSelectedSectionID addObject:notification];
        } else {
            [_notificationsForSelectedSectionID addObject:notification];
        }
    }

    if ([_notificationsForSelectedSectionID count] == 0 && [_notifications count] != 0){
        [self selectedSectionID:nil];
        return;
    }

    [_tableView reloadData];
    [_notificationIconsView reloadData];

    if ([_notificationsForSelectedSectionID count] <= 0){
        [_lockScreenView setShouldShowNotificationLabel:NO];
    } else {
        [_lockScreenView setShouldShowNotificationLabel:YES];
    }
}

- (void)addNotificationWithIcon:(UIImage *)icon sectionID:(NSString *)sectionID title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin request:(NCNotificationRequest *)request buttons:(NSArray *)buttons {
    NSMutableDictionary *notification = [NSMutableDictionary dictionary];
    if (appTitle != nil)
        [notification setObject:appTitle forKey:@"title"];
    if (sectionID != nil)
        [notification setObject:sectionID forKey:@"sectionID"];
    if (message != nil)
        [notification setObject:message forKey:@"message"];
    if (icon != nil)
        [notification setObject:icon forKey:@"icon"];
    if (bulletin != nil)
        [notification setObject:bulletin forKey:@"bulletin"];
    if (request != nil)
        [notification setObject:request forKey:@"request"];
    if (buttons != nil)
        [notification setObject:buttons forKey:@"buttons"];
    [_notifications insertObject:notification atIndex:0];
    [self selectedSectionID:_selectedSectionID];
}

- (NSInteger)findIndexOfBulletin:(BBBulletin *)bulletin {
    NSInteger idx = 0;
    for (NSDictionary *notification in _notifications){
        if ([[notification objectForKey:@"bulletin"] isEqual:bulletin]){
            return idx;
        }
        idx++;
    }
    return -1;
}

- (void)modifyNotificationWithIcon:(UIImage *)icon sectionID:(NSString *)sectionID title:(NSString *)appTitle message:(NSString *)message bulletin:(BBBulletin *)bulletin request:(NCNotificationRequest *)request buttons:(NSArray *)buttons {
    NSInteger idx = [self findIndexOfBulletin:bulletin];
    if (idx == -1)
        return;
    NSMutableDictionary *notification = [NSMutableDictionary dictionary];
    if (appTitle != nil)
        [notification setObject:appTitle forKey:@"title"];
    if (sectionID != nil)
        [notification setObject:sectionID forKey:@"sectionID"];
    if (message != nil)
        [notification setObject:message forKey:@"message"];
    if (icon != nil)
        [notification setObject:icon forKey:@"icon"];
    if (bulletin != nil)
        [notification setObject:bulletin forKey:@"bulletin"];
    if (request != nil)
        [notification setObject:request forKey:@"request"];
    if (buttons != nil)
        [notification setObject:buttons forKey:@"buttons"];
    [_notifications replaceObjectAtIndex:idx withObject:notification];
    [self selectedSectionID:_selectedSectionID];
}

- (void)removeNotificationWithBulletin:(BBBulletin *)bulletin {
    NSInteger idx = [self findIndexOfBulletin:bulletin];
    if (idx == -1)
        return;
    [_notifications removeObjectAtIndex:idx];
    [self selectedSectionID:_selectedSectionID];
}

- (void)clearNotifications {
    _selectedSectionID = nil;
    [_notifications removeAllObjects];
    [_notificationsForSelectedSectionID removeAllObjects];
    [_lockScreenView setShouldShowNotificationLabel:NO];
    [_tableView reloadData];
    [_notificationIconsView reloadData];
}

- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action context:(NSDictionary *)context {
    if (action.activationMode == UIUserNotificationActivationModeBackground){
        void (^actionBlock)() = [bulletin actionBlockForAction:action];
        if (actionBlock){
            actionBlock();

            BBServer *bulletinServer = [objc_getClass("BBServer") sharedBBServer];

            NSMutableSet *observers = [bulletinServer valueForKey:@"_observers"];
            BBObserverClientProxy *observer = [observers anyObject];
            dispatch_queue_t queue = [observer queue];
            dispatch_sync(queue, ^{
                [bulletinServer _clearBulletinIDs:@[bulletin.bulletinID] forSectionID:bulletin.sectionID shouldSync:YES];
            });
        } else {
            NSString *message = [NSString stringWithFormat:@"An expected error occurred handling this action.\nDetails: %@ %@\nPlease take a screenshot and message @coolstarorg.", bulletin.sectionID, action.appearance.title];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    CSMetroLockScreenViewController *lockScreenController = [CSMetroLockScreenViewController sharedLockScreenController];
    [lockScreenController actionTriggeredWithBulletin:bulletin action:action context:context];
}

- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action {
    CSMetroLockScreenViewController *lockScreenController = [CSMetroLockScreenViewController sharedLockScreenController];
    [lockScreenController actionTriggeredWithRequest:request action:action];
}

- (void)handleResponseWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action response:(BBResponse *)response {
    BBServer *bulletinServer = [objc_getClass("BBServer") sharedBBServer];

    NSMutableSet *observers = [bulletinServer valueForKey:@"_observers"];
    BBObserverClientProxy *observer = [observers anyObject];
    
    __block BBResponse *blockResponse = response;
    if ([observer respondsToSelector:@selector(handleResponse:withCompletion:)]){
        [observer handleResponse:blockResponse withCompletion:^{
            [observer clearBulletinIDs:@[bulletin.bulletinID] inSection:bulletin.sectionID];
        }];
    }
    else {
        dispatch_queue_t queue = [observer queue];
        dispatch_sync(queue, ^{
            if ([observer respondsToSelector:@selector(handleResponse:)])
                [observer handleResponse:blockResponse];
            [bulletinServer _clearBulletinIDs:@[bulletin.bulletinID] forSectionID:bulletin.sectionID shouldSync:YES];
        });
    }
}
@end
