#import "MainMenuViewController.h"
#import "Model.h"
#import "MainMenuCell.h"
#import "DeviceManager.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScan:) name:StopScan object:nil];

    self.title = @"主菜单";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshViewControlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)refreshViewControlEventValueChanged:(UIRefreshControl *)sender {
    [DeviceManager scan];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DeviceManager stopScan];
    });
}

#pragma mark - NSKeyValueObserving
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

- (void)stopScan:(NSNotification *)notification {
    [self.refreshControl endRefreshing];
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
    [cell buildWithObject:object];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [[UserInformation sharedInstance] objects][indexPath.row];
    if ([[(CameraInformation *)object peripheral] state] == CBPeripheralStateDisconnected) {
        [DeviceManager connectPeripheral:[(CameraInformation *)object peripheral]];
    } else if ([[(CameraInformation *)object peripheral] state] == CBPeripheralStateConnecting ||
               [[(CameraInformation *)object peripheral] state] == CBPeripheralStateConnected) {
        [DeviceManager cancelPeripheralConnection:[(CameraInformation *)object peripheral]];
    }
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[UserInformation sharedInstance] removeObserver:self forKeyPath:@"objects"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
