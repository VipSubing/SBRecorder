//
//  SBFaceBaseView.h
//  SBRecorder
//
//  Created by qyb on 2018/2/5.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceParseTool.h"
#import "SBRecorderHeader.h"
@interface SBFaceBaseView : UIView

@property (nonatomic) NSArray *faces;

//允许自动绘制脸部矩形 Defaults NO
@property (assign,nonatomic) BOOL allowFaceRectangle;


- (void)drawFaceView:(NSArray *)faces;
@end
