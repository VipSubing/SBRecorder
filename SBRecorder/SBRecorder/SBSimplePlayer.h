//
//  SBSimplePlayer.h
//  SBRecorder
//
//  Created by qyb on 2017/10/17.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class SBSimplePlayer;
@protocol SBSimplePlayerDelegate <NSObject>
- (void)didBeginPlayWithPlayer:(SBSimplePlayer *)player;
- (void)playFaitureWithPlayer:(SBSimplePlayer *)player;
- (void)didFinishedPlayWithPlayer:(SBSimplePlayer *)player;
@end

@interface SBSimplePlayer : UIView
@property (weak,nonatomic) id <SBSimplePlayerDelegate> delegate;
@property (strong,nonatomic,readonly) AVPlayer *player;
@property (strong,nonatomic,readonly) AVPlayerItem *currentItem;
@property (assign,nonatomic) BOOL autoPlay;
@property (assign,nonatomic) BOOL loopPlay; // defaults YES
+ (SBSimplePlayer *)player;
- (void)playWithUrl:(NSURL *)url layer:(UIView *)layer frame:(CGRect )frame;
- (UIImage *)thumbnailImage;
- (void)play;
- (void)pause;
- (void)reset;
@end
