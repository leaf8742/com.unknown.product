#import "LocationManager.h"

@interface LocationManager()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end


@implementation LocationManager

- (id)init {
    if (self = [super init]) {
        self.bestEffortAtLocation = nil;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    return self;
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

+ (MKCoordinateRegion)coordinateRegionWithCenter:(CLLocationCoordinate2D)centerCoordinate approximateRadiusInMeters:(CLLocationDistance)radiusInMeters {
    double radiusInMapPoints = radiusInMeters*MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude);
    MKMapSize radiusSquared = {radiusInMapPoints,radiusInMapPoints};
    
    MKMapPoint regionOrigin = MKMapPointForCoordinate(centerCoordinate);
    MKMapRect regionRect = (MKMapRect){regionOrigin, radiusSquared}; //origin is the top-left corner
    
    regionRect = MKMapRectOffset(regionRect, -radiusInMapPoints/2, -radiusInMapPoints/2);
    
    // clamp the rect to be within the world
    regionRect = MKMapRectIntersection(regionRect, MKMapRectWorld);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(regionRect);
    return region;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        self.bestEffortAtLocation = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        NSLog(@"%@", NSLocalizedString(@"Error", @"Error"));
    }
}

@end
