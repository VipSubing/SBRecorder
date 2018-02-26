//
//  SBRecordAbstract Filter.h
//  SBRecorder
//
//  Created by qyb on 2018/1/13.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import <Foundation/Foundation.h>
#import "SBRecorderHeader.h"
extern NSString *const kRecordFilterObjectIndexKey;
extern NSString *const kRecordFilterObjectParamKey;

@interface SBRecordAbstractFilter : NSObject

@property (nonatomic,readonly) NSInteger selectedIndex;

@property (nonatomic,readonly) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic,readonly) NSInteger sortCode;

- (instancetype)initWithEnum:(SBRecordFilterEnum)filterEnum withObject:(id)object;
@end
