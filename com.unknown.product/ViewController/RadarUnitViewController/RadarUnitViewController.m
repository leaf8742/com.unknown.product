#import "RadarUnitViewController.h"
#import "DeviceManager.h"
#import "LocalizationManager.h"

@interface RadarUnitViewController ()

@property (strong, nonatomic) NSArray *numbers;

@end


@implementation RadarUnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [LocalizationManager localizedStringForKey:@"Radar Unit" comment:nil];
    self.numbers = @[@0.1, @0.5, @1, @5];
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"RadarUnitViewController"];
    return result;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.numbers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RadarUnitCell" forIndexPath:indexPath];
    NSString *metre = [LocalizationManager localizedStringForKey:@"metre" comment:nil];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@%@", self.numbers[indexPath.row], metre]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([DeviceManager sharedInstance].radarUnit == [self.numbers[indexPath.row] floatValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [DeviceManager sharedInstance].radarUnit = [self.numbers[indexPath.row] floatValue];
    [self.tableView reloadData];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
