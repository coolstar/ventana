#import <UIKit/UIKit.h>

@interface CSMetroLockScreenGradientView : UIView {
	CAGradientLayer *_gradientLayer;
	NSArray *_savedGradient;
}
- (void)setLightGradientColor:(UIColor *)gradientColor;
- (void)setGradientColor:(UIColor *)gradientColor;
- (void)refreshGradient;
- (void)resetGradient;
@end