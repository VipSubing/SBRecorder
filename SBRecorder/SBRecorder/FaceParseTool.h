//
//  FaceParseTool.h
//  SBRecorder
//
//  Created by qyb on 2018/1/31.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const kFacePointsKey;

extern NSString *const kFaceRectKey;

extern NSString *const kFaceOriginsKey;

@interface FaceParseTool : NSObject

+ (FaceParseTool *)shareFaceParse;

- (void)deallocFaceDetrctor;

- (void)parseSampleBuffer:(CMSampleBufferRef)sampleBuffer cameraPosition:(AVCaptureDevicePosition)cameraPosition callBack:(void(^)(NSArray *array))callBack;
@end
