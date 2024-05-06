#import <Foundation/Foundation.h>

@protocol CSMetroLockScreenViewControllerDelegate <NSObject>
- (void)unlock;
- (BOOL)unlockWithPasscode:(NSString *)passcode;
- (void)setPasscodeLockVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL success))completion;
@optional
- (void)setUnlockActionContext:(id)context;
- (void)setCustomLockScreenActionContext:(id)context;
- (void)resetLockScreenIdleTimer;
@end