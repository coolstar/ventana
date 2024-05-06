//
//  CSMetroLockScreenNotificationButton.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/17/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenNotificationButton.h"
#import "CSMetroNotificationTableViewCell.h"

@implementation CSMetroLockScreenNotificationButton
- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted){
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    }
}

- (void)setupHandler {
	[self addTarget:self action:@selector(triggerNotification:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)triggerNotification:(id)sender {
	if (_bulletinAction)
		[_cell actionTriggeredWithBulletin:_bulletin action:_bulletinAction isReply:_bulletinIsReply];
	else
		[_cell actionTriggeredWithRequest:_request action:_requestAction];
}
@end
