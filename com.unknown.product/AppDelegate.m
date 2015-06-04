#import "AppDelegate.h"
#import "MainViewController.h"
#import "DeviceManager.h"
#import <CoordinatingController/CoordinatingController.h>

#import <LELocation/LELocationManager.h>
#import <LELocation/LELocationManagerDelegate.h>


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[CoordinatingController sharedInstance] rootViewController];
    [self.window makeKeyAndVisible];
    
    [DeviceManager sharedInstance];
    [self appearance];
    [[CoordinatingController sharedInstance] pushViewControllerWithClass:[MainViewController class] animated:NO];
    
    return YES;
}

- (void)appearance {
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:71 / 255.0 green:149 / 255.0 blue:201 / 255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName:[UIFont systemFontOfSize:18.0]}];
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:71 / 255.0 green:149 / 255.0 blue:201 / 255.0 alpha:1]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:115 / 255.0 green:221 / 255.0 blue:248 / 255.0 alpha:1]];
//    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:146 / 255.0 alpha:1],
                                                        NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]}
                                             forState: UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:115 / 255.0 green:221 / 255.0 blue:248 / 255.0 alpha:1],
                                                        NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]}
                                             forState: UIControlStateSelected];
}

@end
