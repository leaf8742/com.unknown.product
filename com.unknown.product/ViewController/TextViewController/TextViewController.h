//
//  TextViewController.h
//  com.unknown.product
//
//  Created by LEAF on 15/6/24.
//  Copyright (c) 2015年 LEAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoordinatingController/CoordinatingController.h>

@interface TextViewController : UIViewController<CoordinatingControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)send:(UIButton *)sender;

@end
