#import "Preferences.h"

@interface CSMLSAdvancedSettingsController: PSListController {
}
@end

@implementation CSMLSAdvancedSettingsController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Advanced" target:self];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		[self removeSpecifierID:@"mediaPlayerBackdrop"];
	}
}
@end