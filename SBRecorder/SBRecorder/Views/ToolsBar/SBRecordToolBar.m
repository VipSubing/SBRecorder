//
//  SBRecordToolBar.m
//  SBRecorder
//
//  Created by qyb on 2017/10/21.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import "SBSkinCareSelectView.h"
#import "SBRecordToolBar.h"
#import "SBRecorderHeader.h"
#import "SBRecordUIDatasConfiguration.h"
#import "SBSkinCareSelectView.h"

@interface SBRecordToolBar()<UIGestureRecognizerDelegate>
@property (strong,nonatomic) SBRecordTopicView *topicView;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) UITapGestureRecognizer *cancleGestureRecognizer;
@property (nonatomic,readwrite) BOOL isExpand;
@property (nonatomic,readwrite) BOOL isShow;
@property (nonatomic) NSInteger topIndex;
@property (nonatomic) NSArray *datas;

@property (weak,nonatomic) id <SBRecordToolBarDelegate> delegate;
@end
@implementation SBRecordToolBar
{
    BOOL _lock;
}
+ (SBRecordToolBar *)toolBarWithDelegate:(id)delegate{
    SBRecordToolBar *bar = [[SBRecordToolBar alloc] initWithFrame:CGRectMake(0, ScreenHeight-150, ScreenWidth, 150)];
    bar.delegate = delegate;
    return bar;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
        _isShow = YES;
        //添加手势
        _cancleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleTouchAction:)];
        _cancleGestureRecognizer.cancelsTouchesInView = NO;
        _cancleGestureRecognizer.delegate = self;
        _cancleGestureRecognizer.enabled = NO;
        
        [self addSubview:self.topicView];
        [self addSubview:self.scrollView];
        
        
        
    }
    return self;
}
- (void)firstExpand{
    if (!_lock) {
        _lock = YES;
        self.scrollView.frame = CGRectMake(0, self.topicView.bounds.size.height, self.bounds.size.width, self.bounds.size.height-self.topicView.bounds.size.height);
        [self initContents];
        [self reloadContents];
    }
}
- (void)setBarEnum:(SBRecordToolBarEnum)barEnum{
    _barEnum = barEnum;
    NSMutableArray *items = [NSMutableArray new];
    if (_barEnum & SBRecordToolBarEnumWithFace) {
        SBRecordTopicItemModel *face = [SBRecordTopicItemModel new];
        face.title = @"贴纸";
        face.funcClass = @"SBFullViewSelectView";
        face.funcDatas = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceResource" ofType:@"plist"]];
        [items addObject:face];
    }
    if (_barEnum & SBRecordToolBarEnumWithFullView) {
        //全景
        SBRecordTopicItemModel *full = [SBRecordTopicItemModel new];
        full.title = @"全景";
        full.funcClass = @"SBFullViewSelectView";
        
        full.funcDatas = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fullViewFilters" ofType:@"plist"]];
        [items addObject:full];
    }
    if (_barEnum & SBRecordToolBarEnumWithSkin) {
        //美颜
        SBRecordTopicItemModel *skin = [SBRecordTopicItemModel new];
        skin.title = @"美颜";
        skin.funcClass = @"SBSkinCareSelectView";
        skin.selected = YES;
        skin.funcDatas = @[@(0.1),@(0.35),@(0.5),@(0.65),@(0.8),@(1.f)];
        [items addObject:skin];
    }
    
    self.datas = items.copy;
    [self setTopicDatas:self.datas];
}

- (void)initContents{
    for (int i = 0; i < self.datas.count; i ++) {
        SBRecordTopicItemModel *item = self.datas[i];
        item.func.funcDelegate = self;
        [self.scrollView addSubview:item.func];
        item.func.frame = CGRectMake(i * _scrollView.bounds.size.width, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    }
}
- (void)reloadContents{
    for (int i = 0; i < self.datas.count; i ++) {
        SBRecordTopicItemModel * item = self.datas[i];
        item.func.datas = item.funcDatas;
    }
}
- (void)setTopicDatas:(NSArray *)topicDatas{
    self.topicView.datas = topicDatas;
}
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.topicView.bounds.size.height, self.bounds.size.width, self.bounds.size.height-self.topicView.bounds.size.height)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}
- (SBRecordTopicView *)topicView{
    if (_topicView == nil) {
        __weak typeof(self) weak = self;
        _topicView = [SBRecordTopicView topicWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40) handleBlock:^(NSInteger index, SBRecordTopicItemModel *model) {
            BOOL animation = YES;
            if (weak.isShow && !weak.isExpand) {
                [weak expand];
                animation = NO;
            }
            weak.topIndex = index;
            [weak.scrollView setContentOffset:CGPointMake(index*weak.bounds.size.width, weak.scrollView.contentOffset.y) animated:animation];
        }];
        [self addSubview:_topicView];
    }
    return _topicView;
}
#pragma mark  - operation
- (void)cancleTouchAction:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    if (![self whileLocationInViewWithPoint:point]) {
        [self retract];
    }
}
- (void)activationCancleGesture{
    _cancleGestureRecognizer.enabled = YES;
    if (!_cancleGestureRecognizer.view) {
        [self.window addGestureRecognizer:_cancleGestureRecognizer];
    }
}
- (void)closeCancleGesture{
    _cancleGestureRecognizer.enabled = NO;
}
//展开
- (void)expand{
    self.isExpand = YES;
    if ([_delegate respondsToSelector:@selector(toolFunctionShouldExpandWithBar:)]) {
        [_delegate toolFunctionShouldExpandWithBar:self];
    }
    [self expandAnimation];
    [self activationCancleGesture];
    [self firstExpand];
    
    [self contentShowAnimation];
}
//收起
- (void)retract{
    self.isExpand = NO;
    [self.topicView remuseNomal];
    [self closeCancleGesture];
    if ([_delegate respondsToSelector:@selector(toolFunctionShouldRetractWithBar:)]) {
        [_delegate toolFunctionShouldRetractWithBar:self];
    }
    [self retractAnimation];
    [self contentHidenAnimation];
}
//隐藏
- (void)hiden{
    self.isShow = NO;
    self.userInteractionEnabled = NO;
    [self hidenAnimation];
}
//显示
- (void)show{
    self.isShow = YES;
    self.userInteractionEnabled = YES;
    [self showAnimation];
}

- (void)hideTopic{
    [self hideTopicBarAnimation];
}
- (void)showTopic{
    [self showTopicBarAnimation];
}
#pragma mark - SBToolFunctionViewDelegate
- (void)functionView:(SBToolFunctionView *)view didSelectedTopicIndex:(NSInteger)topIndex modelIndex:(NSInteger)modelIndex model:(id)model{
    if ([self.delegate respondsToSelector:@selector(toolBar:didSelectedTopicIndex:modelIndex:model:)]) {
        [self.delegate toolBar:self didSelectedTopicIndex:self.topIndex modelIndex:modelIndex model:model];
    }
}
#pragma mark - animation
- (void)contentHidenAnimation{
    CABasicAnimation *hidenAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hidenAnimation.fromValue =  @(self.scrollView.layer.opacity);
    hidenAnimation.toValue = @(0.f);
    hidenAnimation.duration = 0.1f;
    self.scrollView.layer.opacity = 0.f;
    [self.scrollView.layer addAnimation:hidenAnimation forKey:@"hiden_opacity"];
}
- (void)contentShowAnimation{
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue =  @(self.scrollView.layer.opacity);
    showAnimation.toValue = @(1.f);
    showAnimation.duration = 0.1f;
    self.scrollView.layer.opacity = 1.f;
    [self.scrollView.layer addAnimation:showAnimation forKey:@"show_opacity"];
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
- (void)expandAnimation{
    CGRect rect = self.frame;
    rect.size.height = 200.f;
    rect.origin.y = ScreenHeight-rect.size.height;
    [UIView animateWithDuration:0.2f animations:^{
        self.frame = rect;
    }];
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    expandAnimation.fromValue = (__bridge id)self.layer.backgroundColor;
    expandAnimation.toValue = (__bridge id)[UIColor colorWithWhite:0.f alpha:0.5f].CGColor;
    expandAnimation.duration = 0.2f;
    self.layer.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5f].CGColor;
    [self.layer addAnimation:expandAnimation forKey:@"retract_backgroundColor"];
}
- (void)retractAnimation{
    CGRect rect = self.frame;
    rect.size.height = 150.f;
    rect.origin.y = ScreenHeight-rect.size.height;
    [UIView animateWithDuration:0.2f animations:^{
        self.frame = rect;
    }];
    
    CABasicAnimation *retractAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    retractAnimation.fromValue = (__bridge id)self.layer.backgroundColor;
    retractAnimation.toValue = (__bridge id)[UIColor colorWithWhite:0.f alpha:0.f].CGColor;
    retractAnimation.duration = 0.2f;
    self.layer.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f].CGColor;
    [self.layer addAnimation:retractAnimation forKey:@"retract_backgroundColor"];
}
- (void)hideTopicBarAnimation{
    CABasicAnimation *hidenAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    hidenAnimation.fromValue =  @(self.topicView.layer.opacity);
    hidenAnimation.toValue = @(0.f);
    hidenAnimation.duration = 0.2f;
    self.topicView.layer.opacity = 0.f;
    [self.topicView.layer addAnimation:hidenAnimation forKey:@"hiden_opacity"];
}
- (void)showTopicBarAnimation{
    CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showAnimation.fromValue =  @(self.topicView.layer.opacity);
    showAnimation.toValue = @(1.f);
    showAnimation.duration = 0.2f;
    self.topicView.layer.opacity = 1.f;
    [self.topicView.layer addAnimation:showAnimation forKey:@"show_opacity"];
}
#pragma mark -
- (void)dealloc{
    [self.window removeGestureRecognizer:_cancleGestureRecognizer];
}
#pragma mark - UIGestureRecognizerDelegate
//只能同时识别一个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}
//竞争手势应该失败
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view.superview isKindOfClass:[UICollectionViewCell class]] || [touch.view.superview isKindOfClass:[SBToolFunctionView class]]) {
        //点击顶部 不响应
        return NO;
    }
    return YES;
}

- (BOOL)whileLocationInViewWithPoint:(CGPoint)point{
    if (point.x < 0 || point.y > self.bounds.size.height || point.x > self.bounds.size.width || point.y < 0) {
        return NO;
    }
    return YES;
}

@end
