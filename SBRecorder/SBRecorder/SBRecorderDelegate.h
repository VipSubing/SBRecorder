//
//  SBRecorderDelegate.h
//  SBRecorder
//
//  Created by qyb on 2017/10/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBRecorderDelegate <NSObject>
- (void)recordDidFinishWithFileUrl:(NSURL *)fileUrl thumbnail:(UIImage *)thumbnail duration:(NSTimeInterval)duration completed:(BOOL)completed;
@end
