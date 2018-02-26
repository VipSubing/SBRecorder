//
//  ViewController.m
//  SBRecorder
//
//  Created by qyb on 2017/10/11.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "ViewController.h"
#import "SBRecordController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
    float width = [UIScreen mainScreen].bounds.size.width;
    UIButton *record = [[UIButton alloc] initWithFrame:CGRectMake(width/2-100, 100, 100, 100)];
    
    
    [record setTitle:@"record" forState:UIControlStateNormal];
    [record setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [record addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:record];
}

- (void)record:(id)sender{
    SBRecordController *record = [SBRecordController recordWithDelegate:self];
    record.maxOutputFilesCount = 5;
    record.maxDuration = 10;
    record.recordStrokeColor = self.view.tintColor;
//    record.videoResolution = AVCaptureSessionPreset320x240;
    [self presentViewController:record animated:YES completion:nil];
}
- (void)recordDidFinishWithFileUrl:(NSURL *)fileUrl thumbnail:(UIImage *)thumbnail duration:(NSTimeInterval)duration completed:(BOOL)completed{
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
