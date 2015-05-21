/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/**
 * @class LocationManager
 * @brief 定位管理类
 * @author 单宝华
 * @date 2015-04-15
 */
@interface LocationManager : NSObject

/// @brief 最优定位
@property (strong, nonatomic) CLLocation *bestEffortAtLocation;

+ (instancetype)sharedInstance;

+ (MKCoordinateRegion)coordinateRegionWithCenter:(CLLocationCoordinate2D)centerCoordinate approximateRadiusInMeters:(CLLocationDistance)radiusInMeters;

@end
