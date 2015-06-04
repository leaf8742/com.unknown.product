/**
 * @file
 * @author 单宝华
 * @date 2015-06-04
 */
#import <UIKit/UIKit.h>
#import <CoordinatingController/CoordinatingController.h>

/**
 * @class AlarmModeViewController
 * @brief 报警方式页
 * @author 单宝华
 * @date 2015-06-04
 */
@interface AlarmModeViewController : UIViewController<CoordinatingControllerDelegate>

/// @brief 启用声音
@property (weak, nonatomic) IBOutlet UISwitch *audioEnabled;

/// @brief 启用震动
@property (weak, nonatomic) IBOutlet UISwitch *vibrateEnabled;

/// @brief 启用声音
- (IBAction)audioEnabled:(UISwitch *)sender;

/// @brief 启用震动
- (IBAction)vibrateEnabled:(UISwitch *)sender;

@end
