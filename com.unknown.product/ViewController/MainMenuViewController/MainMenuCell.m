#import "MainMenuCell.h"
#import "MainMenuViewController.h"
#import "DeviceManager.h"
#import "LocalizationManager.h"

@interface MainMenuCell()

@property (strong, nonatomic) CameraInformation *object;

@end


@implementation MainMenuCell

- (void)buildWithObject:(id<ObjectGeneral>)object {
    self.object = object;
    self.title.text = object.title;
    
    [self.object addObserver:self forKeyPath:@"RSSI" options:NSKeyValueObservingOptionNew context:nil];

    self.currentDistance.text = [NSString stringWithFormat:[LocalizationManager localizedStringForKey:@"How long ... from the mobile" comment:nil], [(CameraInformation *)self.object distance]];
    self.alertDistance.text = [NSString stringWithFormat:[LocalizationManager localizedStringForKey:@"Distance for How long ... from the mobile alarm" comment:nil], [DeviceManager sharedInstance].alarmDistance];
}

- (IBAction)distance:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:RadarObject object:self.object];
}

- (IBAction)find:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:LocaltionObject object:self.object];
}

- (IBAction)alert:(UIButton *)sender {
    [DeviceManager alert:self.object.peripheral];
}

#pragma mark - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    self.currentDistance.text = [NSString stringWithFormat:[LocalizationManager localizedStringForKey:@"How long ... from the mobile" comment:nil], [(CameraInformation *)self.object distance]];
}

@end
