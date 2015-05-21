#import "VideoMenu.h"

@interface VideoMenu() <UITableViewDataSource, UITableViewDelegate>

@end

@implementation VideoMenu

- (void)awakeFromNib {
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

@end
