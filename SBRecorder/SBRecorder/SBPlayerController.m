//
//  SBPlayerController.m
//  SBRecorder
//
//  Created by qyb on 2017/10/13.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "SBPlayerController.h"
#import "SBRecorderHeader.h"
#import "SBRecorderDelegate.h"
#import "SBSimplePlayer.h"

@interface SBPlayerController ()<SBSimplePlayerDelegate>
@property (strong,nonatomic) UIButton *playButton;
@property (strong,nonatomic) NSURL *intputUrl;
@property (strong,nonatomic) NSURL *outputUrl;
@property (assign,nonatomic) NSTimeInterval inputDuration;
@property (weak,nonatomic) id <SBRecorderDelegate> delegate;
@property (strong,nonatomic) SBSimplePlayer *player;
@property (strong,nonatomic) UIImageView *coverView;
@end

@implementation SBPlayerController
{
    dispatch_queue_t _autotrimQueue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupPlayer];
    [self setupControl];
    [self addObserver];
}
- (instancetype)initWithUrl:(NSURL *)url duration:(NSTimeInterval)duration delegate:(id)delegate{
    if (self = [super init]) {
        _intputUrl = url.copy;
        _inputDuration = duration;
        _delegate = delegate;
    }
    return self;
}
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)setupControl{
    UIButton *cancle = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-100, ScreenHeight-70-44, 70, 70)];
    [cancle setImage:[SBRecordUtils drawReturnIcon:@"SBRecorder.bundle/return_1"] forState:UIControlStateNormal];
    cancle.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
    cancle.layer.masksToBounds = YES;
    cancle.layer.cornerRadius = 35.f;
    [cancle addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancle];
    
    UIButton *complete = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2+30, ScreenHeight-70-44, 70, 70)];
    [complete setImage:[SBRecordUtils drawReturnIcon:@"SBRecorder.bundle/sure"] forState:UIControlStateNormal];
    complete.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    complete.layer.masksToBounds = YES;
    complete.layer.cornerRadius = 35.f;
    [complete addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:complete];
}

- (void)setupPlayer{
    _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_coverView];
    _player = [SBSimplePlayer player];
    [_player playWithUrl:_intputUrl layer:_coverView frame:self.view.bounds];
    _player.delegate = self;
    _player.autoPlay = YES;
}

- (void)appDidEnterBackground{
    [_player pause];
}
- (void)appDidBecomeActive{
    [_player play];
}
#pragma mark - status
- (BOOL)prefersStatusBarHidden
{
    return YES;// 返回YES表示隐藏，返回NO表示显示
}
#pragma mark  - action
- (void)cancle:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)complete:(id)sender{
    if ([self.delegate respondsToSelector:@selector(recordDidFinishWithFileUrl:thumbnail:duration:completed:)]) {
        [self.delegate recordDidFinishWithFileUrl:_intputUrl thumbnail:[_player thumbnailImage] duration:_inputDuration completed:YES];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - SBSimplePlayerDelegate
- (void)didBeginPlayWithPlayer:(SBSimplePlayer *)player{
//    self.view.backgroundColor = [UIColor clearColor];
}
- (void)playFaitureWithPlayer:(SBSimplePlayer *)player{
    
}
- (void)didFinishedPlayWithPlayer:(SBSimplePlayer *)player{
}
#pragma mark - over write
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_player pause];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
