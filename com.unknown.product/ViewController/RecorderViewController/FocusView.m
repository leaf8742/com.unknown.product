//
//  FocusView.m
//  com.unknown.product
//
//  Created by LEAF on 15/6/25.
//  Copyright (c) 2015年 LEAF. All rights reserved.
//

#import "FocusView.h"

@implementation FocusView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextAddRect(ctx, CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2));
    CGContextStrokePath(ctx);
}

@end
