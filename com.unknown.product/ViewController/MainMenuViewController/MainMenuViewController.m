#import "MainMenuViewController.h"
#import "UserInformation.h"
#import "ObjectGeneral.h"
#import "MainMenuCell.h"

NSString *const BluetoothObject = @"BluetoothObject";
NSString *const RadarObject = @"RadarObject";
NSString *const LocaltionObject = @"LocaltionObject";

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [[UserInformation sharedInstance] addObserver:self forKeyPath:@"objects" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    self.title = @"主菜单";
}

- (IBAction)find:(UIButton *)sender {
    id object = [[UserInformation sharedInstance] objects][sender.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:LocaltionObject object:object];
}

- (IBAction)alert:(UIButton *)sender {
    __block NSString *title = [sender titleForState:UIControlStateNormal];
    [sender setEnabled:NO];
    [sender setTitle:@"" forState:UIControlStateNormal];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake((sender.frame.size.width - indicator.frame.size.width) / 2,
                                 (sender.frame.size.height - indicator.frame.size.height) / 2,
                                 indicator.frame.size.width, indicator.frame.size.height);
    [sender addSubview:indicator];
    [indicator startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender setEnabled:YES];
        [sender setTitle:title forState:UIControlStateNormal];
        [indicator removeFromSuperview];
    });
}

- (IBAction)distance:(UIButton *)sender {
    id object = [[UserInformation sharedInstance] objects][sender.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:RadarObject object:object];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSNumber *kindValue = [change objectForKey:NSKeyValueChangeKindKey];
//    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//    id indexesValue = [change objectForKey:NSKeyValueChangeIndexesKey];
    
//    if ([kindValue isEqual:[NSNumber numberWithInteger:NSKeyValueChangeInsertion]]) {
//        
//    }
    
    if ([keyPath isEqualToString:@"objects"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"MainMenuViewController"];
    return result;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[UserInformation sharedInstance] objects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainMenuCellIdentifier" forIndexPath:indexPath];
    
    id<ObjectGeneral> object = [[UserInformation sharedInstance] objects][indexPath.row];
    cell.title.text = object.title;
    cell.currentDistance.text = @"距离手机50米";
    cell.alertDistance.text = @"距离手机100米报警";
    cell.find.tag = [indexPath row];
    cell.alert.tag = [indexPath row];
    cell.distance.tag = [indexPath row];

    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[UserInformation sharedInstance] removeObserver:self forKeyPath:@"objects"];
}

@end
