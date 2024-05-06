#import <Social/Social.h>
#import "Preferences.h"
#import <spawn.h>

extern char **environ;

@interface CSMLSRootListController: PSListController {
}
@end

@implementation CSMLSRootListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"MetroLockScreenSettings" target:self];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 121)];
	headerView.tag = 23491234;
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[headerView setBackgroundColor:[UIColor colorWithWhite:(43.0f/255.0f) alpha:1.0f]];

	UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,121)];
	titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[titleView setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/MetroLockScreenSettings.bundle/banner.png"]];
	[titleView setBackgroundColor:[UIColor colorWithWhite:(43.0f/255.0f) alpha:1.0f]];
	[headerView addSubview:titleView];

	[[self table] addSubview:headerView];
	[[self table] setContentOffset:CGPointMake(0,0)];

	if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad){
		[self removeSpecifierID:@"siriTitle"];
		[self removeSpecifierID:@"displaySiri"];
	}

	if (kCFCoreFoundationVersionNumber < 1300){
		[self removeSpecifierID:@"nativeNotifications"];

		PSSpecifier *notificationsTitle = [self specifierForID:@"notificationsTitle"];
		[notificationsTitle removePropertyForKey:@"footerText"];

		[self reloadSpecifierID:@"notificationsTitle"];
	}

	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/MetroLockScreenSettings.bundle/heart.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tweet:)]];
}

- (void)tweet:(id)sender {
	SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[tweetSheet setInitialText:@"I am loving #Ventana by @coolstarorg and @JeremyGoulet!"];
	[self presentViewController:tweetSheet animated:YES completion:nil];
}

- (void)respring:(id)sender {
	pid_t pid;
	posix_spawn(&pid, "sbreload", NULL, NULL, (char **)&(const char*[]){"sbreload"}, environ);
}

- (void)coolstarTwitter:(id)sender {
	NSString *user = @"coolstarorg";
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

- (void)jeremyTwitter:(id)sender {
	NSString *user = @"JeremyGoulet";
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	
	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}
@end