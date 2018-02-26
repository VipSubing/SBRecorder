//
//  SBRecordTopicView.m
//  SBRecorder
//
//  Created by qyb on 2017/10/21.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBRecordTopicView.h"
#import "SBRecorderHeader.h"

@implementation SBRecordTopicItemModel
- (void)setSelected:(BOOL)selected{
    _selected = selected;
    
}
- (SBToolFunctionView *)func{
    if (_func == nil) {
        Class funcClass = NSClassFromString(_funcClass);
        _func = [[funcClass alloc] init];
    }
    return _func;
}
@end
@implementation SBRecordTopicView
{
    void(^_handleBlock)(NSInteger index,SBRecordTopicItemModel *model);
    NSArray *_items;
}
+ (SBRecordTopicView *)topicWithFrame:(CGRect)frame handleBlock:(void(^)(NSInteger index,SBRecordTopicItemModel *model))handleBlock{
    SBRecordTopicView *topic = [[SBRecordTopicView alloc] initWithFrame:frame];
    topic->_handleBlock = [handleBlock copy];
    return topic;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.alwaysBounceHorizontal = NO;
    }
    return self;
}

- (void)setDatas:(NSArray *)datas{
    _datas = datas.copy;
    [self reloadData];
}
- (void)removeSubViews{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}
- (void)reloadData{
    [self removeSubViews];
    CGFloat itemWidth = _datas.count > 4 ? ScreenWidth/4:ScreenWidth/_datas.count;
    self.contentSize = CGSizeMake(itemWidth*_datas.count, self.bounds.size.height);
    NSMutableArray *items = [NSMutableArray new];
    
    for (int i = 0; i < _datas.count; i ++) {
        UIButton *item = [self item];
        SBRecordTopicItemModel *model = _datas[i];
        item.frame = CGRectMake(itemWidth*i, 0, itemWidth, self.bounds.size.height);
        item.tag = 100 + i;
        [item setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
        [item setTitle:model.title forState:UIControlStateNormal];
        [item setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [item setTitleColor:DefaultColor forState:UIControlStateSelected];
        [items addObject:item];
        [self addSubview:item];
    }
    _items = items.copy;
}
- (UIButton *)item{
    UIButton *item = [[UIButton alloc] init];
    [item addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
    item.titleLabel.font = [UIFont fontWithName:@"Heiti TC" size:16];
    return item;
}
- (void)remuseNomal{
    for (UIButton *button in _items) {
        button.selected = NO;
    }
}
- (void)didSelectedItem:(UIButton *)item{
    NSInteger index = item.tag - 100;
    for (UIButton *button in _items) {
        if (button == item) continue;
        button.selected = NO;
    }
    item.selected = YES;
    SBRecordTopicItemModel *model = _datas[index];
    if (_handleBlock) {
        _handleBlock(index,model);
    }
}
@end
