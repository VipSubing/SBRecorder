//
//  SBStatusNotifcation.m
//  SBRecorder
//
//  Created by qyb on 2017/10/16.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBStatusBarNotification.h"

float const fontSize = 13.f;
NSTimeInterval const animateDuration = 0.25f;
@implementation SBStatusBarNotification
{
    UILabel *_notificationLabel;
}
+ (SBStatusBarNotification *)statusBar{
    static SBStatusBarNotification *bar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bar = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    });
    return bar;
}
+ (SBStatusBarNotification*)showWithStatus:(NSString *)status
                              dismissAfter:(NSTimeInterval)timeInterval{
    if (status == nil || ![status isKindOfClass:[NSString class]]) {
        status = @"";
    }
    float height = [status boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size.height+20;
    SBStatusBarNotification *statusBar = [SBStatusBarNotification statusBar];
    
    statusBar->_notificationLabel.text = status;
    [statusBar showWithHeight:height];
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, (timeInterval+animateDuration) * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        [statusBar dissmiss];
    });
    return statusBar;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _notificationLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _notificationLabel.numberOfLines = 0;
        _notificationLabel.textAlignment = NSTextAlignmentCenter;
        _notificationLabel.textColor = _notificationLabel.textColor;
        _notificationLabel.font = [UIFont systemFontOfSize:fontSize];
        [self addSubview:_notificationLabel];
    }
    return self;
}
- (void)layoutSubviews{
    _notificationLabel.frame = self.bounds;
}

- (void)showWithHeight:(float)height{
    self.hidden = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:animateDuration animations:^{
        CGRect rect = self.frame;
        rect.size.height = height;
        self.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)dissmiss{
    [UIView animateWithDuration:animateDuration animations:^{
        CGRect rect = self.frame;
        rect.size.height = 0;
        self.frame = rect;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
}
@end
