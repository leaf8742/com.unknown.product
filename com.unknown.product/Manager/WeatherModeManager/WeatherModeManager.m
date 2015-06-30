#import "WeatherModeManager.h"
#import "CommunicationMgr.h"

@implementation WeatherModeManager

+ (void)sendPattern {
    switch ([[self sharedInstance] weatherMode]) {
        case kWeatherModeOvercast:
            [[CommunicationMgr sharedInstance] sendOvercast];
            break;
        case kWeatherModeWet:
            [[CommunicationMgr sharedInstance] sendWet];
            break;
        case kWeatherModeDusk:
            [[CommunicationMgr sharedInstance] sendDusk];
            break;
        case kWeatherModeNight:
            [[CommunicationMgr sharedInstance] sendNight];
            break;
        case kWeatherModeSOS:
            [[CommunicationMgr sharedInstance] sendSOS];
            break;
        default:
            break;
    }
}

#pragma mark - Signleton Implementation
+ (instancetype)sharedInstance {
    static id sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [NSAllocateObject([self class], 0, NULL) init];
    });
    return sharedClient;
}

+ (id)allocWithZone:(NSZone *)zone {
    static id result;
    result = nil;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        result = [self sharedInstance];
    });
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

@end
