#import "MainMenuCell.h"
#import "MainMenuViewController.h"
#import "DeviceManager.h"

@interface MainMenuCell()

@property (strong, nonatomic) CameraInformation *object;

@end


@implementation MainMenuCell

- (void)buildWithObject:(id<ObjectGeneral>)object {
    self.object = object;
    self.title.text = object.title;
    self.currentDistance.text = @"距离手机50米";
    self.alertDistance.text = @"距离手机100米报警";
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

@end
