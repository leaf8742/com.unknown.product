/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <UIKit/UIKit.h>
#import <CoordinatingController/CoordinatingController.h>

FOUNDATION_EXPORT NSString *const BluetoothObject;
FOUNDATION_EXPORT NSString *const RadarObject;
FOUNDATION_EXPORT NSString *const LocaltionObject;

/**
 * @class MainMenuViewController
 * @brief 主菜单页面
 * @author 单宝华
 * @date 2015-04-15
 */
@interface MainMenuViewController : UITableViewController<CoordinatingControllerDelegate>

@end
