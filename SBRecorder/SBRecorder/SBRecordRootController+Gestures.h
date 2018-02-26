//
//  SBRecordRootController+Gestures.h
//  SBRecorder
//
//  Created by qyb on 2017/10/18.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBRecordRootController.h"
#import "SBExposureControlLayer.h"
@interface SBRecordRootController (Gestures)<CAAnimationDelegate>
@property (strong,nonatomic) CALayer *focusLayer;
@property (strong,nonatomic) SBExposureControlLayer *exposureLayer;
@property (nonatomic, assign) CGFloat focalLengthScale;//开始的缩放比例
@property (strong,nonatomic) UIPanGestureRecognizer *exposurePan;
@property (strong,nonatomic) UIPinchGestureRecognizer *pinch;
@property (strong,nonatomic) UITapGestureRecognizer *focusTap;
@property (assign,nonatomic) CGPoint exposurePoint;
@property (assign,nonatomic) float exposureValue;
- (void)setupGestures;
- (void)setFocalLength:(float)focalLength complete:(void(^)(BOOL success,NSError *error))complete;
- (float)focalLength;
- (void)setFocus:(CGPoint)point complete:(void(^)(BOOL success,NSError *error))complete;
- (CGPoint)currentFocusPoint;
- (void)restoreDefaults;
@end
