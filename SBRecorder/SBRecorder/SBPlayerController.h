//
//  SBPlayerController.h
//  SBRecorder
//
//  Created by qyb on 2017/10/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBPlayerController : UIViewController

- (instancetype)initWithUrl:(NSURL *)url duration:(NSTimeInterval)duration delegate:(id)delegate;
@end
