/**
 * @file
 * @author 单宝华
 * @date 2013-09-23
 * @copyright 大连一丁芯智能技术有限公司
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @class DocumentManager
 * @brief 文档管理类
 * @author 单宝华
 * @date 2013-09-23
 */
@interface DocumentManager : NSObject

/// @brief 产生唯一标识
+ (NSString *)uuid;

/// @brief 将图片存储到本地，返回存储成功/失败
+ (BOOL)setPhotoToPath:(UIImage *)image isName:(NSString *)name;

/// @brief 将图片存储到本地，返回存储的文件名
+ (NSString *)setPhoto:(UIImage *)image;

/// @brief 获取本地图片
+ (UIImage *)getPhotoFromName:(NSString *)name;

/// @brief 将录音存储到本地，返回存储成功/失败
+ (BOOL)setRecordToPath:(NSData *)data isName:(NSString *)name;

/// @brief 将录音存储到本地，返回存储的文件名
+ (NSString *)setRecord:(NSData *)data;

/// @brief 获取本地录音
+ (NSData *)getRecordFromName:(NSString *)name;

/// @brief 删除本地文件
+ (BOOL)deleteFromName:(NSString *)name;

/// @brief 返回正向的图片
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/// @brief 压缩图片
+ (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size;

@end
