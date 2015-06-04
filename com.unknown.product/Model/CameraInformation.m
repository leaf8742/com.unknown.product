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
        self.timer = [NSTimer timerWithTimeInterval:[DeviceManager sharedInstance].radarFrequency target:self selector:@selector(readBLEServiceRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [[DeviceManager sharedInstance] addObserver:self forKeyPath:@"radarFrequency" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)readBLEServiceRSSI {
    if (self.peripheral && self.peripheral.state == CBPeripheralStateConnected) {
        [self.peripheral readRSSI];
    }
}

- (CGFloat)distance {
    NSInteger rssi = labs([self.RSSI integerValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    CGFloat result = pow(10, ci);
    return floor(result / [DeviceManager sharedInstance].radarUnit) * [DeviceManager sharedInstance].radarUnit;
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([keyPath isEqualToString:@"radarFrequency"]) {
        [self.timer invalidate];
        self.timer = [NSTimer timerWithTimeInterval:[DeviceManager sharedInstance].radarFrequency target:self selector:@selector(readBLEServiceRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    } else {
        if (self.distance > [DeviceManager sharedInstance].alarmDistance) {
            [DeviceManager playAudio];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"RSSI"];
    [[DeviceManager sharedInstance] removeObserver:self forKeyPath:@"radarFrequency"];
}

@end
