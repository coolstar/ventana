//
//  CSMetroLockScreenDataHandler.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/6/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenDataHandler.h"

static CSMetroLockScreenDataHandler *sharedObject;

@implementation CSMetroLockScreenDataHandler
+ (instancetype)sharedObject {
    if (!sharedObject)
        sharedObject = [[self alloc] init];
    return sharedObject;
}
@end
