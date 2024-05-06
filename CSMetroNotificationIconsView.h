//
//  CSMetroNotificationIconsView.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSMetroNotificationIconsView : UIView {
    NSMutableArray *_notificationIcons;
    NSMutableArray *_sectionIDs;
    NSString *_selectedSectionID;
    UIView *_highlightView;
}

- (void)reloadData;

@end
