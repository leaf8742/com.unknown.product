/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <Foundation/Foundation.h>
#import "ObjectGeneral.h"

/**
 * @class UserInformation
 * @brief 用户模型
 * @author 单宝华
 * @date 2015-04-15
 */
@interface UserInformation : NSObject

@property (strong, nonatomic) NSMutableArray *objects;

+ (instancetype)sharedInstance;

/// @brief 根据唯一标识查找对象
/// @return 如果对象列表中没有，返回nil
+ (id<ObjectGeneral>)objectWithIdentifier:(NSUUID *)identifier;

/// @brief 根据唯一标识和类型查找对象
/// @return 如果对象列表中没有，返回一个新建的
+ (id<ObjectGeneral>)objectWithIdentifier:(NSUUID *)identifier type:(kObjectType)type;

@end
