//
//  SBRecordFilterConfiguration.m
//  SBRecorder
//
//  Created by qyb on 2018/1/13.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBRecordFilterConfiguration.h"
#import "GPUImageBeautifyFilter.h"
#import "SBRecorderHeader.h"
#import "GPUImageSBBlendFilter.h"
@interface SBRecordFilterConfiguration()
@property (nonatomic,readwrite) GPUImageFilter *terminalFilter;
@property (nonatomic,readwrite) GPUImageFilterGroup *filterGroup;
@property (nonatomic) GPUImageUIElement *uiElement;
@property (nonatomic,readwrite) NSArray <SBRecordAbstractFilter*> *filters;
@property (nonatomic,readwrite) SBFaceBaseView *faceView;
@property (nonatomic) NSMutableDictionary *filterTable;
@property (nonatomic) NSMutableDictionary *filterParamTable;
@end

@implementation SBRecordFilterConfiguration
{
    __weak GPUImageVideoCamera * _previousTarget;
    __weak GPUImageView * _nextTarget;
    __weak UIView *_superview;
}
#pragma mark - public
+ (SBRecordFilterConfiguration *)filterConfig{
    SBRecordFilterConfiguration *configuration = [SBRecordFilterConfiguration new];
    return configuration;
}
- (void)setPerviousTarget:(id)previousTarget{
    _previousTarget = previousTarget;
}
- (void)setNextTarget:(id)nextTarget{
    _nextTarget = nextTarget;
}
- (void)setSuperView:(UIView *)superview{
    _superview = superview;
}
- (void)bridgeConnection{
    if (_filterGroup == nil) _filterGroup = (id)[[GPUImageFilter alloc] init];
    if (_terminalFilter == nil) _terminalFilter = (id)[self defaultTerminalFilter];
    [_previousTarget addTarget:_filterGroup];
    [_filterGroup addTarget:_terminalFilter];
    [_filterGroup addTarget:_nextTarget];
    [_uiElement addTarget:_terminalFilter];
    [_superview insertSubview:_faceView atIndex:1];
    // update face ui
    __weak typeof (self) weakSelf = self;
    [_filterGroup setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        NSLog(@"update ui");
        __strong typeof (self) strongSelf = weakSelf;
        dispatch_async([GPUImageContext sharedContextQueue], ^{
            [strongSelf.uiElement updateWithTimestamp:time];
        });
    }];
}
- (void)clearSourceTarget{
    [_previousTarget removeAllTargets];
    [_terminalFilter removeAllTargets];
    [_faceView removeFromSuperview];
//    [_filterGroup removeAllTargets];
}
#pragma mark -
- (instancetype)init{
    self = [super init];
    if (self) {
        _filterTable = [NSMutableDictionary new];
        _filterParamTable = [NSMutableDictionary new];
    }
    return self;
}
- (void)filterForEnum:(SBRecordFilterEnum)filterEnum withObject:(id)Object{
    if (filterEnum == SBRecordFilterFacialRecognition) {
        
        id param = Object[kRecordFilterObjectParamKey] ;
        if (![param isKindOfClass:[NSNumber class]]) {
            SBFaceBaseView *faceView = [self faceFactoryForParam:[param valueForKey:@"filter"]];
            faceView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);

            _faceView = faceView;
            GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:faceView];
            GPUImageAlphaBlendFilter *blend = [[GPUImageAlphaBlendFilter alloc] init];
            blend.mix = 1.0;
            _uiElement = uiElement;
            _terminalFilter = blend;
        }else{
            _terminalFilter = [self defaultTerminalFilter];
        }
    }else{
        [_filterParamTable setObject:Object forKey:@(filterEnum)];
        
        _filters = [self mergeFilter];
        
        _filterGroup = [self initialGroupWithFilters:_filters];
    }
}

- (NSArray <SBRecordAbstractFilter *> *)mergeFilter{
    NSMutableArray *sorts = [NSMutableArray new];
    for (id key in _filterParamTable) {
        id object = _filterParamTable[key];
        SBRecordAbstractFilter *filter = [[SBRecordAbstractFilter alloc] initWithEnum:(SBRecordFilterEnum)[key integerValue] withObject:object];
        if (filter.filter) {
            [sorts addObject:filter];
        }
    }
    
    return [sorts sortedArrayUsingComparator:^NSComparisonResult(  SBRecordAbstractFilter *obj1, SBRecordAbstractFilter *obj2) {
        return obj1.sortCode < obj2.sortCode;
    }];;
}
- (GPUImageFilterGroup *)initialGroupWithFilters:(NSArray <SBRecordAbstractFilter *>*)filters{
    GPUImageFilterGroup *group = [[GPUImageFilterGroup alloc] init];
    GPUImageOutput *pervious = filters.firstObject.filter;
    for (SBRecordAbstractFilter *abstractFilter in filters) {
        [group addFilter:abstractFilter.filter];
        if (pervious != abstractFilter.filter) {
            [pervious addTarget:abstractFilter.filter];
        }
    }
    if (filters.count > 0) {
        group.initialFilters = [NSArray arrayWithObject:filters.firstObject.filter];
        group.terminalFilter = filters.lastObject.filter;
    }else{
        GPUImageFilter *hold = [[GPUImageFilter alloc] init];
        [group addFilter:hold];
        group.initialFilters = [NSArray arrayWithObject:hold];
        group.terminalFilter = hold;
    }
    
    return group;
}
#pragma mark - Face
// factory
- (SBFaceBaseView *)faceFactoryForParam:(NSString *)param{
    SBFaceBaseView *faceView = [[NSClassFromString(param) alloc] init];
    return faceView;
}
- (GPUImageAddBlendFilter *)defaultTerminalFilter{
    SBFaceBaseView *face = [[SBFaceBaseView alloc] init];
    face.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    _faceView = face;
    
    GPUImageUIElement *uiElement = [[GPUImageUIElement alloc] initWithView:face];
    GPUImageAlphaBlendFilter *blend = [[GPUImageAlphaBlendFilter alloc] init];
    blend.mix = 1.0;
    _uiElement = uiElement;
    return blend;
}
@end
