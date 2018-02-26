//
//  SBSimplePlayer.m
//  SBRecorder
//
//  Created by qyb on 2017/10/17.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBSimplePlayer.h"
@interface SBSimplePlayer()
@property (strong,nonatomic,readwrite) AVPlayer *player;
@property (strong,nonatomic,readwrite) AVPlayerItem *currentItem;
@end
@implementation SBSimplePlayer
{
    BOOL _firstLock;
    UIImage *_thumbnailImage;
}
+ (SBSimplePlayer *)player{
    SBSimplePlayer *player = [SBSimplePlayer new];
    
    return player;
}
- (instancetype)init{
    if (self = [super init]) {
        _loopPlay = YES;
        _firstLock = NO;
        _player = [[AVPlayer alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFaiture:) name:AVPlayerItemNewErrorLogEntryNotification object:self.player.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidBegin:) name:AVPlayerItemTimeJumpedNotification object:self.player.currentItem];
        
    }
    return self;
}
- (void)playWithUrl:(NSURL *)url layer:(UIView *)viewLayer frame:(CGRect )frame{
    [self setThumbnailImageWithLayer:(UIImageView *)viewLayer url:url];
    _firstLock = NO;
    [self removeObserver:_currentItem];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    _currentItem = item;
    [self addObserverForItem:_currentItem];
    [_player replaceCurrentItemWithPlayerItem:item];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerLayer.frame = frame;
    [viewLayer.layer addSublayer:playerLayer];
}
- (UIImage *)thumbnailImage{
    return _thumbnailImage;
}
- (void)setThumbnailImageWithLayer:(UIImageView *)layer url:(NSURL *)url{
    _thumbnailImage = [self thumbnailImageForVideo:url atTime:0.01f];
    layer.image = _thumbnailImage;
}
- (void)reset{
    [self pause];
    [_player replaceCurrentItemWithPlayerItem:_currentItem];
    [self play];
}
- (void)play{
    [_player play];
}
- (void)pause{
    [_player pause];
}
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;
}

#pragma mark - observer
- (void)playDidFinish:(NSNotification *)nf{
    if (_loopPlay) {
        [_player seekToTime:kCMTimeZero];
        [self play];
    }
    if ([self.delegate respondsToSelector:@selector(playDidFinish:)]) {
        [self.delegate didFinishedPlayWithPlayer:self];
    }
}
- (void)playDidFaiture:(NSNotification *)nf{
    if ([self.delegate respondsToSelector:@selector(playFaitureWithPlayer:)]) {
        [self.delegate playFaitureWithPlayer:self];
    }
}
- (void)playDidBegin:(NSNotification *)nf{
    if (!_firstLock) {
        _firstLock = YES;
        if ([self.delegate respondsToSelector:@selector(didBeginPlayWithPlayer:)]) {
            [self.delegate didBeginPlayWithPlayer:self];
        }
    }
}
- (void)addObserverForItem:(AVPlayerItem *)item{
    if (!item) return;
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)removeObserver:(AVPlayerItem *)item{
    if (!item) return;
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"status"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            if (_autoPlay) {
                [self.player play];
            }
        }
    }
}
- (void)dealloc{
    [self pause];
    [self removeObserver:_currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemNewErrorLogEntryNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:self.player.currentItem];
    
    _player = nil;
}
@end
