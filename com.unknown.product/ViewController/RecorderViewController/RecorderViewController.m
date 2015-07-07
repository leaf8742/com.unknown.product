#import "RecorderViewController.h"
#import "SCRecordSessionManager.h"
#import "MainMenuViewController.h"
#import "DeviceManager.h"
#import <SCRecorder/SCRecorder.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import <CoordinatingController/CoordinatingController.h>
#import "CommunicationMgr.h"
#import "WeatherModeManager.h"

/**
 * @enum kCameraMode
 * @brief 照相机模式
 * @author 单宝华
 * @date 2015-04-26
 */
typedef NS_ENUM(NSInteger, kCameraMode) {
    /// @brief 照相模式
    kCameraModePhoto,
    
    /// @brief 录像模式
    kCameraModeVideo,
    
    /// @brief 正在录像
    kCameraModeRecording,
};

@interface RecorderViewController ()<SCRecorderDelegate, MWPhotoBrowserDelegate>

@property (strong, nonatomic) SCRecorder *recorder;

//@property (strong, nonatomic) SCRecorderToolsView *focusView;

@property (assign, nonatomic) kCameraMode cameraMode;

@property (strong, nonatomic) NSMutableArray *groups;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) UIButton *switchCaptureDevice;

@end


@implementation RecorderViewController

- (void)library {
    if (self.assetsLibrary == nil) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    self.groups = [NSMutableArray array];
    self.assets = [NSMutableArray array];
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0) {
            [self.groups addObject:group];
        } else {
        }
        
        if (group == nil) {
            ALAssetsGroup *groupForCell = [self.groups lastObject];
            CGImageRef posterImageRef = [groupForCell posterImage];
            UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
            [self.browse setBackgroundImage:posterImage forState:UIControlStateNormal];
            
            [groupForCell enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [self.assets addObject:result];
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.preview addGestureRecognizer:singleTapGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.preview addGestureRecognizer:doubleTapGestureRecognizer];
    
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    
    self.recorder = [SCRecorder recorder];
    self.recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
//    self.recorder.maxRecordDuration = CMTimeMake(10, 1);
    self.recorder.delegate = self;
    self.recorder.autoSetVideoOrientation = YES;
    self.recorder.previewView = self.preview;
    self.recorder.initializeSessionLazily = YES;
    SCRecordSession *session = [SCRecordSession recordSession];
    session.fileType = AVFileTypeMPEG4;
    self.recorder.session = session;

    NSError *error;
    if (![self.recorder prepare:&error]) {
        NSLog(@"Prepare error: %@", error.localizedDescription);
    }
    
    self.switchCaptureDevice = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.switchCaptureDevice setBackgroundImage:[UIImage imageNamed:@"zhuanhuan"] forState:UIControlStateNormal];
    [self.switchCaptureDevice addTarget:self action:@selector(switchCaptureDevices:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.switchCaptureDevice];
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:titleButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.2 alpha:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self library];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyStateService:) name:KeyStateService object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.recorder startRunning];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.2 alpha:1]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.recorder stopRunning];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:71 / 255.0 green:149 / 255.0 blue:201 / 255.0 alpha:1]];
}

- (void)switchCaptureDevices:(UIBarButtonItem *)sender {
    [self.recorder switchCaptureDevices];
}

- (IBAction)capturePhoto:(UIButton *)sender {
    self.videoMenu.hidden = YES;
    self.capturePhotoMenu.hidden = YES;
    if ([[WeatherModeManager sharedInstance] weatherMode] == kWeatherModeWet ||
        [[WeatherModeManager sharedInstance] weatherMode] == kWeatherModeDusk) {
        [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(DelaycapturePhoto) userInfo:nil repeats:NO];
        return;
    }
    if (self.cameraMode == kCameraModePhoto) {
        [self.recorder capturePhoto:^(NSError *error, UIImage *image) {
            if (image != nil) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                [WeatherModeManager sendPattern];
                [self.browse setBackgroundImage:image forState:UIControlStateNormal];
            } else {
                NSLog(@"Failed to capture photo: %@", error.localizedDescription);
            }
        }];
    } else {
        [[CommunicationMgr sharedInstance] stopDetect];

        [UIView animateWithDuration:0.4 animations:^{
            self.capturePhotoWidth.constant = 75;
            self.capturePhotoHeight.constant = 75;
            self.capturePhotoYCenter.constant = 0;
            
            self.recordVideoWidth.constant = 40;
            self.recordVideoHeight.constant = 40;
            self.recordVideoYCenter.constant = -74;
            
            [self setPhotoModeImage];
        }];
    }
}

- (void)DelaycapturePhoto{
    if (self.cameraMode == kCameraModePhoto) {
        [self.recorder capturePhoto:^(NSError *error, UIImage *image) {
            if (image != nil) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            } else {
                NSLog(@"Failed to capture photo: %@", error.localizedDescription);
            }
            [WeatherModeManager sendPattern];
            [self.browse setBackgroundImage:image forState:UIControlStateNormal];
        }];
    } else {
        [[CommunicationMgr sharedInstance] stopDetect];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.capturePhotoWidth.constant = 75;
            self.capturePhotoHeight.constant = 75;
            self.capturePhotoYCenter.constant = 0;
            
            self.recordVideoWidth.constant = 40;
            self.recordVideoHeight.constant = 40;
            self.recordVideoYCenter.constant = -74;
            
            [self setPhotoModeImage];
        }];
    }
}


- (IBAction)recordVideo:(UIButton *)sender {
    self.videoMenu.hidden = YES;
    self.capturePhotoMenu.hidden = YES;
    if (self.cameraMode == kCameraModeVideo) {
        [self.recorder record];
        self.cameraMode = kCameraModeRecording;
        [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_large_highlighted"] forState:UIControlStateNormal];
    } else if (self.cameraMode == kCameraModeRecording) {
        [self.recorder pause];
        [[SCRecordSessionManager sharedInstance] saveRecordSession:self.recorder.session];
        self.cameraMode = kCameraModeVideo;
        [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_large_normal"] forState:UIControlStateNormal];
        [self library];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            self.capturePhotoWidth.constant = 40;
            self.capturePhotoHeight.constant = 40;
            self.capturePhotoYCenter.constant = -74;
            
            self.recordVideoWidth.constant = 75;
            self.recordVideoHeight.constant = 75;
            self.recordVideoYCenter.constant = 0;
            
            [self setVideoModeImage];
        }];
    }
}

- (IBAction)location:(UIButton *)sender {
    self.videoMenu.hidden = YES;
    self.capturePhotoMenu.hidden = YES;
    [[CoordinatingController sharedInstance] popViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:LocaltionObject object:nil];
}

- (IBAction)bluetooth:(UIButton *)sender {
    self.videoMenu.hidden = YES;
    self.capturePhotoMenu.hidden = YES;
    [[CoordinatingController sharedInstance] popViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothObject object:nil];
}

- (IBAction)browse:(UIButton *)sender {
    self.videoMenu.hidden = YES;
    self.capturePhotoMenu.hidden = YES;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = NO;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = YES;
    ALAssetsGroup *groupForCell = [self.groups lastObject];
    [browser setCurrentPhotoIndex:[groupForCell numberOfAssets] - 1];
    
    [[CoordinatingController sharedInstance].rootViewController pushViewController:browser animated:YES];
}

- (IBAction)focus:(UIControl *)sender forEvent:(UIEvent *)event {
    CGPoint point = [(UITouch *)[[event allTouches] anyObject] locationInView:self.preview];
    [self.recorder continuousFocusAtPoint:point];
    self.focusView.center = point;
    [UIView animateWithDuration:0.4 animations:^{
        self.focusView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.focusView.alpha = 0;
        }];
    }];
}

- (void)setting:(id)sender {
    if (self.cameraMode == kCameraModeVideo || self.cameraMode == kCameraModeRecording) {
        [self.capturePhotoMenu setHidden:YES];
        [self.videoMenu setHidden:!self.videoMenu.hidden];
    } else {
        [self.videoMenu setHidden:YES];
        [self.capturePhotoMenu setHidden:!self.capturePhotoMenu.hidden];
    }
}

- (void)setPhotoModeImage {
    self.cameraMode = kCameraModePhoto;
    
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_large_normal"] forState:UIControlStateNormal];
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_large_highlighted"] forState:UIControlStateHighlighted];
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_large_normal"] forState:UIControlStateSelected];
    
    [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_small_normal"] forState:UIControlStateNormal];
    [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_small_highlighted"] forState:UIControlStateHighlighted];
    [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_small_normal"] forState:UIControlStateSelected];
}

- (void)setVideoModeImage {
    self.cameraMode = kCameraModeVideo;
    
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_small_normal"] forState:UIControlStateNormal];
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_small_highlighted"] forState:UIControlStateHighlighted];
    [self.capturePhoto setBackgroundImage:[UIImage imageNamed:@"capturePhoto_small_normal"] forState:UIControlStateSelected];
    
    [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_large_normal"] forState:UIControlStateNormal];
    [self.recordVideo setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.recordVideo setBackgroundImage:[UIImage imageNamed:@"recordVideo_large_normal"] forState:UIControlStateSelected];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
//        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
//        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.cameraMode == kCameraModeRecording) {
        [self recordVideo:nil];
    }
}

- (void)keyStateService:(NSNotification *)notification {
    if ([[[CoordinatingController sharedInstance] rootViewController].topViewController isEqual:self]) {
        switch (self.cameraMode) {
            case kCameraModePhoto:
                [self capturePhoto:nil];
                break;
            default:
                [self recordVideo:nil];
        }
    }
}

- (void)singleTap:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.preview];
    [self.recorder continuousFocusAtPoint:point];
    self.focusView.center = point;
    [UIView animateWithDuration:0.4 animations:^{
        self.focusView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.focusView.alpha = 0;
        }];
    }];
}

- (void)doubleTap:(id)sender {
    if ([self.recorder videoZoomFactor] == 1) {
        [self.recorder setVideoZoomFactor:2];
    } else {
        [self.recorder setVideoZoomFactor:1];
    }
}

- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"%f", volume);
    [self capturePhoto:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    ALAssetsGroup *groupForCell = [self.groups lastObject];
    return [groupForCell numberOfAssets];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    __block MWPhoto *photo;;
    ALAssetsGroup *groupForCell = [self.groups lastObject];
    [groupForCell enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:index] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if  (result) {
            photo = [MWPhoto photoWithURL:result.defaultRepresentation.url];
        }
    }];
    
    return photo;
}

#pragma mark - CoordinatingControllerDelegate
+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"RecorderViewController"];
    return result;
}

#pragma mark - SCRecorderDelegate
- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
    UISaveVideoAtPathToSavedPhotosAlbum(segment.url.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
