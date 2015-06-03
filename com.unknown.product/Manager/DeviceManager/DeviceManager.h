/**
 * @file
 * @author 单宝华
 * @date 2015-05-11
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

FOUNDATION_EXPORT NSString *const StopScan;
FOUNDATION_EXPORT NSString *const KeyStateService;

/**
 * @class DeviceManager
 * @brief 设备管理类
 * @author 单宝华
 * @date 2015-05-11
 */
@interface DeviceManager : NSObject

+ (instancetype)sharedInstance;

+ (void)scan;

+ (void)stopScan;

+ (void)connectPeripheral:(CBPeripheral *)peripheral;

+ (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

+ (void)alert:(CBPeripheral *)peripheral;

@end
