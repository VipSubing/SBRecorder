//
//  SBToolFunctionView.h
//  SBRecorder
//
//  Created by qyb on 2018/1/12.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBToolFunctionView;
@protocol SBToolFunctionViewDelegate <NSObject>
@required
- (void)functionView:(SBToolFunctionView *)view didSelectedTopicIndex:(NSInteger)topIndex modelIndex:(NSInteger)modelIndex model:(id)model;
@end
@interface SBToolFunctionView : UIView
@property (weak,nonatomic) id <SBToolFunctionViewDelegate> funcDelegate;

@property (strong,nonatomic) NSArray *datas;
@property (nonatomic) NSInteger topicIndex;
@end
