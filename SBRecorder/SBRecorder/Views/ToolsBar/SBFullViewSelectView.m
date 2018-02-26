//
//  SBFullViewSelectView.m
//  SBRecorder
//
//  Created by qyb on 2018/1/17.
//  Copyright © 2018年 qyb. All rights reserved.
//
#import <objc/runtime.h>
#import "SBRecorderHeader.h"
#import "SBFullViewSelectView.h"
#import "SBRecordCancleCell.h"
@implementation SBFullViewSelectModel
- (id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

+ (id)modelWithDictionary:(NSDictionary *)dic
{
    id model = [[self alloc]initWithDictionary:dic];
    return model;
}
@end

@interface SBFullViewSelectCell :UICollectionViewCell
@property (nonatomic) UIImageView *icon;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) SBFullViewSelectModel *model;
@property (nonatomic) BOOL filterSelected;
@end
@implementation SBFullViewSelectCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _icon = [[UIImageView alloc] initWithFrame:self.bounds];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        [self.contentView addSubview:_icon];
        UIBlurEffect *burEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:burEffect];
        effectView.frame = CGRectMake(0, self.bounds.size.height/3*2, self.bounds.size.width, self.bounds.size.height/3);
        [self.contentView addSubview:effectView];
        _titleLabel = [[UILabel alloc] initWithFrame:effectView.bounds];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [effectView.contentView addSubview:_titleLabel];
    }
    return self;
}
- (void)setFilterSelected:(BOOL)filterSelected{
    if (_filterSelected != filterSelected) {
        filterSelected?[self selectedState]:[self unselectedState];
    }
    _filterSelected = filterSelected;
}
- (void)setModel:(SBFullViewSelectModel *)model{
    _model = model;
    _titleLabel.text = model.title;
    _icon.image = [UIImage imageNamed:model.imgUrl];
}
- (void)selectedState{
    self.contentView.layer.borderWidth = 4;
    self.contentView.layer.borderColor = DefaultColor.CGColor;
    _titleLabel.textColor = DefaultColor;
}
- (void)unselectedState{
    self.contentView.layer.borderWidth = 0;
//    self.contentView.layer.borderColor = DefaultColor.CGColor;
    _titleLabel.textColor = [UIColor whiteColor];
}
@end

@interface SBFullViewSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSArray *modelDatas;
@property (weak,nonatomic) SBFullViewSelectCell *selectedCell;
@end
@implementation SBFullViewSelectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self mylayout]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[SBFullViewSelectCell class] forCellWithReuseIdentifier:@"SBFullViewSelectCell"];
        [_collectionView registerClass:[SBRecordCancleCell class] forCellWithReuseIdentifier:@"SBRecordCancleCell"];
        
    }
    return self;
}
- (void)setDatas:(NSArray *)datas{
    [super setDatas:datas];
    NSMutableArray *modelDatas = [NSMutableArray new];
    [modelDatas addObject:@0];// number 0 作为取消标记位置
    for (NSDictionary *dict in datas) {
        SBFullViewSelectModel *model = [SBFullViewSelectModel modelWithDictionary:dict];
        [modelDatas addObject:model];
    }
    self.modelDatas = modelDatas.copy;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
}
- (UICollectionViewFlowLayout *)mylayout{
    // 设置布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 3;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    CGFloat width = (([UIScreen mainScreen].bounds.size.width-20)-3*10)/4;
    layout.itemSize = CGSizeMake(width, width);
    return layout;
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelDatas.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.modelDatas[indexPath.row];
    if ([model isKindOfClass:[NSNumber class]]) {
        //取消
        SBRecordCancleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBRecordCancleCell" forIndexPath:indexPath];
        return cell;
    }else{
        //滤镜
        SBFullViewSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SBFullViewSelectCell" forIndexPath:indexPath];
        cell.model = self.modelDatas[indexPath.row];
        return cell;
    }
    return nil;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.modelDatas[indexPath.row];
    if ([self.funcDelegate respondsToSelector:@selector(functionView:didSelectedTopicIndex:modelIndex:model:)]) {
        //撤销上一个选中
        self.selectedCell.filterSelected = NO;
        if (![model isKindOfClass:[NSNumber class]]) {
            
            //开始下一个选中
            self.selectedCell = (SBFullViewSelectCell *)[collectionView cellForItemAtIndexPath:indexPath];
            self.selectedCell.filterSelected = YES;
        }
        [self.funcDelegate functionView:self didSelectedTopicIndex:self.topicIndex modelIndex:indexPath.row model:model];
    }
}
@end
