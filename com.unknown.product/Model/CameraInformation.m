#import "CameraInformation.h"
#import "DeviceManager.h"

@interface CameraInformation()

@property (strong, nonatomic) NSTimer *timer;

@end

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


- (id)init {
    if (self = [super init]) {
        [self addObserver:self forKeyPath:@"RSSI" options:NSKeyValueObservingOptionNew context:nil];
        self.timer = [NSTimer timerWithTimeInterval:.5 target:self selector:@selector(readBLEServiceRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"RSSI"];
}

- (void)readBLEServiceRSSI {
    if (self.peripheral && self.peripheral.state == CBPeripheralStateConnected) {
        [self.peripheral readRSSI];
    }
}

- (CGFloat)distance {
    NSInteger rssi = labs([self.RSSI integerValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    return pow(10,ci);
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (self.distance > [DeviceManager sharedInstance].alarmDistance) {
        [DeviceManager alert:self.peripheral];
    }
}

@end
