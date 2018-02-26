//
//  SBStatusNotifcation.h
//  SBRecorder
//
//  Created by qyb on 2017/10/16.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBStatusBarNotification : UIView
+ (SBStatusBarNotification*)showWithStatus:(NSString *)status
                              dismissAfter:(NSTimeInterval)timeInterval;
@end
