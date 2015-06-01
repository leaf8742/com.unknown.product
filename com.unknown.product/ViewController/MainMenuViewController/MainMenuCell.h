/**
 * @file
 * @author 单宝华
 * @date 2015-04-15
 */
#import <UIKit/UIKit.h>
#import "Model.h"

/**
 * @class MainMenuCell
 * @author 单宝华
 * @date 2015-04-15
 */
@interface MainMenuCell : UITableViewCell

/// @brief 标题
@property (weak, nonatomic) IBOutlet UILabel *title;

/// @brief 与手机之间的距离
@property (weak, nonatomic) IBOutlet UILabel *currentDistance;

/// @brief 报警距离
@property (weak, nonatomic) IBOutlet UILabel *alertDistance;

/// @brief 查找
@property (weak, nonatomic) IBOutlet UIButton *find;

/// @brief 报警
@property (weak, nonatomic) IBOutlet UIButton *alert;

/// @brief 距离
@property (weak, nonatomic) IBOutlet UIButton *distance;

- (void)buildWithObject:(id<ObjectGeneral>)object;

- (IBAction)distance:(UIButton *)sender;

- (IBAction)find:(UIButton *)sender;

- (IBAction)alert:(UIButton *)sender;

@end
