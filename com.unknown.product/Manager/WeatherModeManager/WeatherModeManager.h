/**
 * @file
 * @author 单宝华
 * @date 2015-06-30
 */
#import <Foundation/Foundation.h>

/**
 * @enum kWeatherMode
 * @brief 天气模式
 * @author 单宝华
 * @date 2015-06-30
 */
typedef NS_ENUM(NSInteger, kWeatherMode) {
    /// @brief 晴天模式
    kWeatherModeOvercast,
    
    /// @brief 阴天模式
    kWeatherModeWet,
    
    /// @brief 傍晚模式
    kWeatherModeDusk,
    
    /// @brief 夜晚模式
    kWeatherModeNight,
    
    /// @brief SOS闪烁模式
    kWeatherModeSOS,
};

/**
 * @class WeatherModeManager
 * @brief 天气模式管理
 * @author 单宝华
 * @date 2015-06-30
 */
@interface WeatherModeManager : NSObject

/// @brief 天气模式
@property (assign, nonatomic) kWeatherMode weatherMode;

+ (instancetype)sharedInstance;

+ (void)sendPattern;

@end
