#import "RadarFrequencyViewController.h"
#import "LocalizationManager.h"
#import "DeviceManager.h"

@interface RadarFrequencyViewController ()

@property (strong, nonatomic) NSArray *numbers;

@end


@implementation RadarFrequencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [LocalizationManager localizedStringForKey:@"Radar Frequency" comment:nil];
    
    self.numbers = @[@0.5, @1, @5, @10];
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"RadarFrequencyViewController"];
    return result;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.numbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadarFrequencyCell" forIndexPath:indexPath];
    NSString *minute = [LocalizationManager localizedStringForKey:@"Second" comment:nil];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@%@", self.numbers[indexPath.row], minute]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([DeviceManager sharedInstance].alarmDistance == [self.numbers[indexPath.row] integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [DeviceManager sharedInstance].alarmDistance = [self.numbers[indexPath.row] integerValue];
    [self.tableView reloadData];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

