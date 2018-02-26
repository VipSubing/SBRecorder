//
//  SBFaceBowknotView.m
//  SBRecorder
//
//  Created by qyb on 2018/2/25.
//  Copyright © 2018年 qyb. All rights reserved.
// 蝴蝶结

#import "SBFaceBowknotView.h"
@interface SBFaceBowknotView()
@property (nonatomic,readwrite) UIImageView *faceHeadView;
@end
@implementation SBFaceBowknotView

- (UIImageView *)faceHeadView{
    if (_faceHeadView == nil) {
        _faceHeadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*1.7, 150)];
        _faceHeadView.image = [UIImage imageNamed:@"蝴蝶结"];
        [self addSubview:_faceHeadView];
    }
    return _faceHeadView;
}
- (void)drawFaceView:(NSArray *)faces{
    if (faces.count == 1) {
        @autoreleasepool{
            NSDictionary *dicPerson = faces.firstObject;
            CGRect rect = CGRectFromString([dicPerson objectForKey:kFaceRectKey]);
            CGFloat scale = rect.size.width/ScreenWidth;
            CGFloat space = 200*scale;
            NSArray * strPoints = [dicPerson objectForKey:kFacePointsKey];
            //右边鼻孔
            CGPoint strPoint1 = CGPointFromString(((NSString *)strPoints[2]));
            //左边鼻孔
            CGPoint  strPoint2 = CGPointFromString(((NSString *)strPoints[15]));
            //右边嘴角
            CGPoint  strPoint3 = CGPointFromString(((NSString *)strPoints[5]));
            //左边嘴角
            CGPoint strPoint4 = CGPointFromString(((NSString *)strPoints[20]));
            double rotation = atan((strPoint3.x+strPoint4.x -strPoint1.x - strPoint2.x)/(strPoint3.y +strPoint4.y - strPoint1.y - strPoint2.y));
            
            self.faceHeadView.center = CGPointMake(CGPointFromString(((NSString *)strPoints[6])).x, CGPointFromString(((NSString *)strPoints[6])).y+space) ;
            self.faceHeadView.transform = CGAffineTransformMakeRotation(-rotation);
            self.faceHeadView.transform = CGAffineTransformScale(self.faceHeadView.transform,scale,scale);
        }
    }
}

@end
