//
//  SBRecordTopicView.h
//  SBRecorder
//
//  Created by qyb on 2017/10/21.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBToolFunctionView.h"

@interface SBRecordTopicItemModel:NSObject
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *icon;
@property (assign,nonatomic) BOOL selected;

@property (strong,nonatomic) SBToolFunctionView *func;
@property (copy,nonatomic) NSString * funcClass;
@property (nonatomic) id funcDatas;
@end

@interface SBRecordTopicView : UIScrollView
+ (SBRecordTopicView *)topicWithFrame:(CGRect)frame handleBlock:(void(^)(NSInteger index,SBRecordTopicItemModel *model))handleBlock;
@property (strong,nonatomic) NSArray *datas;

- (void)remuseNomal;
@end
