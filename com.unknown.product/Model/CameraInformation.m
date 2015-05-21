#import "CameraInformation.h"

@implementation CameraInformation

@synthesize title = _title;
@synthesize coordinate2D = _coordinate2D;
@synthesize objectType = _objectType;
@synthesize alertDistance = _alertDistance;
@synthesize identifier = _identifier;

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, identity: %@, title: %@>", NSStringFromClass([self class]), self, self.identifier, self.title];
}

- (instancetype)initWithIdentifier:(NSUUID *)identifier {
    if (self = [self init]) {
        self.identifier = identifier;
        self.objectType = kObjectTypeCamera;
    }
    return self;
}

@end
