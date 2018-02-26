//
//  DemoPreDefine.h
//  IFlyFaceRequestDemo
//
//  Created by 张剑 on 14/10/24.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

#ifndef IFlyFaceRequestDemo_DemoPreDefine_h
#define IFlyFaceRequestDemo_DemoPreDefine_h


#define Margin  5
#define Padding 10
#define iOS7TopMargin 64 //导航栏44，状态栏20
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define ButtonHeight 44
#define NavigationBarHeight 44


#define USER_APPID           @"5a69a3ad"




#ifdef __IPHONE_6_0
# define IFLY_ALIGN_CENTER NSTextAlignmentCenter
#else
# define IFLY_ALIGN_CENTER UITextAlignmentCenter
#endif

#ifdef __IPHONE_6_0
# define IFLY_ALIGN_LEFT NSTextAlignmentLeft
#else
# define IFLY_ALIGN_LEFT UITextAlignmentLeft
#endif


#endif
