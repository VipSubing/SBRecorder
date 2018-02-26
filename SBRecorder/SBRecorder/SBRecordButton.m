//
//  SBRecordButton.m
//  SBRecorder
//
//  Created by qyb on 2017/10/12.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SBRecordButton.h"
#import "SBRecorderHeader.h"
@implementation SBRecordCloseButton
- (CGRect)imageRectForContentRect:(CGRect)bounds{
    return CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
}
@end

@interface SBRecordProgress : UIView
@property (assign,nonatomic) float progress;
@property (strong,nonatomic) UIColor *progressColor;
@end
@implementation SBRecordProgress
- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    CGPoint center = CGPointMake(self.bounds.size.height/2, self.bounds.size.height/2);  //设置圆心位置
    CGFloat radius = self.bounds.size.height/2-2.9f;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 6.0f); //设置线条宽度
    [_progressColor setStroke]; //设置描边颜色
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    CGContextStrokePath(ctx);  //渲染
}
- (void)setProgress:(float)progress{
    _progress = progress;
    [self setNeedsDisplay];
}
@end

NSTimeInterval const animationDuration = 0.2f;
@implementation SBRecordButton
{
    SBRecordProgress *_progressLayer;
    UILabel *_durationLabel;
    BOOL _recording;
}
+ (instancetype)recordButtonWithDelegate:(id)delegate{
    SBRecordButton *recordbtn = [[SBRecordButton alloc] init];
    recordbtn.actionDelegate = delegate;
    return recordbtn;
}
- (instancetype)init{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake((ScreenWidth-80)/2, ScreenHeight-80-25, 80, 80);
        self.image = [SBRecordUtils makeCircularImageWithSize:self.bounds.size];
        _progressLayer = [SBRecordProgress new];
        
        _progressLayer.backgroundColor = [UIColor clearColor];
        _progressLayer.frame = self.bounds;
        [self addSubview:_progressLayer];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -25, self.bounds.size.width, 20)];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_durationLabel];
        UITapGestureRecognizer *tapResponer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        [self addGestureRecognizer:tapResponer];
        UILongPressGestureRecognizer *longResponer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longResponer.minimumPressDuration = 0.1f;
        [self addGestureRecognizer:longResponer];
    }
    return self;
}
- (void)setProgress:(float)progress{
    _progressLayer.progress = progress;
    if (progress == 1) {
        _recording = NO;
    }
}
- (void)setProgressColor:(UIColor *)progressColor{
    _progressColor = progressColor;
    _progressLayer.progressColor = _progressColor;
}
- (void)setDuration:(float)duration{
    _durationLabel.text = duration <= 0 ?@"":[NSString stringWithFormat:@"%.1fs",duration];
}
- (void)hide{
    [self shrinkageAnimation];
    [self hidenAnimation];
}
- (void)show{
    [self clearAnimation];
}
#pragma mark - action
- (void)tapPress:(UITapGestureRecognizer *)responer{
    if ([self.actionDelegate respondsToSelector:@selector(singlePressRecordButton:)]) {
        [self.actionDelegate singlePressRecordButton:self];
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)responer{
    switch (responer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _recording = YES;
            [self stretchAnimation];
            if ([self.actionDelegate respondsToSelector:@selector(beginLongPressRecordButton:)]) {
                [self.actionDelegate beginLongPressRecordButton:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _recording = NO;
            [self shrinkageAnimation];
            [self hidenAnimation];
            if ([self.actionDelegate respondsToSelector:@selector(endLongPressRecordButton:)]) {
                [self.actionDelegate endLongPressRecordButton:self];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _recording = NO;
            [self shrinkageAnimation];
            [self hidenAnimation];
            if ([self.actionDelegate respondsToSelector:@selector(cancleOrFailureLongPressRecordButton:)]) {
                [self.actionDelegate cancleOrFailureLongPressRecordButton:self];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - Animation
- (void)stretchAnimation{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = [NSNumber numberWithDouble:1.0];
    animation.toValue = [NSNumber numberWithDouble:1.2];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = animationDuration;
    animation.repeatCount = 0;  //"forever"
    [self.layer addAnimation:animation forKey:@"scale_big"];
}
- (void)shrinkageAnimation{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    animation.fromValue = [NSNumber numberWithDouble:1.2];
    animation.toValue = [NSNumber numberWithDouble:1.0];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = animationDuration;
    animation.repeatCount = 0;  //"forever"
    [self.layer addAnimation:animation forKey:@"scale_small"];
}
- (void)hidenAnimation{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = animationDuration;
    opacityAnimation.repeatCount = 0;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:opacityAnimation forKey:@"opacity"];
}
- (void)clearAnimation{
    [self.layer removeAllAnimations];
}
@end
