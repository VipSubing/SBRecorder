//
//  SBTopToolsBar.m
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBTopToolsBar.h"
#import "SBRecorderHeader.h"

@implementation SBRecordToolBarModel

@end

@interface SBRecordCollectionViewCell : UICollectionViewCell
{
    UIImageView *_icon;
}
@end
@implementation SBRecordCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _icon = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_icon];
    }
    return self;
}
- (void)setImage:(UIImage *)image{
    _icon.image = image;
}
@end
#define kItemWidth 27
static NSString *const collection_identifier = @"SBTopToolsBar_collection_identifier";

@interface SBTopToolsBar()<UICollectionViewDelegate,UICollectionViewDataSource>
@end
@implementation SBTopToolsBar
#pragma mark - Public
+ (instancetype)topToolsBar{
    SBTopToolsBar *bar = [[SBTopToolsBar alloc] initWithFrame:CGRectMake(0, 20, 0, 44)];
    return bar;
}
- (void)show{
    [self showAnimation];
}
- (void)hide{
    [self hidenAnimation];
}
#pragma mark -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame collectionViewLayout:[self mylayout]]) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[SBRecordCollectionViewCell class] forCellWithReuseIdentifier:collection_identifier];
    }
    return self;
}
- (UICollectionViewFlowLayout *)mylayout{
    // 设置布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    //布局滚动方向  设置
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //item 之间的最小值
    layout.minimumInteritemSpacing = 10;
    //行之间的最小值
    layout.minimumLineSpacing = 30;
    layout.itemSize = CGSizeMake(kItemWidth, kItemWidth);
    return layout;
}
- (void)setFlashStatus:(BOOL)status{
    SBRecordToolBarModel *flash = _datas[0];
    flash.invalid = !status;
    [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
}
#pragma mark - over write
- (void)reloadData{
    [super reloadData];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    float width = _datas.count * (kItemWidth+30);
    self.frame = CGRectMake(ScreenWidth-width, 20, width, 44);
}

#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SBRecordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collection_identifier forIndexPath:indexPath];
    SBRecordToolBarModel *model = _datas[indexPath.row];
    [cell setImage:[UIImage imageNamed:model.selectUrl]];
    if (model.invalid) {
        cell.hidden = YES;
    }else cell.hidden = NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SBRecordToolBarModel *model = _datas[indexPath.row];
    if (model.invalid) return;
    model.selected = !model.selected;
    [self reloadItemsAtIndexPaths:@[indexPath]];
    if ([self.toolDelegate respondsToSelector:@selector(toolsBarModel:didSelectItemAtIndex:)]) {
        [self.toolDelegate toolsBarModel:model didSelectItemAtIndex:model.index];
    }
}
- (void)hidenAnimation{
    CABasicAnimation *hidenAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hidenAnimation.fromValue =  @(self.layer.opacity);
    hidenAnimation.toValue = @(0.f);
    hidenAnimation.duration = 0.2f;
    self.layer.opacity = 0.f;
    [self.layer addAnimation:hidenAnimation forKey:@"hiden_opacity"];
}
- (void)showAnimation{
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue =  @(self.layer.opacity);
    showAnimation.toValue = @(1.f);
    showAnimation.duration = 0.2f;
    self.layer.opacity = 1.f;
    [self.layer addAnimation:showAnimation forKey:@"show_opacity"];
}
@end
