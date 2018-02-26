//
//  SBRecordUIDatasConfiguration.m
//  SBRecorder
//
//  Created by qyb on 2018/1/11.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBRecordUIDatasConfiguration.h"
#import "SBRecordTopicView.h"
@implementation SBRecordUIDatasConfiguration



+ (NSArray *)topicItemDatas{
    SBRecordTopicItemModel *beautiful = [SBRecordTopicItemModel new];
    beautiful.title = @"美颜";
    return @[beautiful];
}

@end
