//
//  GPUImageSBBlendFilter.h
//  SBRecorder
//
//  Created by qyb on 2018/2/26.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageSBBlendFilter : GPUImageTwoInputFilter
{
    GLint mixUniform;
}

// Mix ranges from 0.0 (only image 1) to 1.0 (only image 2), with 0.5 (half of either) as the normal level
@property(readwrite, nonatomic) CGFloat mix;
@end
