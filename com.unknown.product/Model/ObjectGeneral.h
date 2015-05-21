/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 * @enum kObjectType
 * @brief 对象类型
 * @author 单宝华
 * @date 2015-0415
 */
typedef NS_ENUM(NSInteger, kObjectType) {
    /// @brief 自拍杆
    kObjectTypeCamera,
};

/**
 * @protocol ObjectGeneral
 * @brief 硬件对象协议
 * @author 单宝华
 * @date 2015-04-15
 */
@protocol ObjectGeneral <NSObject>

/// @brief 标题
@property (strong, nonatomic) NSString *title;

/// @brief 位置
@property (strong, nonatomic) CLLocation *coordinate2D;

/// @brief 设备类型
@property (assign, nonatomic) kObjectType objectType;

/// @brief 报警距离
@property (assign, nonatomic) CGFloat alertDistance;

@property (strong, nonatomic) NSUUID *identifier;

- (instancetype)initWithIdentifier:(NSUUID *)identifier;

@end

/**
 @synthesize title = _title;
 @synthesize coordinate2D = _coordinate2D;
 @synthesize objectType = _objectType;
 @synthesize alertDistance = _alertDistance;
 @synthesize identifier = _identifier;
 */