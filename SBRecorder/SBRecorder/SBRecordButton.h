//
//  SBRecordButton.h
//  SBRecorder
//
//  Created by qyb on 2017/10/12.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SBRecordCloseButton:UIButton
@end
@class SBRecordButton;
@protocol  SBRecordButtonDelegate <NSObject>
- (void)singlePressRecordButton:(SBRecordButton *)recordButton;
- (void)beginLongPressRecordButton:(SBRecordButton *)recordButton;
- (void)endLongPressRecordButton:(SBRecordButton *)recordButton;
- (void)cancleOrFailureLongPressRecordButton:(SBRecordButton *)recordButton;
@end

@interface SBRecordButton : UIImageView
+ (instancetype)recordButtonWithDelegate:(id)delegate;
@property (strong,nonatomic) UIColor *progressColor;
@property (weak,nonatomic) id <SBRecordButtonDelegate> actionDelegate;
//进度 0-1
@property (assign,nonatomic) float progress;
@property (assign,nonatomic) float duration;

- (void)hide;

- (void)show;

@end
