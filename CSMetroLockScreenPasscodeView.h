//
//  CSMetroLockScreenPasscodeView.h
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSMetroLockScreenPasscodeView : UIView <UITextFieldDelegate> {
    UITextField *_passcodeField;
    UIButton *_passcodeBtn;
    
    UILabel *_passcodeFailed;
    UIButton *_passcodeRetry;
    
    UIImageView *_avatarImg;
    
    BOOL _keyboardIsShowing;
    CGFloat _keyboardHeight;
}

- (void)focusTextField;
- (void)resetLock;

@end
