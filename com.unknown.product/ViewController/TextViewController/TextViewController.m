//
//  TextViewController.m
//  com.unknown.product
//
//  Created by LEAF on 15/6/24.
//  Copyright (c) 2015年 LEAF. All rights reserved.
//

#import "TextViewController.h"
#import "CommunicationMgr.h"

@interface TextViewController ()

@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation TextViewController

+ (instancetype)buildViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id result = [storyboard instantiateViewControllerWithIdentifier:@"TextViewController"];
    return result;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.array = [NSMutableArray array];
    self.textView.editable = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:@"ReceiveData" object:nil];
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)receiveData:(NSNotification *)notification {
    [self.array insertObject:notification.object atIndex:0];
}

- (void)timer:(NSTimer *)sender {
    self.textView.text = [NSString stringWithFormat:@"%@", self.array];
}

- (IBAction)backgroundTap:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)send:(UIButton *)sender {
//    [[CommunicationMgr sharedInstance] sendStartDetectReq];
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
