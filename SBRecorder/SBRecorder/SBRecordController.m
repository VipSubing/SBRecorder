//
//  SBRecordController.m
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "SBRecordController.h"
#import "SBRecordRootController.h"
#import "SBRecordPerssionController.h"

dispatch_semaphore_t _lock;
static NSString *_noitce;
@interface SBRecordController ()
{
    __weak SBRecordRootController *_record;
}
@end

@implementation SBRecordController

+ (instancetype)recordWithDelegate:(id)delegate{
    if (![self cameraPermissions]) {
        SBRecordController *record = [[SBRecordController alloc] initWithNotice:@"没有相机权限,请到“设置”开启"];
        return record;
    }
    if (![self mirphonePermissions]) {
        SBRecordController *record = [[SBRecordController alloc] initWithNotice:@"没有麦克风权限,请到“设置”开启"];
        return record;
    }
    
    SBRecordController *record = [[SBRecordController alloc] initWithDelegate:delegate];
    return record;
}
- (instancetype)initWithDelegate:(id)delegate{
    SBRecordRootController *root = [[SBRecordRootController alloc] initWithDelegate:delegate];
    if (self = [super initWithRootViewController:root]) {
        _record = root;
        _minDuration = 2.f;
        _videoResolution = AVCaptureSessionPreset640x480;
        _maxDuration = 20.f;
        _maxOutputFilesCount = 10;
        _cameraPosition = AVCaptureDevicePositionBack;
        _recordStrokeColor = [UIColor colorWithRed:118/255.f green:255/255.f blue:122/255.f alpha:1.f];
        _barEnum = SBRecordToolBarEnumWithSkin|SBRecordToolBarEnumWithFullView|SBRecordToolBarEnumWithFace;
        root.minDuration = _minDuration;
        root.videoResolution = _videoResolution;
        root.maxDuration = _maxDuration;
        root.maxOutputFilesCount = _maxOutputFilesCount;
        root.cameraPosition = _cameraPosition;
        root.recordStrokeColor = _recordStrokeColor;
        root.barEnum = _barEnum;
    }
    return self;
}
- (instancetype)initWithNotice:(NSString *)notice{
    SBRecordPerssionController *perssion = [[SBRecordPerssionController alloc] init];
    perssion.notice = notice;
    self = [super initWithRootViewController:perssion];
    return self;
}
#pragma mark - 禁止屏幕旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;  //支持横向
}

//设置为允许旋转
- (BOOL) shouldAutorotate {
    return NO;
}
#pragma mark  - attributes setting
- (void)setMinDuration:(NSTimeInterval)minDuration{
    _minDuration = minDuration<1.f?1.0f:minDuration;
    _record.minDuration = _minDuration;
}
- (void)setVideoResolution:(NSString *)videoResolution{
    _videoResolution = videoResolution.copy;
    _record.videoResolution = _videoResolution;
}
- (void)setMaxDuration:(NSTimeInterval)maxDuration{
    _maxDuration = maxDuration > 1&& maxDuration <= 60 ?maxDuration:_maxDuration;
    _record.maxDuration = _maxDuration;
}
- (void)setMaxOutputFilesCount:(NSInteger)maxOutputFilesCount{
    _maxOutputFilesCount = maxOutputFilesCount > 5 && maxOutputFilesCount < 20 ? maxOutputFilesCount:_maxOutputFilesCount;
    _record.maxOutputFilesCount = _maxOutputFilesCount;
}
- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition{
    _cameraPosition = cameraPosition;
    _record.cameraPosition = _cameraPosition;
}
- (void)setRecordStrokeColor:(UIColor *)recordStrokeColor{
    _recordStrokeColor = recordStrokeColor.copy;
    _record.recordStrokeColor = _recordStrokeColor;
}
- (void)setBarEnum:(SBRecordToolBarEnum)barEnum{
    _barEnum = barEnum;
    _record.barEnum = barEnum;
}
#pragma mark - permissions
+ (BOOL)mirphonePermissions{
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    __block BOOL result = NO;
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //请求权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                result = granted;
                dispatch_semaphore_signal(lock);//+1
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            result = NO;
            dispatch_semaphore_signal(lock);//+1
            break;
        case AVAuthorizationStatusAuthorized:
            result = YES;
            dispatch_semaphore_signal(lock);//+1
            break;
        default:
            break;
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return result;
}
+ (BOOL)cameraPermissions{
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __block BOOL result = NO;
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                result = granted;
                dispatch_semaphore_signal(lock);//+1
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            result = NO;
            dispatch_semaphore_signal(lock);//+1
            break;
        case AVAuthorizationStatusAuthorized:
            result = YES;
            dispatch_semaphore_signal(lock);//+1
            break;
        default:
            break;
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return result;
}
@end
