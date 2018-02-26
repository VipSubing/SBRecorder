//
//  SBRecordPerssionController.m
//  SBRecorder
//
//  Created by qyb on 2018/1/25.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBRecordPerssionController.h"

@interface SBRecordPerssionController ()
@property (nonatomic) UILabel *noticeLabel;
@end

@implementation SBRecordPerssionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"提示";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupBackItem];
    
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 50)];
    _noticeLabel.textColor = [UIColor blueColor];
    _noticeLabel.font = [UIFont systemFontOfSize:17];
    _noticeLabel.text = _notice;
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noticeLabel];
}
- (void)setupBackItem{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 30, 30)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"SBRecorder.bundle/nav_back"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBarButtonItems = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBarButtonItems;
}
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
