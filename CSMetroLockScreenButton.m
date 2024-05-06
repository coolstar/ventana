//
//  CSMetroLockScreenButton.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/6/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenButton.h"

@implementation CSMetroLockScreenButton

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted){
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
}

@end
