#import "CSMetroLockScreenGradientView.h"
#import "CSMetroLockScreenSettingsManager.h"

@implementation CSMetroLockScreenGradientView
- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self){
		_gradientLayer = [CAGradientLayer layer];
		if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
			_gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor];
		else
			_gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
		_gradientLayer.locations = @[@0, @0.5, @1];
		[self.layer addSublayer:_gradientLayer];

		_savedGradient = _gradientLayer.colors;

		if (![[CSMetroLockScreenSettingsManager sharedInstance] mediaPlayerBackdrop])
			_gradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
	}
	return self;
}
 
- (void)refreshGradient {
	if (![[CSMetroLockScreenSettingsManager sharedInstance] mediaPlayerBackdrop])
		_gradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
	else
		_gradientLayer.colors = _savedGradient;
}

- (void)setLightGradientColor:(UIColor *)gradientColor {
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		_gradientLayer.colors = @[(id)gradientColor.CGColor, (id)[gradientColor colorWithAlphaComponent:0.5].CGColor, (id)[gradientColor colorWithAlphaComponent:0.3].CGColor];
	else
		_gradientLayer.colors = @[(id)gradientColor.CGColor, (id)gradientColor.CGColor, (id)gradientColor.CGColor];
	_gradientLayer.locations = @[@0, @0.8, @1];

	_savedGradient = _gradientLayer.colors;

	if (![[CSMetroLockScreenSettingsManager sharedInstance] mediaPlayerBackdrop])
		_gradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
}

- (void)setGradientColor:(UIColor *)gradientColor {
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		_gradientLayer.colors = @[(id)gradientColor.CGColor, (id)[gradientColor colorWithAlphaComponent:0.5].CGColor, (id)[gradientColor colorWithAlphaComponent:0.3].CGColor];
	else
		_gradientLayer.colors = @[(id)gradientColor.CGColor, (id)gradientColor.CGColor, (id)gradientColor.CGColor];
	_gradientLayer.locations = @[@0, @0.5, @1];

	_savedGradient = _gradientLayer.colors;

	if (![[CSMetroLockScreenSettingsManager sharedInstance] mediaPlayerBackdrop])
		_gradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
}

- (void)resetGradient {
	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
		_gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor];
	else
		_gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
	_gradientLayer.locations = @[@0, @0.5, @1];

	_savedGradient = _gradientLayer.colors;

	if (![[CSMetroLockScreenSettingsManager sharedInstance] mediaPlayerBackdrop])
		_gradientLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor];
}

- (void)layoutSubviews {
	_gradientLayer.frame = self.bounds;
	[super layoutSubviews];
}
@end