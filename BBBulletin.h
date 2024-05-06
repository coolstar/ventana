#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BBAppearance : NSObject {
    int  _style;
    NSString * _title;
    NSString * _viewClassName;
}

@property (nonatomic) int style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *viewClassName;

+ (BBAppearance *)appearanceWithTitle:(NSString *)arg1;

@end

@interface BBResponse : NSObject
@property (nonatomic, copy) NSDictionary *context;
@end

@interface BBAction : NSObject
@property (nonatomic, copy) BBAppearance *appearance;
@property (nonatomic) int behavior;
@property (nonatomic) int activationMode;

- (BOOL)isURLLaunchAction;
- (BOOL)isAppLaunchAction;
- (BOOL)hasPluginAction;
- (BOOL)hasRemoteViewAction;
- (id)launchBundleID;
- (id)launchURL;
- (id)internalBlock;
- (NSString *)identifier;
- (BOOL)canBypassPinLock;
@end

@interface BBAttachments : NSObject
@end

@interface BBContent : NSObject
@end

@interface BBSound : NSObject
@end

@interface BBSectionIcon : NSObject

@end

@interface BBBulletin : NSObject {
}

@property (nonatomic, copy) NSString *bulletinID;
@property(copy) BBAction * defaultAction;
@property(readonly) NSString * fullUnlockActionLabel;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly) unsigned int messageNumberOfLines;
@property(copy) NSString * sectionID;
@property BOOL showsMessagePreview;
@property(copy) BBAction * snoozeAction;
@property (nonatomic, copy) NSString *subtitle;
@property(readonly) BOOL suppressesMessageForPrivacy;
@property (nonatomic, readonly) BOOL suppressesTitle;
@property (nonatomic, copy) NSString *title;
@property(readonly) NSString * unlockActionLabel;

- (NSArray <BBAction *> *)supplementaryActions;

- (void (^)())actionBlockForAction:(BBAction *)action;
- (BBResponse *)responseForAction:(BBAction *)action;

@end

@interface BBServer : NSObject
+ (BBServer *)sharedBBServer;
- (void)_clearBulletinIDs:(NSArray *)arg1 forSectionID:(NSString *)arg2 shouldSync:(BOOL)arg3;
@end

@interface BBObserverClientProxy : NSObject
- (void)handleResponse:(BBResponse *)arg1;
- (void)handleResponse:(BBResponse *)arg1 withCompletion:(/*^block*/id)arg2;
-(void)clearBulletinIDs:(id)arg1 inSection:(id)arg2 ;
- (dispatch_queue_t)queue;
@end