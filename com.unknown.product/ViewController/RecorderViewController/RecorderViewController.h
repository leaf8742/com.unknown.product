/**
 * @file
 * @author 单宝华
 * @date 2015-04-24
 */
#import <UIKit/UIKit.h>
#import <CoordinatingController/CoordinatingController.h>
#import "VideoMenu.h"
#import "CapturePhotoMenu.h"
#import "FocusView.h"

/**
 * @class RecorderViewController
 * @brief 照相、摄像页面
 * @author 单宝华
 * @date 2015-04-24
 */
@interface RecorderViewController : UIViewController<CoordinatingControllerDelegate>

/// @brief 图像页面
@property (weak, nonatomic) IBOutlet UIControl *preview;

@property (weak, nonatomic) IBOutlet UIView *cameraToolsPanel;

/// @brief 照相按钮
@property (weak, nonatomic) IBOutlet UIButton *capturePhoto;

/// @brief 录像按钮
@property (weak, nonatomic) IBOutlet UIButton *recordVideo;

/// @brief 最右侧按钮
@property (weak, nonatomic) IBOutlet UIButton *location;

/// @brief 蓝牙按钮
@property (weak, nonatomic) IBOutlet UIButton *bluetooth;

/// @brief 照片按钮
@property (weak, nonatomic) IBOutlet UIButton *browse;

/// @brief 录像机设置菜单
@property (weak, nonatomic) IBOutlet VideoMenu *videoMenu;

/// @brief 照相机设置菜单
@property (weak, nonatomic) IBOutlet CapturePhotoMenu *capturePhotoMenu;

/// @brief 照相机宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capturePhotoWidth;

/// @brief 照相机高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capturePhotoHeight;

/// @brief 照相机居中
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capturePhotoYCenter;

/// @brief 录相机宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordVideoWidth;

/// @brief 录相机高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordVideoHeight;

/// @brief 录相机居中
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordVideoYCenter;

/// @brief 调焦页面
@property (weak, nonatomic) IBOutlet FocusView *focusView;

/// @brief 照相按钮
- (IBAction)capturePhoto:(UIButton *)sender;

/// @brief 录像按钮
- (IBAction)recordVideo:(UIButton *)sender;

/// @brief 定位
- (IBAction)location:(UIButton *)sender;

/// @brief 蓝牙
- (IBAction)bluetooth:(UIButton *)sender;

/// @brief 浏览图库
- (IBAction)browse:(UIButton *)sender;

/// @brief 触摸
- (IBAction)focus:(UIControl *)sender forEvent:(UIEvent *)event;

@end
