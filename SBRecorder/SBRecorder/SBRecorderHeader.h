//
//  SBRecorderHeader.h
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#ifndef SBRecorderHeader_h
#define SBRecorderHeader_h
#import "SBRecordUtils.h"

typedef NS_ENUM(NSInteger,SBRecordFilterEnum) {
    SBRecordFilterSkin, //美颜
    SBRecordFilterFullView ,// 全景
    SBRecordFilterFacialRecognition, //面部识别
};
typedef NS_ENUM(NSInteger,SBRecordToolBarEnum) {
    SBRecordToolBarEnumWithSkin = 1 << 0, //美颜
    SBRecordToolBarEnumWithFullView = 1 << 1, // 全景
    SBRecordToolBarEnumWithFace = 1 << 2, //面部识别
};

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define dispatch_main_async_safa(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#define DefaultColor [UIColor colorWithRed:42.f/255.f green:92.f/255.f blue:170.f/255.f alpha:0.8]
#endif /* SBRecorderHeader_h */
