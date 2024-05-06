//
//  CSNotificationTableViewCell.m
//  MetroLockScreen
//
//  Created by CoolStar on 8/16/16.
//  Copyright © 2016 CoolStar. All rights reserved.
//

#import "CSMetroNotificationTableViewCell.h"
#import "CSMetroLockScreenTextField.h"
#import "CSMetroLockScreenButton.h"
#import "CSMetroLockScreenNotificationButton.h"
#import "CSMetroLockScreenViewController.h"
#import "Headers.h"

@implementation CSMetroNotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _replyField = [[CSMetroLockScreenTextField alloc] initWithFrame:CGRectZero];
        [_replyField setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [_replyField setBorderStyle:UITextBorderStyleNone];
        [_replyField setPlaceholder:@"Reply"];
        [_replyField setDelegate:self];
        [self addSubview:_replyField];

        _replyButton = [[CSMetroLockScreenButton alloc] initWithFrame:CGRectZero];
        [_replyButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [_replyButton setImage:[CSMetroLockScreenViewController imageNamed:@"arrow"] forState:UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(sendReply:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_replyButton];
        _replyButton.layer.borderWidth = 1;
        _replyButton.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.5] CGColor];

        _actionButtons = [[NSMutableArray alloc] init];
        
        //[self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
        [self setBackgroundColor:[UIColor colorWithRed:61.0/255.0 green:93.0/255.0 blue:156.0/255.0 alpha:0.5]];
        
        [[self textLabel] setTextColor:[UIColor whiteColor]];
        [[self detailTextLabel] setTextColor:[UIColor whiteColor]];

        [[self textLabel] setFont:[UIFont systemFontOfSize:12]];
        [[self detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(15, 15, 32, 32);
    
    CGRect frame = self.textLabel.frame;
    frame.origin.y = 15;
    self.textLabel.frame = frame;
    
    frame = self.detailTextLabel.frame;
    if (_hasTitle){
        self.textLabel.alpha = 1.0f;
        frame.origin.y = 35;
    }
    else {
        self.textLabel.alpha = 0.0f;
        frame.origin.y = 15;
    }
    self.detailTextLabel.frame = frame;

    _replyField.alpha = 0.0;
    _replyButton.alpha = 0.0;

    _replyField.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width - 40, 40);
    _replyButton.frame = CGRectMake(self.bounds.size.width - 40, self.bounds.size.height - 40, 40, 40);
    
    for (UIButton *button in _actionButtons){
        [button removeFromSuperview];
    }

    int x = 0;
    float width = self.bounds.size.width / (float)[_actionButtonItems count];
    width = trunc(width);
    
    int i = 0;
    
    for (NSMutableDictionary *item in _actionButtonItems){
        CGFloat buttonX = x;
        CGFloat buttonWidth = width;
        if (i != 0)
            buttonX += 1;
        if (i != [_actionButtonItems count]-1)
            buttonWidth -= 2;
        else
            buttonWidth -= 1;

        NSString *title = [item objectForKey:@"title"];
        
        CSMetroLockScreenNotificationButton *button = [[CSMetroLockScreenNotificationButton alloc] initWithFrame:CGRectZero];
        [button setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
        [button setTitle:title forState:UIControlStateNormal];
        [button setBulletin:_bulletin];
        [button setBulletinAction:[item objectForKey:@"action"]];

        [button setRequest:_request];
        [button setRequestAction:[item objectForKey:@"raction"]];

        [button setBulletinIsReply:[[item objectForKey:@"response"] boolValue]];
        [button setCell:self];
        [button setupHandler];
        [_actionButtons addObject:button];
        [self addSubview:button];

        button.frame = CGRectMake(buttonX, self.bounds.size.height - 40, buttonWidth, 40);

        x += width;
        i++;
    }
}

- (void)actionTriggeredWithRequest:(NCNotificationRequest *)request action:(NCNotificationAction *)action {
    [_actionDelegate actionTriggeredWithRequest:request action:action];
}

- (void)actionTriggeredWithBulletin:(BBBulletin *)bulletin action:(BBAction *)action isReply:(BOOL)isReply {
    if (isReply){
        _currentAction = action;
        [[CSMetroLockScreenViewController sharedLockScreenController] cancelDimTimer];
        [UIView animateWithDuration:0.25 animations:^{
            for (UIButton *button in _actionButtons){
                button.alpha = 0.0f;
            }
            _replyField.alpha = 1.0f;
            _replyButton.alpha = 1.0f;
        }];
    }
    else {
        [_actionDelegate actionTriggeredWithBulletin:bulletin action:action context:nil];
    }
}

- (void)sendReply:(id)sender {
    BBResponse *bbresponse = [_bulletin responseForAction:_currentAction];
    NSMutableDictionary *context = [bbresponse.context mutableCopy];
    if (context == nil)
        context = [[NSMutableDictionary alloc] init];

    context[@"userResponseInfo"] = @{@"UIUserNotificationActionResponseTypedTextKey": _replyField.text};
    bbresponse.context = context;
    [_actionDelegate handleResponseWithBulletin:_bulletin action:_currentAction response:bbresponse];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self sendReply:nil];
    return NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
