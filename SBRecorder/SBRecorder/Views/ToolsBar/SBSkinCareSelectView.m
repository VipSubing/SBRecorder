//
//  SBSkinCareView.m
//  SBRecorder
//
//  Created by qyb on 2017/10/22.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBSkinCareSelectView.h"
#import "SBRecorderHeader.h"

@class SBSkinCareItem;
@protocol SBSkinCareItemDelegate <NSObject>
@optional
- (void)didSelectedItem:(SBSkinCareItem *)item;
@end


@interface SBSkinCareItem :UIButton
@property (weak,nonatomic) id <SBSkinCareItemDelegate> skinDelegate;
@end
@implementation SBSkinCareItem
- (instancetype)init{
    if (self = [super init]) {
        [self addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        [self setTitleColor:[UIColor colorWithWhite:0 alpha:0.8] forState:UIControlStateNormal];
        [self setTitleColor:DefaultColor forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        self.selected = NO;
    }
    return self;
}
- (void)setSelected:(BOOL)selected{
    selected ? [self selectedState]:[self unselectedState];
    [super setSelected:selected];
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = frame.size.width/2;
}
- (void)selectedState{
    self.layer.borderColor = DefaultColor.CGColor;
    self.layer.borderWidth = 2;
}
- (void)unselectedState{
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}
#pragma mark - delegate
- (void)didSelectedItem:(SBSkinCareItem *)item{
    if ([self.skinDelegate respondsToSelector:@selector(didSelectedItem:)]) {
        [self.skinDelegate didSelectedItem:item];
    }
}
@end


@interface SBSkinCareSelectView ()<SBSkinCareItemDelegate>
@end
@implementation SBSkinCareSelectView
{
    NSArray *_items;
    __weak UIButton *_selectedItem;
}

- (void)removeAllSubviews{
    for (UIView *sub in self.subviews) {
        [sub removeFromSuperview];
    }
}
- (void)setDatas:(NSArray *)datas{
    [super setDatas:datas];
    [self removeAllSubviews];
    CGFloat width = 40;
    CGFloat space = 15;
    CGFloat start_x = (self.bounds.size.width-(datas.count-1)*space-datas.count*width)/2;
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0; i < datas.count; i ++) {
        SBSkinCareItem *item = [[SBSkinCareItem alloc] init];
        item.skinDelegate = self;
        if (i == 0) {
            item.selected = YES;
            _selectedItem = item;
        }
        item.tag = 100 + i;
        item.frame = CGRectMake(start_x+i*(width+space), self.bounds.size.height/2-width/2, width, width);
        
        [item setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];

        [items addObject:item];
        [self addSubview:item];
    }
    _items = items.copy;
}
#pragma mark - delegate
- (void)didSelectedItem:(SBSkinCareItem *)item{
    NSInteger index = item.tag - 100;
    id model = self.datas[index];
    if ([self.funcDelegate respondsToSelector:@selector(functionView:didSelectedTopicIndex:modelIndex:model:)]) {
        //取消上一个
        _selectedItem.selected = NO;
        //开始下一个
        _selectedItem = item;
        _selectedItem.selected = YES;
        
        [self.funcDelegate functionView:self didSelectedTopicIndex:self.topicIndex modelIndex:index model:model];
    }
}
@end
