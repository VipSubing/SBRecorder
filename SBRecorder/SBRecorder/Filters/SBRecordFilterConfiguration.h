//
//  SBRecordFilterConfiguration.h
//  SBRecorder
//
//  Created by qyb on 2018/1/13.
//  Copyright © 2018年 qyb. All rights reserved.
//
#import <GPUImage/GPUImage.h>
#import <Foundation/Foundation.h>
#import "SBRecordAbstractFilter.h"
#import "SBFaceBaseView.h"

@interface SBRecordFilterConfiguration : NSObject

@property (nonatomic,readonly) GPUImageFilter *terminalFilter;

@property (nonatomic,readonly) GPUImageFilterGroup *filterGroup;

@property (nonatomic,readonly) NSArray <SBRecordAbstractFilter*> *filters;

@property (nonatomic,readonly) SBFaceBaseView *faceView;

+ (SBRecordFilterConfiguration *)filterConfig;

- (void)setPerviousTarget:(id)previousTarget;

- (void)setNextTarget:(id)nextTarget;

- (void)setSuperView:(UIView *)superview;

- (void)bridgeConnection;

- (void)clearSourceTarget;

- (void)filterForEnum:(SBRecordFilterEnum)filterEnum withObject:(id)Object;
@end
