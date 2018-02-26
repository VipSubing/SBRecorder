//
//  SBRecordCancleCell.m
//  SBRecorder
//
//  Created by qyb on 2018/1/22.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBRecordCancleCell.h"

@implementation SBRecordCancleCell
{
    UIImageView *_icon;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _icon = [[UIImageView alloc] initWithFrame:self.bounds];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        _icon.image = [UIImage imageNamed:@"SBRecorder.bundle/filter_cancle"];
        [self.contentView addSubview:_icon];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _icon.frame = self.bounds;
}
@end
