/**
 * @file
 * @author 单宝华
 * @date 2015-05-11
 */
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
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

+ (void)playAudio;

/// @brief 防丢距离
@property (assign, nonatomic) NSInteger alarmDistance;

/// @brief 雷达单位
@property (assign, nonatomic) CGFloat radarUnit;

/// @brief 雷达频率
@property (assign, nonatomic) CGFloat radarFrequency;

/// @brief 启用震动
@property (assign, nonatomic) BOOL vibrateEnabled;

/// @brief 启用声音
@property (assign, nonatomic) BOOL audioEnabled;

@end
