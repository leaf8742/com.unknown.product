#import "AlarmModeViewController.h"
#import "DeviceManager.h"
#import "LocalizationManager.h"

@interface AlarmModeViewController ()

@end


@implementation AlarmModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [LocalizationManager localizedStringForKey:@"Alarm Way" comment:nil];
    [self.audioEnabled setOn:[DeviceManager sharedInstance].audioEnabled];
    [self.vibrateEnabled setOn:[DeviceManager sharedInstance].vibrateEnabled];
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"AlarmModeViewController"];
    return result;
}

- (IBAction)audioEnabled:(UISwitch *)sender {
    [DeviceManager sharedInstance].audioEnabled = sender.on;
}

- (IBAction)vibrateEnabled:(UISwitch *)sender {
    [DeviceManager sharedInstance].vibrateEnabled = sender.on;
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
