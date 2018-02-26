//
//  SBTopToolsBar.h
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBRecordToolBarModel : NSObject
@property (copy,nonatomic) NSString *onUrl;
@property (copy,nonatomic) NSString *offUrl;
@property (copy,nonatomic) NSString *selectUrl;
@property (assign,nonatomic) BOOL invalid;
@property (assign,nonatomic) BOOL selected;
@property (assign,nonatomic) NSInteger index;
@end

@protocol SBTopToolsBarDelegate <NSObject>
- (void)toolsBarModel:(SBRecordToolBarModel *)model didSelectItemAtIndex:(NSInteger)index;
@end

@interface SBTopToolsBar : UICollectionView
+ (instancetype)topToolsBar;
@property (strong,nonatomic) NSArray *datas;
@property (weak,nonatomic) id <SBTopToolsBarDelegate> toolDelegate;
- (void)setFlashStatus:(BOOL)status;

- (void)show;

- (void)hide;
@end
