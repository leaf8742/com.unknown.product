//
//  BatteryView.m
//  com.unknown.product
//
//  Created by LEAF on 15/8/9.
//  Copyright (c) 2015年 LEAF. All rights reserved.
//

#import "BatteryView.h"

@implementation BatteryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 3);
    CGFloat radius = self.offset + idx * distance;
    if (radius > self.endRadius) break;
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:(beginRed + radius / self.endRadius * (endRed - beginRed)) / 255
                                                           green:(beginGreen + radius / self.endRadius * (endGreen - beginGreen)) / 255
                                                            blue:(beginBlue + radius / self.endRadius * (endBlue - beginBlue)) / 255
                                                           alpha:1] CGColor]);
    CGContextMoveToPoint(ctx, self.frame.size.width / 2 + radius, self.frame.size.height);
    CGContextAddArc(ctx, self.frame.size.width / 2, self.frame.size.height, radius, 0.0f, M_PI, YES);
    CGContextStrokePath(ctx);
}
*/

@end
