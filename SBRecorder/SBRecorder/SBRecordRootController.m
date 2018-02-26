//
//  SBRecordRootController.m
//  SBRecorder
//
//  Created by qyb on 2017/10/16.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <iflyMSC/IFlyFaceSDK.h>
#import "SBRecordRootController+Gestures.h"
#import "SBStatusBarNotification.h"
#import "SBRecordRootController.h"
#import "SBRecordFilterConfiguration.h"
#import "SBRecorderHeader.h"
#import "SBTopToolsBar.h"
#import "SBRecordButton.h"
#import "SBRecorderDelegate.h"
#import "SBPlayerController.h"
#import "SBWeakTimer.h"
#import "SBRecordToolBar.h"
#import "FaceParseTool.h"

NSString *const recordFileDirectory = @"sb_record";
NSTimeInterval const timerInterval = 0.01f;
@interface SBRecordRootController ()<GPUImageVideoCameraDelegate,SBRecordButtonDelegate,GPUImageMovieWriterDelegate,SBTopToolsBarDelegate,SBRecordToolBarDelegate>
@property (strong,nonatomic) SBTopToolsBar *topToolsBar;
@property (strong,nonatomic) GPUImageMovieWriter *movieWriter;
@property (strong,nonatomic) GPUImageOutput<GPUImageInput> *filter;
@property (strong,nonatomic) SBRecordButton *recordButton;
@property (nonatomic) SBRecordCloseButton *closeButton;
@property (strong,nonatomic) SBRecordToolBar *bottomToolsBar;
@property (assign,nonatomic) NSTimeInterval duration;
@property (strong,nonatomic) SBRecordFilterConfiguration *filterConfig;
@property (strong,nonatomic) FaceParseTool *faceParse;

@end

static dispatch_queue_t _autotrimQueue;

@implementation SBRecordRootController
{
    __weak id _delegate;
    NSURL *_url;
    NSTimer *_timer;
    CGSize _writerSize;
    NSTimeInterval _delayPush;
}
+ (void)initialize{
    const char *queueLabel = "com.sb.record.trimFiles";
    _autotrimQueue = dispatch_queue_create(queueLabel, NULL);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.25 alpha:0.5];
    self.navigationController.navigationBarHidden = YES;
    self.faceParse = [FaceParseTool shareFaceParse];
    [self initializeUI];
    [self configurationRecorder];
    [self addObserver];
    [self setupGestures];
}

- (instancetype)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _delayPush = 0.0f;
    }
    return self;
}
- (void)initializeUI{
    //close
    _closeButton = [[SBRecordCloseButton alloc] initWithFrame:CGRectMake(20, 20, 44, 44)];
    _closeButton.contentMode = UIViewContentModeScaleToFill;
    [_closeButton setImage:[UIImage imageNamed:@"SBRecorder.bundle/cancel"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    //top tools bar
    _topToolsBar = [SBTopToolsBar topToolsBar];
    _topToolsBar.toolDelegate = self;
    _topToolsBar.datas = [self toolModels];
    [self.view addSubview:_topToolsBar];
    [_topToolsBar reloadData];
    
    //bottom tools bar
    _bottomToolsBar = [SBRecordToolBar toolBarWithDelegate:self];
    _bottomToolsBar.barEnum = self.barEnum;
    [self.view addSubview:_bottomToolsBar];
    //record button
    _recordButton = [SBRecordButton recordButtonWithDelegate:self];
    _recordButton.progressColor = _recordStrokeColor;
    [self.view addSubview:_recordButton];
}
- (NSArray *)toolModels{
    SBRecordToolBarModel *flash = [SBRecordToolBarModel new];
    flash.onUrl = @"SBRecorder.bundle/camera_flash_on";
    flash.offUrl = @"SBRecorder.bundle/camera_flash_close";
    flash.selectUrl = flash.offUrl;
    flash.selected = NO;
    flash.index = 0;
    SBRecordToolBarModel *camera = [SBRecordToolBarModel new];
    camera.onUrl = @"SBRecorder.bundle/camera_id";
    camera.offUrl = @"SBRecorder.bundle/camera_id";
    camera.selectUrl = camera.offUrl;
    camera.selected = NO;
    camera.index = 1;
    return @[flash,camera];
}
- (void)setupVideoCamera{
    //camera
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_videoResolution cameraPosition:_cameraPosition];
    _videoCamera.delegate = self;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
}
- (void)configurationRecorder{
    
    [self setupVideoCamera];
    //over
    _recordView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    _recordView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:_recordView atIndex:0];
    
    _filterConfig = [SBRecordFilterConfiguration filterConfig];
    [_filterConfig setPerviousTarget:_videoCamera];
    [_filterConfig setNextTarget:_recordView];
    [_filterConfig setSuperView:self.view];
    [_filterConfig bridgeConnection];
    
    [_videoCamera startCameraCapture];
}
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self _autoTrim];
    [self _restoreStatus];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self _pauseStatus];
}
- (void)appDidEnterBackground{
    [self pausePicture];
}
- (void)appDidBecomeActive{
    [self remusePicture];
    [self restoreDefaults];
}
#pragma mark - status
- (BOOL)prefersStatusBarHidden
{
    return YES;// 返回YES表示隐藏，返回NO表示显示
}
+ (CGSize)_writerSizeWithVideoPreset:(NSString *)preset{
    NSString *flag = @"x";
    NSString *codes = [preset substringFromIndex:[self _avPrefix]];
    if ([codes rangeOfString:flag].location == NSNotFound) return CGSizeMake(720, 1280);
    NSArray *codess = [codes componentsSeparatedByString:flag];
    return CGSizeMake([[codess lastObject] integerValue], [[codess firstObject] integerValue]);
}
+ (NSInteger)_avPrefix{
    NSString *avPrefix = @"AVCaptureSessionPreset1280x720";
    for (int i = 0; i < AVCaptureSessionPreset1280x720.length; i ++) {
        char c1 = [AVCaptureSessionPreset1280x720 characterAtIndex:i];
        char c2 = [AVCaptureSessionPreset640x480 characterAtIndex:i];
        if (c1 != c2) {
            avPrefix = [AVCaptureSessionPreset1280x720 substringToIndex:i];
            break;
        }
    }
    return avPrefix.length;
}

- (void)_autoTrim{
    dispatch_async(_autotrimQueue, ^{
        [self _trim];
    });
}
- (void)_trim{
    NSArray *files = [SBRecordUtils fileCountInDiskfolderWithDirectory:[self _fileDirectory]];
    if (!files.count) return;
    if ([SBRecordUtils diskSpaceFree] < 1024*1024*20 || files.count > _maxOutputFilesCount) {
        NSString *fileName = [[self _fileDirectory] stringByAppendingPathComponent:[self _timeCodingMinWithFiles:files]];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        [self _trim];
    }
}
- (NSString *)_timeCodingMinWithFiles:(NSArray *)files{
    NSString *name = nil;
    NSInteger minCode = 0;
    for (int i = 0; i < files.count; i ++) {
       
        NSString *fileName = files[i];
        NSInteger code = [[[fileName componentsSeparatedByString:@"."] firstObject] longLongValue];
        if (i == 0) minCode = code;
        if (code < minCode){
            minCode = code;
            name = fileName.copy;
        }
    }
    return name;
}
- (NSString *)_fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self _fileDirectory]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self _fileDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *fileName = [NSString stringWithFormat:@"%ld.m4v",time(NULL)];
    return [[self _fileDirectory] stringByAppendingPathComponent:fileName];
}
- (NSString *)_fileDirectory{
    NSString *file = [NSString stringWithFormat:@"Documents/%@",recordFileDirectory];
    return [NSHomeDirectory() stringByAppendingPathComponent:file];
}
- (void)_pauseStatus{
    [self pausePicture];
}
- (void)_restoreStatus{
    _duration = 0.f;
    [_recordButton show];
    _recordButton.progress = 0.f;
    _recordButton.duration = 0.f;
    [self _removeTimer];
    [_videoCamera resumeCameraCapture];
}
- (void)_setRecordProgress:(float)progress{
    _recordButton.progress = progress;
}
- (void)_setRecordDuration:(float)duration{
    _recordButton.duration = duration;
}
- (void)_setupTimer{
    _timer = [SBWeakTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(_recordRepeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    _duration = 0.f;
}
- (void)_recordRepeat{
    _duration += timerInterval;
    BOOL autoFinish = NO;
    if (_duration > _maxDuration) {
        _duration = _maxDuration;
        autoFinish = YES;
    }
    float progress = _duration/_maxDuration;
    [self _setRecordProgress:progress];
    [self _setRecordDuration:_duration];
    if (autoFinish) {
        _delayPush = 0.5f;
        [self stopRecord];
    }
}
- (void)_removeTimer{
    [_timer invalidate];
    _timer = nil;
}
- (void)_remuseTimer{
    [_timer setFireDate:[NSDate distantPast]];
}
- (void)_pauseTimer{
    [_timer setFireDate:[NSDate distantFuture]];
}
#pragma  mark - action
- (void)close:(id)sender{
    [_videoCamera stopCameraCapture];
    [_movieWriter cancelRecording];
    [self _removeTimer];
    if ([_delegate respondsToSelector:@selector(recordDidFinishWithFileUrl:thumbnail:duration:completed:)]) {
        [_delegate recordDidFinishWithFileUrl:nil thumbnail:nil duration:0.f completed:NO];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - public
- (void)switchCameradDirection{
    //解决切换前置摄像头因分辨率问题不能成功问题
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
        _videoCamera.captureSessionPreset = AVCaptureSessionPreset640x480;
    }
    [_videoCamera rotateCamera];
    
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionBack) {
        if ([_videoCamera.captureSession canSetSessionPreset:_videoResolution]) {
            _videoCamera.captureSessionPreset = _videoResolution;
        }
    }
    
    [_topToolsBar setFlashStatus:_videoCamera.inputCamera.position == AVCaptureDevicePositionBack?YES:NO];
}
- (void)switchFlash:(BOOL)on{
    [_videoCamera.inputCamera lockForConfiguration:nil];
    [_videoCamera.inputCamera setTorchMode:on?AVCaptureTorchModeOn:AVCaptureTorchModeOff];
    [_videoCamera.inputCamera unlockForConfiguration];
}
- (void)pausePicture{
    [_videoCamera pauseCameraCapture];
    [self pauseRecord];
}
- (void)remusePicture{
    [_videoCamera resumeCameraCapture];
    [self remuseRecord];
}
- (void)stopPicture{
    [_videoCamera stopCameraCapture];
    [self stopRecord];
}
- (void)pauseRecord{
    //录制暂停
    [_movieWriter setPaused:true];
    [self _pauseTimer];
}
- (void)remuseRecord{
    [_movieWriter setPaused:false];
    [self _remuseTimer];
}
- (void)stopRecord {
    [_filterConfig.filterGroup removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    __weak typeof(self) weak = self;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        dispatch_main_async_safa(^{
            if (weak.duration >= weak.minDuration) {
                [weak playVideo];
            }else {
                [SBStatusBarNotification showWithStatus:@"拍摄时间过短，请重新拍摄" dismissAfter:1.f];
                [weak _restoreStatus];
            }
        });
    }];
}
- (void)startRecord{
    NSString *url = [self _fileName];
    unlink([url UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:url];
    _url = movieURL.copy;
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.f, 640.f)];
    _movieWriter.delegate = self;
    _movieWriter.hasAudioTrack = YES;
    _movieWriter.encodingLiveVideo = YES;
    _videoCamera.audioEncodingTarget = _movieWriter;
    [_filterConfig.terminalFilter addTarget:_movieWriter];
    [_movieWriter startRecording];
    //初始化计时器
    [self _setupTimer];
}
- (void)playVideo{
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, (_delayPush) * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        if ((self.isViewLoaded && self.view.window)) {
            SBPlayerController *player = [[SBPlayerController alloc] initWithUrl:_url duration:_duration delegate:_delegate];
            [self.navigationController pushViewController:player animated:YES];
        }
    });
}
- (void)showOtherControl{
    [self.bottomToolsBar showTopic];
    [self.topToolsBar show];
    self.closeButton.hidden = NO;
}
- (void)hideOtherControl{
    [self.bottomToolsBar hideTopic];
    [self.topToolsBar hide];
    self.closeButton.hidden = YES;
}
#pragma mark - SBRecordButtonDelegate
- (void)beginLongPressRecordButton:(SBRecordButton *)recordButton{
    [self startRecord];
    [self hideOtherControl];
}
- (void)endLongPressRecordButton:(SBRecordButton *)recordButton{
    [self stopRecord];
    [self showOtherControl];
}
- (void)cancleOrFailureLongPressRecordButton:(SBRecordButton *)recordButton{
    [self _removeTimer];
    [self _restoreStatus];
    [self showOtherControl];
}
- (void)singlePressRecordButton:(SBRecordButton *)recordButton{
    
}
#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    [self.faceParse parseSampleBuffer:sampleBuffer cameraPosition:self.videoCamera.cameraPosition callBack:^(NSArray *array) {
        self.filterConfig.faceView.faces = array;
    }];
}
#pragma mark - GPUImageMovieWriterDelegate
- (void)movieRecordingCompleted{
    NSLog(@"record completed!");
    [self _removeTimer];
}
- (void)movieRecordingFailedWithError:(NSError*)error{
    NSLog(@"reocrd error: %@",error.userInfo);
    [self _removeTimer];
}
#pragma mark - SBTopToolsBarDelegate
- (void)toolsBarModel:(SBRecordToolBarModel *)model didSelectItemAtIndex:(NSInteger)index{
    switch (index) {
        case 0:
            [self switchFlash:model.selected];
            break;
        case 1:
            [self switchCameradDirection];
            break;
        default:
            break;
    }
}
#pragma mark - SBRecordToolBarDelegate
// SBRecordToolBar 即将展开
- (void)toolFunctionShouldExpandWithBar:(SBRecordToolBar *)bar{
    [_recordButton hide];
    _recordButton.userInteractionEnabled = NO;
}
// SBRecordToolBar 即将收起
- (void)toolFunctionShouldRetractWithBar:(SBRecordToolBar *)bar{
    [_recordButton show];
    _recordButton.userInteractionEnabled = YES;
}

- (void)toolBar:(SBRecordToolBar *)bar didSelectedTopicIndex:(NSInteger)topIndex modelIndex:(NSInteger)modelIndex model:(id)model{
    SBRecordFilterEnum Enum = 0;
    switch (topIndex) {
        case 1:
        {
            Enum = SBRecordFilterFullView;
        }
            break;
        case 0:
        {
            Enum = SBRecordFilterFacialRecognition;
        }
            break;
        case 2:
        {
            Enum = SBRecordFilterSkin;
        }
            break;
        default:
            break;
    }
    
    id object = @{kRecordFilterObjectIndexKey:@(modelIndex),kRecordFilterObjectParamKey:model};
    [_filterConfig clearSourceTarget];
    [_filterConfig filterForEnum:Enum withObject:object];
    [_filterConfig bridgeConnection];
}
#pragma mark - over write
- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
    _videoCamera.delegate = nil;
    [_videoCamera stopCameraCapture];
    _videoCamera = nil;
    _movieWriter.delegate = nil;
    [_movieWriter cancelRecording];
    _movieWriter = nil;
    [_faceParse deallocFaceDetrctor];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end

