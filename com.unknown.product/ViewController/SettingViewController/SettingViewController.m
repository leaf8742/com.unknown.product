#import "SettingViewController.h"
#import "LocalizationManager.h"

@interface SettingViewController()

@property (strong, nonatomic) NSArray *titles;

@property (strong, nonatomic) NSArray *selectors;

@property (strong, nonatomic) NSArray *images;

@end


@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [LocalizationManager localizedStringForKey:@"Setting" comment:nil];
    
    CGRect frame = self.tableView.frame;
    frame.origin.y = 64;
    frame.size.height -= 64;
    [self.tableView setFrame:frame];
    
    self.titles = @[
                    /*[LocalizationManager localizedStringForKey:@"Radar Frequency" comment:nil],
                    [LocalizationManager localizedStringForKey:@"Radar Unit" comment:nil],*/
                    [LocalizationManager localizedStringForKey:@"Anti lost distance" comment:nil],
                                          [LocalizationManager localizedStringForKey:@"Alarm Way" comment:nil],
                                          [LocalizationManager localizedStringForKey:@"Language" comment:nil]];
    self.selectors = @[/*@"radarRate", @"radarUnit", */@"distance", @"alertMode", @"language"];
    self.images = @[/*@"radarRate", @"radarUnit", */@"distance", @"alertMode", @"language"];
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    return result;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
    [cell.textLabel setText:self.titles[indexPath.row]];
    [cell.imageView setImage:[UIImage imageNamed:self.images[indexPath.row]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SEL selector = NSSelectorFromString(self.selectors[indexPath.row]);
//    if ([self respondsToSelector:selector]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [self performSelector:selector];
//#pragma clang diagnostic pop
//    }
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
