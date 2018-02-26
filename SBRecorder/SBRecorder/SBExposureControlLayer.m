//
//  SBExposureControlLayer.m
//  SBRecorder
//
//  Created by qyb on 2017/10/19.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SBExposureControlLayer.h"
static float scale = 0.7;
@implementation SBExposureControlLayer
{
    UIImageView *_up_icon;
    UIImageView *_down_icon;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _up_icon = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width*(1-scale)/2.f, 0, frame.size.width*scale, frame.size.width*scale)];
        _up_icon.image = [UIImage imageNamed:@"SBRecorder.bundle/record_light_up"];
        [self addSubview:_up_icon];
        
        _down_icon = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width*(1-scale)/2.f, frame.size.height-frame.size.width*scale, frame.size.width*scale, frame.size.width*scale)];
        _down_icon.image = [UIImage imageNamed:@"SBRecorder.bundle/record_light_down"];
        [self addSubview:_down_icon];
    }
    return self;
}
- (void)setValue:(float)value{
    _value = value;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();//获取上下文
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat sun_height = width*1.5;
    CGPoint up_point_fm = CGPointMake(width/2.f, width);
    CGFloat allLength = height-2*width-sun_height;
    CGFloat up_length = allLength*(1-_value);
    CGPoint up_point_to = CGPointMake(up_point_fm.x, up_length+up_point_fm.y);
    if (up_length > 0.f) {
        [self drawLineFromPoint:up_point_fm toPoint:up_point_to inContext:context];
    }
    UIImage *sun = [UIImage imageNamed:@"SBRecorder.bundle/record_light_sun"];
    CGRect sun_rect = CGRectMake(0, up_point_to.y+sun_height/6.f, width, width);
    [sun drawInRect:sun_rect];
    
    CGFloat down_length = allLength*_value;
    if (down_length > 0.f) {
        CGPoint down_point_fm = CGPointMake(up_point_fm.x, up_point_to.y+sun_height);
        CGPoint down_point_to = CGPointMake(down_point_fm.x, down_point_fm.y+down_length);
        [self drawLineFromPoint:down_point_fm toPoint:down_point_to inContext:context];
    }
}
- (void)drawLineFromPoint:(CGPoint)fPoint toPoint:(CGPoint)tPoint inContext:(CGContextRef)context{
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, fPoint.x, fPoint.y);
    CGContextAddLineToPoint(context, tPoint.x, tPoint.y);
    CGContextStrokePath(context);
}
@end
