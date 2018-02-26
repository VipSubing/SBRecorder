//
//  SBRecordUtils.h
//  SBRecorder
//
//  Created by qyb on 2017/10/12.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SBRecordUtils : NSObject
+ (UIImage *)makeCircularImageWithSize:(CGSize)size;

+ (UIImage *)drawSkinCareSelectImageForIndex:(NSInteger)index select:(BOOL)flag;

+ (UIImage *)drawReturnIcon:(NSString *)name;
/// Free disk space in bytes.

/**
 沙盒自由空间的大小  int64_t
 
 @return byte
 */
+ (int64_t) diskSpaceFree;

/**
 目标路径下文件

 @param directory 路径
 @return files
 */
+ (NSArray *)fileCountInDiskfolderWithDirectory:(NSString *)directory;
@end
