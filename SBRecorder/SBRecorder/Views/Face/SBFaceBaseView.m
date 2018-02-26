//
//  SBFaceBaseView.m
//  SBRecorder
//
//  Created by qyb on 2018/2/5.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBFaceBaseView.h"

@implementation SBFaceBaseView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        _allowFaceRectangle = YES;
    }
    return self;
}
- (void)setFaces:(NSArray *)faces{
    _faces = faces;
    if (_faces) {
        [self setNeedsDisplay];
        if (self.hidden) self.hidden = NO;
    }else{
        if (!self.hidden) self.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect{
    if (self.faces) {
        [self drawFaceView:self.faces];
    }else [super drawRect:rect];
}

- (void)drawFaceView:(NSArray *)faces{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_allowFaceRectangle) [self drawRectangle:faces context:context];
}

- (void)drawRectangle:(NSArray *)faces context:(CGContextRef)context{
//    if (faces.count == 1) {
//        for (NSDictionary *dicPerson in faces) {
//            if ([dicPerson objectForKey:kFacePointsKey]) {
//                int index = 0;
//                for (NSString *strPoints in [dicPerson objectForKey:kFacePointsKey]) {
//                    CGPoint p = CGPointFromString(strPoints) ;
////                    CGContextAddEllipseInRect(context, CGRectMake(p.x - 1 , p.y - 1 , 2 , 2));
//                    [[NSString stringWithFormat:@"%d",index] drawAtPoint:p withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:7],NSForegroundColorAttributeName:[UIColor redColor]}];
//                    index ++;
//                }
//            }
//
//            BOOL isOriRect=NO;
//            if ([dicPerson objectForKey:kFaceRectKey]) {
//                isOriRect=[[dicPerson objectForKey:kFaceRectKey] boolValue];
//            }
//
//            if ([dicPerson objectForKey:kFaceRectKey]) {
//
//                CGRect rect = CGRectFromString([dicPerson objectForKey:kFaceRectKey]);
//
//                if(isOriRect){//完整矩形
//                    CGContextAddRect(context,rect) ;
//                }
//                else{ //只画四角
//                    // 左上
//                    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height/8);
//                    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y);
//
//                    //右上
//                    CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height/8);
//
//                    //左下
//                    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height*7/8);
//                    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width/8, rect.origin.y+rect.size.height);
//
//
//                    //右下
//                    CGContextMoveToPoint(context, rect.origin.x+rect.size.width*7/8, rect.origin.y+rect.size.height);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
//                    CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height*7/8);
//                }
//            }
//        }
//        [self.tintColor set];
//        CGContextSetLineWidth(context, 2);
//        CGContextStrokePath(context);
//    }
}


@end
