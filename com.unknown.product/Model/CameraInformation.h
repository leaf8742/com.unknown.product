/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <Foundation/Foundation.h>
#import "ObjectGeneral.h"

/**
 * @class CameraInformation
 * @brief 自拍杆信息
 * @author 单宝华
 * @date 2015-04-15
 */
@interface CameraInformation : NSObject<ObjectGeneral>

@property (strong, nonatomic) CBPeripheral *peripheral;

@end
