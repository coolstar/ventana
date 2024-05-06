@interface PSSpecifier : NSObject
- (void)removePropertyForKey:(id)arg1;
@end

@interface PSListController : UITableViewController {
	id _specifiers;
}
- (id)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
- (UITableView *)table;
- (void)removeSpecifierID:(NSString *)arg1;
- (PSSpecifier *)specifierForID:(NSString *)arg1;
- (void)reloadSpecifierID:(NSString *)arg1;
@end