//
//  SBRecordRootController.h
//  SBRecorder
//
//  Created by qyb on 2017/10/16.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "SBRecorderHeader.h"
/**
 * 聚焦状态
 */
typedef NS_ENUM(NSInteger,SBFocusTouchState){
    
    SBAutoFocusAndExpose,/**< 自动聚焦曝光状态 */
    
    SBManualFocusAndExpose,/**< 手动聚焦曝光状态 */
    
    SBPartFocusAndExpose/**< 聚焦曝光分离状态 */
};


@interface SBRecordRootController : UIViewController
@property (strong,nonatomic) GPUImageView *recordView;
@property (strong,nonatomic) GPUImageVideoCamera *videoCamera;
@property (assign,nonatomic) NSTimeInterval minDuration;
@property (copy,nonatomic) NSString *videoResolution;
@property (assign,nonatomic) NSTimeInterval maxDuration;
@property (assign,atomic) NSInteger maxOutputFilesCount;
@property (assign,nonatomic) AVCaptureDevicePosition cameraPosition;
@property (nonatomic) SBRecordToolBarEnum barEnum;
//录制按钮进度颜色颜色  默认 绿色
@property (strong,nonatomic) UIColor *recordStrokeColor;

@property (assign,nonatomic) SBFocusTouchState state;
- (instancetype)initWithDelegate:(id)delegate;
@end
