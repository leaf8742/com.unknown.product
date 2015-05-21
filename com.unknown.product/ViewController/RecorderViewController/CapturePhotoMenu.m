#import "CapturePhotoMenu.h"

@interface CapturePhotoMenu()<UITableViewDataSource, UITableViewDelegate>

@end


@implementation CapturePhotoMenu
- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.00001f)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.00001f)];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        default:
            return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"VideoMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"baoguang"];
                cell.textLabel.text = @"曝光";
                cell.accessoryView = [[UISwitch alloc] init];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"shanguang"];
                cell.textLabel.text = @"跟随手机";
                cell.accessoryView = [[UISwitch alloc] init];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"moshi"];
                cell.textLabel.text = @"天气模式";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"yintian"];
                cell.textLabel.text = @"阴天";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"yinyutian"];
                cell.textLabel.text = @"阴雨天";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"yutian"];
                cell.textLabel.text = @"雨天";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"bangwan"];
                cell.textLabel.text = @"傍晚";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 4:
                cell.imageView.image = [UIImage imageNamed:@"yewan"];
                cell.textLabel.text = @"夜晚";
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        for (NSInteger idx = 0; idx != 5; ++idx) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:1]];
            if (idx == [indexPath row]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
//    cellForRowAtIndexPath
}

@end
