#import "MainViewController.h"
#import "MainMenuViewController.h"
#import "LocationViewController.h"
#import "RadarViewController.h"
#import "SettingViewController.h"
#import "RecorderViewController.h"
#import <DocumentManager/DocumentManager.h>

@interface MainViewController () <UITabBarControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UITabBarItem *mainMenuTab;

@property (strong, nonatomic) UITabBarItem *radarTab;

@property (strong, nonatomic) UITabBarItem *locationTab;

@property (strong, nonatomic) UITabBarItem *settingTab;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"主菜单"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.mainMenuTab = [[UITabBarItem alloc] initWithTitle:@"主菜单" image:[UIImage imageNamed:@"mainMenuTab_normal"] selectedImage:[UIImage imageNamed:@"mainMenuTab_selected"]];
    UIViewController *mainMenu = [MainMenuViewController buildViewController];
    [mainMenu setTabBarItem:self.mainMenuTab];
    UINavigationController *mainNavigation = [[UINavigationController alloc] initWithRootViewController:mainMenu];
    
    self.radarTab = [[UITabBarItem alloc] initWithTitle:@"雷达" image:[UIImage imageNamed:@"radarTab_normal"] selectedImage:[UIImage imageNamed:@"radarTab_selected"]];
    UIViewController *radar = [RadarViewController buildViewController];
    [radar setTabBarItem:self.radarTab];
    UINavigationController *radarNavigation = [[UINavigationController alloc] initWithRootViewController:radar];
    
    self.locationTab = [[UITabBarItem alloc] initWithTitle:@"定位" image:[UIImage imageNamed:@"locationTab_normal"] selectedImage:[UIImage imageNamed:@"locationTab_selected"]];
    UIViewController *location = [LocationViewController buildViewController];
    [location setTabBarItem:self.locationTab];
    UINavigationController *locationNavigation = [[UINavigationController alloc] initWithRootViewController:location];
    
    self.settingTab = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"settingTab_normal"] selectedImage:[UIImage imageNamed:@"settingTab_selected"]];
    UIViewController *setting = [SettingViewController buildViewController];
    [setting setTabBarItem:self.settingTab];
    UINavigationController *settingNavigation = [[UINavigationController alloc] initWithRootViewController:setting];
    
    [self setViewControllers:[NSArray arrayWithObjects:mainNavigation, radarNavigation, locationNavigation, settingNavigation, nil]];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(camera:)];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothObject:) name:BluetoothObject object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radarObject:) name:RadarObject object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localtionObject:) name:LocaltionObject object:nil];
}

- (void)bluetoothObject:(NSNotification *)notification {
    self.selectedIndex = 0;
    [self tabBar:self.tabBar didSelectItem:self.mainMenuTab];
}

- (void)radarObject:(NSNotification *)notification {
    self.selectedIndex = 1;
    [self tabBar:self.tabBar didSelectItem:self.radarTab];
}

- (void)localtionObject:(NSNotification *)notification {
    self.selectedIndex = 2;
    [self tabBar:self.tabBar didSelectItem:self.locationTab];
}

- (void)camera:(id)sender {
    [[CoordinatingController sharedInstance] pushViewControllerWithClass:[RecorderViewController class] animated:YES];
}

- (void)add:(id)sender {
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item isEqual:self.mainMenuTab]) {
        [self setTitle:@"主菜单"];
    } else if ([item isEqual:self.radarTab]) {
        [self setTitle:@"雷达"];
    } else if ([item isEqual:self.locationTab]) {
        [self setTitle:@"定位"];
    } else if ([item isEqual:self.settingTab]) {
        [self setTitle:@"设置"];
    }
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    MainViewController *mainViewController = [[MainViewController alloc] init];
    return mainViewController;
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
