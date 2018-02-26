//
//  SBRecordRootController+Gestures.m
//  SBRecorder
//
//  Created by qyb on 2017/10/18.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <objc/runtime.h>
#import "SBRecordRootController+Gestures.h"
#import "SBRecorderHeader.h"

@interface SBHandleBlock :NSObject
@property (strong,nonatomic) dispatch_block_t block;
@property (assign,nonatomic) BOOL cancle;
@end
@implementation SBHandleBlock
+ (SBHandleBlock *)block:(dispatch_block_t)block{
    SBHandleBlock *blockObj = [SBHandleBlock new];
    blockObj.block = block;
    return blockObj;
}
@end
static CGPoint exPoint;
static SBHandleBlock *shouldHandleBlock;
static BOOL exping = NO;
@implementation SBRecordRootController (Gestures)
#pragma mark - 
- (void)setFocusLayer:(CALayer *)focusLayer{
    objc_setAssociatedObject(self, @selector(focusLayer), focusLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CALayer *)focusLayer{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setExposurePoint:(CGPoint)exposurePoint{
    objc_setAssociatedObject(self, @selector(exposurePoint), [NSValue valueWithCGPoint:exposurePoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGPoint)exposurePoint{
    return [objc_getAssociatedObject(self, @selector(exposurePoint)) CGPointValue];
}
- (void)setExposureLayer:(SBExposureControlLayer *)exposureLayer{
    objc_setAssociatedObject(self, @selector(exposureLayer), exposureLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SBExposureControlLayer *)exposureLayer{
    return objc_getAssociatedObject(self, @selector(exposureLayer));
}
- (void)setExposurePan:(UIPanGestureRecognizer *)exposurePan{
    objc_setAssociatedObject(self, @selector(exposurePan), exposurePan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIPanGestureRecognizer *)exposurePan{
    return objc_getAssociatedObject(self, @selector(exposurePan));
}
- (void)setFocusTap:(UITapGestureRecognizer *)focusTap{
    objc_setAssociatedObject(self, @selector(focusTap), focusTap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UITapGestureRecognizer *)focusTap{
    return objc_getAssociatedObject(self, @selector(focusTap));
}
- (void)setPinch:(UIPinchGestureRecognizer *)pinch{
    objc_setAssociatedObject(self, @selector(pinch), pinch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIPinchGestureRecognizer *)pinch{
    return objc_getAssociatedObject(self, @selector(pinch));
}
- (void)setFocalLengthScale:(CGFloat)focalLengthScale{
    objc_setAssociatedObject(self, @selector(focalLengthScale), @(focalLengthScale), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)focalLengthScale{
    return [objc_getAssociatedObject(self, @selector(focalLengthScale)) doubleValue];
}
- (void)setupLayer{
    self.recordView.userInteractionEnabled = YES;
    self.focusLayer = [[CALayer alloc] init];
    self.focusLayer.frame = CGRectMake(0, 0, 70, 70);
    self.focusLayer.hidden = YES;
    self.focusLayer.contents = (id)([UIImage imageNamed:@"SBRecorder.bundle/record_focus"].CGImage);
    [self.recordView.layer addSublayer:self.focusLayer];
    self.focalLengthScale = 1.f;
    self.exposureLayer = [[SBExposureControlLayer alloc] initWithFrame:CGRectMake(0, 0, 16, 120)];
    self.exposureLayer.hidden = YES;
    [self.recordView  addSubview:self.exposureLayer];
//    self.exposureLayer.hidden = YES;
}
- (void)setupGestures{
    [self setupLayer];
    //焦距捏合
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.recordView addGestureRecognizer:pinch];
    //聚焦单击
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.numberOfTapsRequired = 1;
    [self.recordView addGestureRecognizer:tap];
    //曝光拖动
    UIPanGestureRecognizer *exposurePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(exposurePanAction:)];
    exposurePan.enabled = NO;
    [self.recordView addGestureRecognizer:exposurePan];
    self.exposurePan = exposurePan;
}
#pragma mark - public
- (void)restoreDefaults{
    NSError *error;
    if ([self.videoCamera.inputCamera lockForConfiguration:&error]) {
        [self.videoCamera.inputCamera setVideoZoomFactor:1];
        if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [self.videoCamera.inputCamera setExposureTargetBias:0.f completionHandler:nil];
        }
        [self.videoCamera.inputCamera unlockForConfiguration];
    }
    
}
- (void)setFocalLength:(float)focalLength complete:(void(^)(BOOL success,NSError *error))complete{
    NSError *error;
    if([self.videoCamera.inputCamera lockForConfiguration:&error]){
        [self.videoCamera.inputCamera setVideoZoomFactor:focalLength];
        [self.videoCamera.inputCamera unlockForConfiguration];
        if (error) {
            if (complete) {
                complete(NO,nil);
            }
        }else {
            if (complete) {
                complete(YES,nil);
            }
        }
    }else {
        if (complete) {
            complete(NO,nil);
        }
    }
}
- (float)focalLength{
    return self.videoCamera.inputCamera.videoZoomFactor;
}
- (void)setFocus:(CGPoint)point complete:(void(^)(BOOL success,NSError *error))complete{
    if([self.videoCamera.inputCamera isExposurePointOfInterestSupported] && [self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        NSError *error;
        if ([self.videoCamera.inputCamera lockForConfiguration:&error]) {
            [self.videoCamera.inputCamera setExposurePointOfInterest:point];
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            if ([self.videoCamera.inputCamera isFocusPointOfInterestSupported] && [self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [self.videoCamera.inputCamera setFocusPointOfInterest:point];
                [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
                if (complete) {
                    complete(YES,nil);
                }
            }else {
                if (complete) {
                    complete(NO,nil);
                }
            }
            [self.videoCamera.inputCamera unlockForConfiguration];
            
        } else {
            if (complete) {
                complete(NO,error);
            }
        }
    }else {
        if (complete) {
            complete(NO,nil);
        }
    }
}
- (CGPoint)currentFocusPoint{
    return self.videoCamera.inputCamera.focusPointOfInterest;
}
- (void)setExposureValue:(float)value{
    if (value > self.videoCamera.inputCamera.maxExposureTargetBias) {
        value = self.videoCamera.inputCamera.maxExposureTargetBias;
    }
    if (value < self.videoCamera.inputCamera.minExposureTargetBias) {
        value = self.videoCamera.inputCamera.minExposureTargetBias;
    }
    if([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        NSError *error;
        if ([self.videoCamera.inputCamera lockForConfiguration:&error]) {
            [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [self.videoCamera.inputCamera setExposureTargetBias:value completionHandler:nil];
            [self.videoCamera.inputCamera unlockForConfiguration];
            [self setExposureLayerValue:value];
        }
    }
}

- (float)exposureValue{
    return self.videoCamera.inputCamera.exposureTargetBias;
}

#pragma mark = private
- (void)delayPerform:(dispatch_block_t)block after:(NSTimeInterval)dTime{
    SBHandleBlock *blockObj = [SBHandleBlock block:block];
    shouldHandleBlock.cancle = YES;
    shouldHandleBlock = blockObj;
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, (dTime) * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        if (blockObj.block && !blockObj.cancle) {
            blockObj.block();
        }
    });
}
- (void)showFocusAndExposure{
    [self setExposureLayerValue:self.exposureValue];
    self.exposurePan.enabled = YES;
    self.focusLayer.hidden = NO;
    self.exposureLayer.hidden = NO;
    
}
- (void)hidenFocusAndExposure{
    if (!exping) {
        self.exposurePan.enabled = NO;
        self.focusLayer.hidden = YES;
        self.exposureLayer.hidden = YES;
    }
}
- (void)setExposureLayerValue:(float)value{
    float average = (fabs(self.videoCamera.inputCamera.minExposureTargetBias) + fabs(self.videoCamera.inputCamera.maxExposureTargetBias))/2.f;
    float total = (fabs(self.videoCamera.inputCamera.minExposureTargetBias) + fabs(self.videoCamera.inputCamera.maxExposureTargetBias));
    self.exposureLayer.value = (value+average)/total;
}
- (void)expBeginEdit{
    exping = YES;
    self.pinch.enabled = NO;
    self.focusTap.enabled = NO;
}
- (void)expFinishEdit{
    exping = NO;
    self.pinch.enabled = YES;
    self.focusTap.enabled = YES;
    [self delayPerform:^{
        [self hidenFocusAndExposure];
    } after:2.f];
}
#pragma mark - aciton
- (void)exposurePanAction:(UIPanGestureRecognizer *)pan{
    
    CGPoint point = [pan translationInView:self.recordView];
    float ratio = 35.f;
    if (pan.state == UIGestureRecognizerStateBegan) {
        exPoint = CGPointMake(point.x, point.y+self.exposureValue*ratio);
        [self expBeginEdit];
        return;
    }
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        [self expFinishEdit];
    }
    CGFloat length = point.y - exPoint.y;
    float value = -length/ratio;
    self.exposureValue = value;
}
//调整焦距方法
- (void)pinchAction:(UIPinchGestureRecognizer*)pinch {
    float scale = pinch.scale;
    scale = self.focalLengthScale * scale;
    if (scale < 1.f) {
        scale = 1.f;
    }else if (scale > 4.f){
        scale = 4.f;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    __weak typeof(self) weak = self;
    [self setFocalLength:scale complete:^(BOOL success, NSError *error) {
        if (success) {
            if (pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled) {
                weak.focalLengthScale = scale;
            }
        }else NSLog(@"%@",error);
    }];
    [CATransaction commit];
}

//对焦方法
- (void)tapAction:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:tap.view];
    [self layerAnimationWithPoint:touchPoint];
    
    if(self.videoCamera.cameraPosition == AVCaptureDevicePositionBack){
        touchPoint = CGPointMake( touchPoint.y /tap.view.bounds.size.height ,1-touchPoint.x/tap.view.bounds.size.width);
    }
    else touchPoint = CGPointMake(touchPoint.y /tap.view.bounds.size.height ,touchPoint.x/tap.view.bounds.size.width);
    __weak typeof(self) weak = self;
    [self setFocus:touchPoint complete:^(BOOL success, NSError *error) {
        if (success) {
            [weak showFocusAndExposure];
        }else{
            NSLog(@"%@",error);
        }
    }];
}

#pragma mark - animation
//对焦动画
- (void)layerAnimationWithPoint:(CGPoint)point {
    if (self.focusLayer) {
        ///聚焦点聚焦动画设置
        CALayer *focusLayer = self.focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.duration = 0.3f;
        animation.delegate = self;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
        
        [self updateExposureLayer];
    }
}
- (void)updateExposureLayer{
    CGRect rect = self.exposureLayer.frame;
    if (ScreenWidth - self.focusLayer.frame.origin.x < self.focusLayer.frame.size.width) {
        rect.origin = CGPointMake(self.focusLayer.frame.origin.x+10, self.focusLayer.frame.origin.y+10);
        self.exposureLayer.frame = rect;
    }else {
        rect.origin = CGPointMake(self.focusLayer.frame.origin.x+self.focusLayer.frame.size.width-10, self.focusLayer.frame.origin.y+10);
        self.exposureLayer.frame = rect;
    }
    self.exposureLayer.frame = rect;
}
#pragma mark -
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self delayPerform:^{
        [self hidenFocusAndExposure];
    } after:2.f];
}
@end
