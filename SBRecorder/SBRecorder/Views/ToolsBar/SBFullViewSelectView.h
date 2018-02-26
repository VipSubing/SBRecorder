//
//  SBFullViewSelectView.h
//  SBRecorder
//
//  Created by qyb on 2018/1/17.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBToolFunctionView.h"

@interface SBFullViewSelectModel :NSObject
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *imgUrl;
@property (copy,nonatomic) NSString *filter;

+ (id)modelWithDictionary:(NSDictionary *)dic;
@end

@interface SBFullViewSelectView : SBToolFunctionView

@end
