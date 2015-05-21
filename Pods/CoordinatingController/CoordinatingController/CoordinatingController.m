#import "CoordinatingController.h"

@interface CoordinatingController()<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationController *rootViewController;

@property (retain, nonatomic) UIViewController *activeViewController;

@end


@implementation CoordinatingController

#pragma mark - Signleton Implementation
+ (instancetype)sharedInstance {
    static CoordinatingController *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [NSAllocateObject([self class], 0, NULL) init];
    });
    return sharedClient;
}

+ (id)allocWithZone:(NSZone *)zone {
    static id result;
    result = nil;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        result = [self sharedInstance];
    });
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

- (id)init {
    if (self = [super init]) {
        self.rootViewController = [[UINavigationController alloc] init];
    }
    return self;
}

#pragma mark - 场景切换
- (void)pushViewControllerWithClass:(Class<CoordinatingControllerDelegate>)class animated:(BOOL)animated {
    id viewController = [class buildViewController];
    [self.rootViewController pushViewController:viewController animated:animated];
}

- (BOOL)popToViewControllerWithClass:(Class)pushClass animated:(BOOL)animated {
    NSArray *filteredObjects = [[self.rootViewController viewControllers] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:pushClass];
    }]];
    
    if ([filteredObjects count]) {
        [self.rootViewController popToViewController:[filteredObjects firstObject] animated:YES];
        return YES;
    } else {
        return NO;
    }
}

- (void)popViewControllerWithAnimated:(BOOL)animated {
    [self.rootViewController popViewControllerAnimated:animated];
}

- (IBAction)popViewController {
    [self popViewControllerWithAnimated:YES];
}

+ (UIImagePickerController *)shootPictureWithDelegate:(id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
        picker.delegate = delegate;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        return picker;
    } else {
        return nil;
    }
}

+ (UIImagePickerController *)selectExistingPictureWithDelegate:(id <UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = delegate;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    return picker;
}

- (IBAction)backgroundTap:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [viewController.navigationItem setBackBarButtonItem:backItem];
    
    if ([viewController conformsToProtocol:@protocol(CoordinatingControllerDelegate)] && [viewController respondsToSelector:@selector(navigationBarHidden)]) {
        [self.rootViewController setNavigationBarHidden:[(id<CoordinatingControllerDelegate>)viewController navigationBarHidden] animated:YES];
    } else {
        [self.rootViewController setNavigationBarHidden:NO animated:YES];
    }
    self.activeViewController = viewController;
}

@end

