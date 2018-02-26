//
//  SBRecordToolBar.h
//  SBRecorder
//
//  Created by qyb on 2017/10/21.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBRecordTopicView.h"
#import "SBRecorderHeader.h"
@class SBRecordToolBar;
@protocol SBRecordToolBarDelegate <NSObject>
// SBRecordToolBar 即将展开
- (void)toolFunctionShouldExpandWithBar:(SBRecordToolBar *)bar;
// SBRecordToolBar 即将收起
- (void)toolFunctionShouldRetractWithBar:(SBRecordToolBar *)bar;
// SBRecordToolBar下部视图 即将出现
- (void)toolBarShouldAppearWithBar:(SBRecordToolBar *)bar;
// SBRecordToolBar下部视图 即将消失
- (void)toolBarShouldDisappearWithBar:(SBRecordToolBar *)bar;

- (void)toolBar:(SBRecordToolBar *)bar didSelectedTopicIndex:(NSInteger)topIndex modelIndex:(NSInteger)modelIndex model:(id)model;
@end

@interface SBRecordToolBar : UIView
//是否展开
@property (nonatomic,readonly) BOOL isExpand;

//是否显示
@property (nonatomic,readonly) BOOL isShow;

@property (nonatomic) SBRecordToolBarEnum barEnum;

+ (SBRecordToolBar *)toolBarWithDelegate:(id)delegate;

- (void)hideTopic;

- (void)showTopic;
@end
