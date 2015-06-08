/**
 * @file
 * @author 单宝华
 * @date 2014/02/13
 * @copyright 大连一丁芯智能技术有限公司
 */
#import <Foundation/Foundation.h>

/// @brief 跟随系统
FOUNDATION_EXPORT NSString *const kDefaultLanguage;

/// @brief 简体中文
FOUNDATION_EXPORT NSString *const kChineseSimplifiedLanguage;

/// @brief 英文
FOUNDATION_EXPORT NSString *const kEnglishLanguage;

/**
 * @class LocalizationManager
 * @brief 本地化管理类
 * @author 单宝华
 * @date 2014/02/13
 */
@interface LocalizationManager : NSObject

/// @brief 当前语言
+ (NSString *)language;

/// @brief 设置当前语言
+ (void)setLanguage:(NSString *)language;

/// @brief 本地化语言
+ (NSString *)localizedStringForKey:(NSString *)key comment:(NSString *)comment;

@end
