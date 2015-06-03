#import "RadarViewController.h"
#import "LocationManager.h"
#import "LocalizationManager.h"

@interface RadarViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) MKPlacemark *placemark;

@end


@implementation RadarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [LocalizationManager localizedStringForKey:@"Radar" comment:nil];
    self.geocoder = [[CLGeocoder alloc] init];
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"RadarViewController"];
    return result;
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if ((userLocation.coordinate.latitude != 0.0) && (userLocation.coordinate.longitude != 0.0)) {
        [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
        
        MKCoordinateRegion region = [LocationManager coordinateRegionWithCenter:userLocation.coordinate approximateRadiusInMeters:kCLLocationAccuracyHundredMeters];
        [self.mapView setRegion:region animated:YES];
    }
    
    [self.geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0)) {
            _placemark = [placemarks objectAtIndex:0];
        } else {
            // Handle the nil case if necessary.
        }
    }];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
