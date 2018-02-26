//
//  SBRecordAbstract Filter.m
//  SBRecorder
//
//  Created by qyb on 2018/1/13.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBRecordAbstractFilter.h"
#import "GPUImageBeautifyFilter.h"

NSString *const kRecordFilterObjectIndexKey = @"kRecordFilterObjectIndexKey";
NSString *const kRecordFilterObjectParamKey = @"kRecordFilterObjectParamKey";

@interface SBRecordAbstractFilter ()
@property (nonatomic,readwrite) NSInteger selectedIndex;

@property (nonatomic,readwrite) GPUImageOutput<GPUImageInput> *filter;

@property (nonatomic,readwrite) NSInteger sortCode;
@end

@implementation SBRecordAbstractFilter

- (instancetype)initWithEnum:(SBRecordFilterEnum)filterEnum withObject:(id)object{
    self = [super init];
    if (self) {
        _selectedIndex = [object[kRecordFilterObjectIndexKey] integerValue];
        switch (filterEnum) {
            case SBRecordFilterSkin:
            {
                id param = object[kRecordFilterObjectParamKey];
                GPUImageBeautifyFilter *beautify = [param floatValue] <= 0.f?nil:[[GPUImageBeautifyFilter alloc] initWithDegree:[param floatValue]];
                _filter = beautify;
                _sortCode = 0;
            }
                break;
            case SBRecordFilterFullView:
            {
                id param = object[kRecordFilterObjectParamKey];
                if ([param isKindOfClass:[NSNumber class]]) {
                    _filter = nil;
                }else{
                    NSString *filterClass = [param valueForKey:@"filter"];
                    _filter = [self fullViewWithParam:filterClass];
                }
                _sortCode = 1;
            }
                break;
            case SBRecordFilterFacialRecognition:
                break;
            default:
                break;
        }
    }
    return self;
}

- (GPUImageFilter *)fullViewWithParam:(id)param{
    if ([param isEqualToString:@"GPUImageHueFilter"]) {
        GPUImageHueFilter *filter = [[GPUImageHueFilter alloc] init];
        filter.hue = 2.f;
        return filter;
    }else if ([param isEqualToString:@"GPUImageToonFilter"]){
        
        GPUImageToonFilter *filter = [[GPUImageToonFilter alloc] init];
        filter.threshold = 0.3f;
        filter.quantizationLevels = 8.f;
        
        GPUImageSaturationFilter *Saturation = [[GPUImageSaturationFilter alloc] init];
        Saturation.saturation = 2.0f;
        
        GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
        [group addFilter:filter];
        [group addFilter:Saturation];
        [filter addTarget:Saturation];
        group.initialFilters = @[filter];
        group.terminalFilter = Saturation;
        return group;
    }
    return [[NSClassFromString(param) alloc] init];;
}
@end
