/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <UIKit/UIKit.h>
#import <CoordinatingController/CoordinatingController.h>
#import "CameraInformation.h"

/**
 * @class RadarViewController
 * @brief 雷达页面
 * @author 单宝华
 * @date 2015-04-15
 */
@interface RadarViewController : UIViewController<CoordinatingControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
