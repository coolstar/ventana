//
//  CSMetroLockScreenTextField.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenTextField.h"

@implementation CSMetroLockScreenTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + 5, bounds.origin.y + 2,
                      bounds.size.width - 10, bounds.size.height - 4);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
