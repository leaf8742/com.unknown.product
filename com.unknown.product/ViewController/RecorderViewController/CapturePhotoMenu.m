#import "CapturePhotoMenu.h"
#import "LocalizationManager.h"
#import "WeatherModeManager.h"

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
            return 4;
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
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Exposure" comment:nil];
                cell.accessoryView = [[UISwitch alloc] init];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"shanguang"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Tracking Mobile" comment:nil];
                cell.accessoryView = [[UISwitch alloc] init];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"moshi"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Weather Mode" comment:nil];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"yintian"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Overcast" comment:nil];
//                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
//            case 1:
//                cell.imageView.image = [UIImage imageNamed:@"yinyutian"];
//                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Rain Days" comment:nil];
//                cell.accessoryType = UITableViewCellAccessoryNone;
//                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"yutian"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Wet" comment:nil];
//                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"bangwan"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Dusk" comment:nil];
//                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"yewan"];
                cell.textLabel.text = [LocalizationManager localizedStringForKey:@"Night" comment:nil];
//                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
    }
    cell.accessoryType = [[WeatherModeManager sharedInstance] weatherMode] == [indexPath row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
                [[WeatherModeManager sharedInstance] setWeatherMode:[indexPath row]];
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
}

@end
