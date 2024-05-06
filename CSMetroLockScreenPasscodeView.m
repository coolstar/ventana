//
//  CSMetroLockScreenPasscodeView.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/5/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroLockScreenViewController.h"
#import "CSMetroLockScreenPasscodeView.h"
#import "CSMetroLockScreenTextField.h"
#import "CSMetroLockScreenButton.h"
#import "Headers.h"

@implementation CSMetroLockScreenPasscodeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        _avatarImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_avatarImg setBackgroundColor:[UIColor whiteColor]];
        #if TARGET_IPHONE_SIMULATOR
            [_avatarImg setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"win10-2" ofType:@"jpg"]]];
        #else
            [_avatarImg setImage:[UIImage imageWithContentsOfFile:@"/var/mobile/avatar.jpg"]];
        #endif
        [_avatarImg.layer setMinificationFilter:kCAFilterTrilinear];
        [_avatarImg setClipsToBounds:YES];
        [_avatarImg setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_avatarImg];
        
        _passcodeField = [[CSMetroLockScreenTextField alloc] initWithFrame:CGRectZero];
        [_passcodeField setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [_passcodeField setBorderStyle:UITextBorderStyleNone];
        [_passcodeField setSecureTextEntry:YES];
        [_passcodeField setPlaceholder:@"Password"];
        [_passcodeField setDelegate:self];
        [_passcodeField setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [self addSubview:_passcodeField];
        _passcodeField.layer.borderWidth = 1;
        _passcodeField.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.5] CGColor];
        
        _passcodeBtn = [[CSMetroLockScreenButton alloc] initWithFrame:CGRectZero];
        [_passcodeBtn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [_passcodeBtn setImage:[CSMetroLockScreenViewController imageNamed:@"arrow"] forState:UIControlStateNormal];
        [_passcodeBtn addTarget:self action:@selector(unlock) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_passcodeBtn];
        _passcodeBtn.layer.borderWidth = 1;
        _passcodeBtn.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.5] CGColor];
        
        _passcodeFailed = [[UILabel alloc] initWithFrame:CGRectZero];
        [_passcodeFailed setText:@"The password is incorrect. Try again."];
        [_passcodeFailed setTextColor:[UIColor whiteColor]];
        [_passcodeFailed setFont:[UIFont systemFontOfSize:14]];
        [_passcodeFailed setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_passcodeFailed];
        
        _passcodeRetry = [[CSMetroLockScreenButton alloc] initWithFrame:CGRectZero];
        [_passcodeRetry setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [_passcodeRetry setTitle:@"OK" forState:UIControlStateNormal];
        [_passcodeRetry addTarget:self action:@selector(resetLock) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_passcodeRetry];
        
        _passcodeFailed.alpha = 0;
        _passcodeRetry.alpha = 0;
        
        UITapGestureRecognizer *dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:_passcodeField action:@selector(resignFirstResponder)];
        dismissKeyboard.numberOfTapsRequired = 1;
        [self addGestureRecognizer:dismissKeyboard];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = self.frame;
    
    CGRect avatarImgFrame = CGRectZero;
    CGRect passcodeFieldFrame = CGRectZero;
    CGRect passcodeBtnFrame = CGRectZero;
    CGRect passcodeFailedFrame = CGRectZero;
    CGRect passcodeOkBtnFrame = CGRectZero;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        CGFloat avatarY = (frame.size.height - 230.f)/2.f;
        
        if (_keyboardIsShowing){
            if (avatarY + 230.f > frame.size.height - (_keyboardHeight + 20.0f))
                avatarY = frame.size.height - (_keyboardHeight + 20.0f + 230.0f);
            else
                avatarY -= 20.f;
        }
        
        avatarImgFrame = CGRectMake(frame.size.width/2.f - 75.f, avatarY, 150, 150);
        
        CGFloat passcodeX = (frame.size.width - 300.f)/2.f;
        
        passcodeFieldFrame = CGRectMake(passcodeX, avatarY + 200, 270, 32);
        passcodeBtnFrame = CGRectMake(passcodeX + 270.f, avatarY + 200, 32, 32);
        
        passcodeFailedFrame = CGRectMake(passcodeX, avatarY + 190, 300, 30);
        passcodeOkBtnFrame = CGRectMake(passcodeX + 100, avatarY + 230, 100, 30);
    } else {
        CGFloat avatarY = (frame.size.height - 150.f)/2.0f;
        
        if (_keyboardIsShowing){
            if (avatarY + 150.f > frame.size.height - (_keyboardHeight + 20.0f))
                avatarY = frame.size.height - (_keyboardHeight + 20.0f + 150.f
                                               );
            else
                avatarY -= 20.f;
        }
        
        avatarImgFrame = CGRectMake(frame.size.width/2.f - 45, avatarY, 90, 90);
        
        CGFloat passcodeX = (frame.size.width - 250.f)/2.f;
        
        passcodeFieldFrame = CGRectMake(passcodeX, avatarY + 120, 220, 32);
        passcodeBtnFrame = CGRectMake(passcodeX + 220, avatarY + 120, 32, 32);
        
        passcodeFailedFrame = CGRectMake(passcodeX, avatarY + 110, 250, 30);
        passcodeOkBtnFrame = CGRectMake(passcodeX + 85, avatarY + 150, 80, 30);
    }
    _avatarImg.frame = avatarImgFrame;
    _passcodeField.frame = passcodeFieldFrame;
    _passcodeBtn.frame = passcodeBtnFrame;
    _passcodeFailed.frame = passcodeFailedFrame;
    _passcodeRetry.frame = passcodeOkBtnFrame;
    _avatarImg.layer.cornerRadius = _avatarImg.bounds.size.width / 2.0f;
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    [aValue getValue:&keyboardBounds];
    _keyboardHeight = keyboardBounds.size.height;
    _keyboardIsShowing = YES;
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutSubviews];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardBounds;
    NSValue *aValue = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    [aValue getValue: &keyboardBounds];
    
    _keyboardHeight = keyboardBounds.size.height;
    _keyboardIsShowing = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutSubviews];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self unlock];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [[CSMetroLockScreenViewController sharedLockScreenController] cancelDimTimer];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[CSMetroLockScreenViewController sharedLockScreenController] restartDimTimer];
}

- (void)focusTextField {
    [_passcodeField becomeFirstResponder];
}

- (void)unlock {
    [_passcodeField resignFirstResponder];
    NSString *passcode = [_passcodeField text];

    if ([[objc_getClass("MCPasscodeManager") sharedManager] unlockDeviceWithPasscode:passcode outError:nil]){
        [[objc_getClass("MCPasscodeManager") sharedManager] lockDeviceImmediately:YES];
        [UIView animateWithDuration:0.25 animations:^{
            _avatarImg.alpha = 0;
            _passcodeField.alpha = 0;
            _passcodeBtn.alpha = 0;
        } completion:^(BOOL completed){
            [[CSMetroLockScreenViewController sharedLockScreenController] unlockWithPasscode:passcode];
        }];
    } else {
        _avatarImg.alpha = 1;
        _passcodeField.alpha = 0;
        _passcodeBtn.alpha = 0;
        _passcodeFailed.alpha = 1;
        _passcodeRetry.alpha = 1;
    }
}

- (void)resetLock {
    [_passcodeField setText:@""];
    _avatarImg.alpha = 1;
    _passcodeField.alpha = 1;
    _passcodeBtn.alpha = 1;
    _passcodeFailed.alpha = 0;
    _passcodeRetry.alpha = 0;
    
    [_passcodeField setKeyboardType:UIKeyboardTypeNumberPad];
    [_passcodeField resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
