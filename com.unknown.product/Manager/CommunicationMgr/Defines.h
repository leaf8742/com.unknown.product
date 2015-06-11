//
//  Defines.h
//  SkinDetect
//
//  Created by Q on 14-9-23.
//  Copyright (c) 2014年 EADING. All rights reserved.
//

#ifndef SkinDetect_Defines_h
#define SkinDetect_Defines_h

typedef NS_ENUM(NSInteger, DetectPosition) {
    DetectPositionNon = 0,
    DetectPositionEyes,
    DetectPositionHead,
    DetectPositionFace,
    DetectPositionHands,
    DetectPositionMax,
};

typedef NS_ENUM(NSInteger, DetectOccasion) {
    DetectOccasionNon = 0,
    DetectOccasionNormal,
    DetectOccasionAfterSkinCare,
    DetectOccasionAfterCleanSkin,
    DetectOccasionBeforeApplyMask,
    DetectOccasionAfterApplyMask,
    DetectOccasionPalmHandNormal,
    DetectOccasionPalmHandAfterCare,
    DetectOccasionBackHandNormal,
    DetectOccasionBackHandAfterCare,
};

typedef NS_ENUM(NSInteger, SendRequest) {
    SendRequestNon = 0,
    SendRequestConnection,
    SendRequestGetData,
    SendRequestFinishDetect,
};

typedef NS_ENUM(NSInteger, SkinStat) {
    SkinStatDry = 0,
    SkinStatGood,
    SkinStatOil
};



//#define SERVICE_URL @"http://192.168.71.125:8893/"
#define SERVICE_URL @"http://skin.eacloud.cn:8088/"

// MARK: 服务器地址
/**************URL*****************/
// 内网中文
#define HTTP_URL [NSString stringWithFormat:@"%@s", SERVICE_URL]

// 头像地址
#define PHOTO_URL [NSString stringWithFormat:@"%@file/photo", SERVICE_URL]

// 帖子图片地址
#define TOPIC_PICTURE_URL [NSString stringWithFormat:@"%@sfile/picture", SERVICE_URL]

// 帖子视频地址
#define TOPIC_VIDEO_URL [NSString stringWithFormat:@"%@sfile/video", SERVICE_URL]

// banner图片地址
#define BANNER_PICTURE_URL [NSString stringWithFormat:@"%@sfile/banner", SERVICE_URL]


// 外网中文
//#define HTTP_URL @"http://eabox.eacloud.cn/service.inf/"

#define container_of(ptr, type, member) ({ / const typeof( ((type *)0)->member ) *__mptr = (ptr); / (type *)( (char *)__mptr - offsetof(type,member) );})

// 125本地
//#define HTTP_SHARE_URL(params) [NSString stringWithFormat:@"http://192.168.71.125:8890/cefuApp.do?key=%@",params]

// 云服地址
#define HTTP_SHARE_URL(params) [NSString stringWithFormat:@"http://skin.eacloud.cn:8088/share/s/%@",params]
/**********************************/

#define App_Store_Url @""


#define IS_IPHONE5 ([UIScreen mainScreen].bounds.size.height > 480)

#define colorRGB(x,y,z,a) [UIColor colorWithRed:x/255. green:y/255. blue:z/255. alpha:a]

#define TIME_OUT 5

#define kNotificationChangePlace @"NotificationChangePlace"
#define kNotificationChangeSideMenuStat @"NotificationChangeSideMenuStat"
#define kNotificationShowLeftMenu @"NotificationShowLeftMenu"

// 设置相关Key
#define SETTINGS_SHOW_INTEGRAL_ALERT_NO_MORE @"SETTINGS_SHOW_INTEGRAL_ALERT_NO_MORE"
#define DETECTING_HAS_BEEN_USED @"DETECTING_HAS_BEEN_USED"

#endif
