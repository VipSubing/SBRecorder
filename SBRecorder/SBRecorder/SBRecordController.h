//
//  SBRecordController.h
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SBRecorderHeader.h"
@interface SBRecordController : UINavigationController
//最小录制时间  默认 2s 不能小于1s
@property (assign,nonatomic) NSTimeInterval minDuration;
//分辨率 默认 AVCaptureSessionPreset640x480
//使用某些滤镜如美颜时，过高分辨率会因为设备不同掉帧，这里自行适配 高分辨率将不能人脸识别 640 *480 为界限
@property (copy,nonatomic) NSString *videoResolution;
//最大录制时间 默认20  1 < maxduration <= 60
@property (assign,nonatomic) NSTimeInterval maxDuration;
//最大输出文件数量 默认 10  5 < count < 20
@property (assign,nonatomic) NSInteger maxOutputFilesCount;
//摄像头方向 默认 AVCaptureDevicePositionBack
@property (assign,nonatomic) AVCaptureDevicePosition cameraPosition;
//录制按钮进度颜色颜色  默认 绿色
@property (strong,nonatomic) UIColor *recordStrokeColor;
//滤镜分类 默认三种 fullview skin face
@property (nonatomic) SBRecordToolBarEnum barEnum;
@property (nonatomic) BOOL allowEnter;
+ (instancetype)recordWithDelegate:(id)delegate;
@end
