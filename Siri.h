@interface AFPreferences : NSObject
+ (instancetype)sharedPreferences;
- (NSString *)languageCode;
@end

@interface AFUtteranceSuggestions : NSObject {
	NSArray *_suggestedUtterances;
}
- (instancetype)initWithLanguageCode:(NSString *)languageCode delegate:(id)arg2;
- (NSString *)_suggestionsFilePath;
- (void)getSuggestedUtterancesWithCompletion:(void (^)(void))completion;
@end

@interface SUICSuggestions : NSObject {
	NSArray *_suggestedUtterances;
}
- (instancetype)initWithLanguageCode:(NSString *)languageCode delegate:(id)arg2;
- (void)getSuggestionsWithCompletion:(void (^)(void))completion;
@end