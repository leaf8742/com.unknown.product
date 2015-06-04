#import "LanguageViewController.h"
#import "LocalizationManager.h"

@interface LanguageViewController ()

@property (strong, nonatomic) NSString *localization;

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [LocalizationManager localizedStringForKey:@"Language" comment:nil];
    
    CGRect frame = self.tableView.frame;
    frame.origin.y = 64;
    frame.size.height -= 64;
    [self.tableView setFrame:frame];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LanguageViewController *result = [storyboard instantiateViewControllerWithIdentifier:@"LanguageViewController"];
    [result.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LanguageCell"];
    return result;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [LocalizationManager setLanguage:self.localization];
        abort();
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *localizations = @[kDefaultLanguage, kChineseSimplifiedLanguage, kEnglishLanguage];
    NSArray *languages = @[@"跟随系统", @"中文", @"English"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = languages[indexPath.row];
    if ([[LocalizationManager language] isEqualToString:localizations[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *localizations = @[kDefaultLanguage, kChineseSimplifiedLanguage, kEnglishLanguage];
    self.localization = localizations[indexPath.row];
    if ([[LocalizationManager language] isEqualToString:localizations[indexPath.row]]) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"设置语言之后，App将会自动重启"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
