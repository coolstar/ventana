#import "BBBulletin.h"

static BBServer *SharedBBServer;

%hook BBServer
%new;
+ (instancetype)sharedBBServer {
	return SharedBBServer;
}

- (instancetype)init {
	self = %orig;
	SharedBBServer = self;
	return self;
}

//iOS 11
-(id)initWithQueue:(id)arg1 {
	self = %orig;
	SharedBBServer = self;
	return self;
}
%end