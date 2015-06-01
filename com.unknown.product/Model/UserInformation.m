#import "UserInformation.h"
#import "CameraInformation.h"

@implementation UserInformation

- (id)init {
    if (self = [super init]) {
        self.objects = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"objects" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

+ (id<ObjectGeneral>)objectWithIdentifier:(NSUUID *)identifier {
    NSArray *filteredObjects = [[[self sharedInstance] objects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ObjectGeneral> evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject identifier] isEqual:identifier];
    }]];
    NSAssert([filteredObjects count] <= 1, @"添加对象时出错，两条一样的身份标识");
    return [filteredObjects firstObject];
}

+ (id<ObjectGeneral>)objectWithIdentifier:(NSUUID *)identifier type:(kObjectType)type {
    id<ObjectGeneral> result = [self objectWithIdentifier:identifier];
    if (result != nil) {
        NSAssert([result objectType] == type, @"查询出错，和被查询的类型不一样");
        return result;
    } else {
        switch (type) {
            case kObjectTypeCamera:
                result = [[CameraInformation alloc] initWithIdentifier:identifier];
                break;
            default:
                break;
        }
        return result;
    }
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSNumber *kindValue = [change objectForKey:NSKeyValueChangeKindKey];
//    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//    id indexesValue = [change objectForKey:NSKeyValueChangeIndexesKey];
//
//    if ([kindValue isEqual:[NSNumber numberWithInteger:NSKeyValueChangeInsertion]]) {
//    }

//    if ([keyPath isEqualToString:@"objects"]) {
//        [self.tableView reloadData];
//    }
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
