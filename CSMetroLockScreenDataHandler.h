//
//  CSMetroLockScreenDataHandler.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/6/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSMetroLockScreenDataHandler : NSObject {
    BOOL _inAirplaneMode;
    BOOL _hasCellSignal;
    int _cellSignalBars;
    int _wifiSignalStrengthBars;
    BOOL _wifiConnectedAndAssociated;
}

@property (nonatomic, assign) BOOL inAirplaneMode;
@property (nonatomic, assign) BOOL hasCellSignal;
@property (nonatomic, assign) int cellSignalBars;
@property (nonatomic, assign) int wifiSignalStrengthBars;
@property (nonatomic, assign) BOOL wifiConnectedAndAssociated;

+ (instancetype)sharedObject;

@end
