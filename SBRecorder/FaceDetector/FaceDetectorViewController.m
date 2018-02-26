//
//  FaceDetectorViewController.m
//  IFlyFaceDemo
//
//  Created by 张剑 on 15/6/25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "FaceDetectorViewController.h"
#import "UIImage+Extensions.h"
#import "UIImage+compress.h"
#import "DemoPreDefine.h"
#import "PermissionDetector.h"
#import <iflyMSC/IFlyFaceSDK.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "IFlyFaceResultKeys.h"

@interface FaceDetectorViewController ()
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UIPopoverControllerDelegate
>

@property (nonatomic,retain) IBOutlet UIImageView     * imgToUse;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * imgSelectBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * detectBtn;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * backBtn;
@property (nonatomic,retain) UIPopoverController      * popover;
@property (nonatomic,retain) CALayer                  * imgToUseCoverLayer;
@property (nonatomic,assign) int                      keyboardHight;
@property (nonatomic,retain) IFlyFaceDetector         * faceDetector;

@end


@implementation FaceDetectorViewController
//@synthesize activityIndicator=_activityIndicator;
@synthesize imgSelectBtn=_imgSelectBtn;
@synthesize detectBtn=_detectBtn;
@synthesize backBtn=_backBtn;
@synthesize imgToUse=_imgToUse;
@synthesize imgToUseCoverLayer=_imgToUseCoverLayer;


- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title=@"离线图片检测示例";
    
    //adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER ){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    self.faceDetector=[IFlyFaceDetector sharedInstance];
    
    self.imgToUse.contentMode = UIViewContentModeScaleAspectFit;
//    [self.activityIndicator setHidden:YES];
//    CGRect rect= self.activityIndicator.frame;
//    self.activityIndicator.frame=CGRectMake(rect.origin.x-1.5*rect.size.width, rect.origin.y-1.5*rect.size.height, 3*rect.size.width, 3*rect.size.height);
    self.imgSelectBtn.enabled=YES;
    
}

-(void)dealloc{
    self.popover=nil;
    self.imgToUse.layer.sublayers=nil;
    self.imgToUse=nil;
    self.imgToUseCoverLayer.sublayers=nil;
    self.imgToUseCoverLayer=nil;
}

-(void)showAlert:(NSString*)info{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:info delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

#pragma mark - button event

- (void)presentImagePicker:(UIImagePickerController* )picker{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        if(self.popover){
//            self.popover=nil;
//        }
//        self.popover=[[UIPopoverController alloc] initWithContentViewController:picker];
//        self.popover.delegate=self;
//        [self.popover presentPopoverFromBarButtonItem: self.imgSelectBtn
//                             permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//    }
//    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)btnbackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSelectImageClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"摄相机", @"图片库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheet.alpha = 1.f;
    actionSheet.tag = 1;
    
    UIView *bgView=[[UIView alloc] initWithFrame:actionSheet.frame];
    bgView.backgroundColor = [UIColor lightGrayColor];
    [actionSheet addSubview:bgView];
    bgView=nil;
    
    [actionSheet showInView:self.view];
    actionSheet=nil;
    
}

- (IBAction)btnDetectImageClicked:(id)sender {
    NSString* strResult=[self.faceDetector detectARGB:[_imgToUse image]];
    NSLog(@"result:%@",strResult);
    [self praseDetectResult:strResult];
}

- (void)btnExploerClicked:(id)sender {
    
    if(![PermissionDetector isAssetsLibraryPermissionGranted]){
        NSString* info=@"没有相册权限";
        [self showAlert:info];
        return;
    }

    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _detectBtn.enabled=NO;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    if([UIImagePickerController isSourceTypeAvailable: picker.sourceType ]) {
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.delegate = self;
        picker.allowsEditing = NO;
    }
    
    [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];
    picker=nil;
}

- (void)btnPhotoClicked:(id)sender {
    
    if(![PermissionDetector isCapturePermissionGranted]){
        NSString* info=@"没有相机权限";
        [self showAlert:info];
        return;
    }
    
    _backBtn.enabled=NO;
    _imgSelectBtn.enabled=NO;
    _detectBtn.enabled=NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
        picker.mediaTypes = @[(NSString*)kUTTypeImage];
        picker.allowsEditing = NO;//设置可编辑
        picker.delegate = self;
        
        [self performSelector:@selector(presentImagePicker:) withObject:picker afterDelay:1.0f];
        picker=nil;
        
    }else{

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        _backBtn.enabled=YES;
        _imgSelectBtn.enabled=YES;
        _detectBtn.enabled=YES;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag)
    {
        case 1://选择图片
            switch (buttonIndex)
        {

            case 0:
            {
                [self btnPhotoClicked:nil];
            }
                break;
            case 1:
            {
                [self btnExploerClicked:nil];
            }
                break;
        }
            break;
    }
}
#pragma mark - Data Parser

-(void)praseDetectResult:(NSString*)result{
    NSString *resultInfo = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSNumber* ret=[dic objectForKey:KCIFlyFaceResultRet];
            NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
            //检测
            if(ret && [ret intValue]==0 && faceArray &&[faceArray count]>0){
                resultInfo=[resultInfo stringByAppendingFormat:@"检测到人脸轮廓"];
            }else{
                resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸轮廓"];
            }
                
                
            //绘图
            if(_imgToUseCoverLayer){
                _imgToUseCoverLayer.sublayers=nil;
                [_imgToUseCoverLayer removeFromSuperlayer];
                _imgToUseCoverLayer=nil;
            }
            _imgToUseCoverLayer = [[CALayer alloc] init];
            
            for(id faceInArr in faceArray){
                
                CALayer* layer= [[CALayer alloc] init];
                layer.borderWidth = 2.0f;
                [layer setCornerRadius:2.0f];
                
                float image_x, image_y, image_width, image_height;
                if(_imgToUse.image.size.width/_imgToUse.image.size.height > _imgToUse.frame.size.width/_imgToUse.frame.size.height){
                    image_width = _imgToUse.frame.size.width;
                    image_height = image_width/_imgToUse.image.size.width * _imgToUse.image.size.height;
                    image_x = 0;
                    image_y = (_imgToUse.frame.size.height - image_height)/2;
                    
                }else if(_imgToUse.image.size.width/_imgToUse.image.size.height < _imgToUse.frame.size.width/_imgToUse.frame.size.height)
                {
                    image_height = _imgToUse.frame.size.height;
                    image_width = image_height/_imgToUse.image.size.height * _imgToUse.image.size.width;
                    image_y = 0;
                    image_x = (_imgToUse.frame.size.width - image_width)/2;
                    
                }else{
                    image_x = 0;
                    image_y = 0;
                    image_width = _imgToUse.frame.size.width;
                    image_height = _imgToUse.frame.size.height;
                }
                
                CGFloat resize_scale = image_width/_imgToUse.image.size.width;
                //
                if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                    NSDictionary* position=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                    if(position){
                        CGFloat bottom =[[position objectForKey:KCIFlyFaceResultBottom] floatValue];
                        CGFloat top=[[position objectForKey:KCIFlyFaceResultTop] floatValue];
                        CGFloat left=[[position objectForKey:KCIFlyFaceResultLeft] floatValue];
                        CGFloat right=[[position objectForKey:KCIFlyFaceResultRight] floatValue];
                        
                        float x = left;
                        float y = top;
                        float width = right- left;
                        float height = bottom- top;
                        
                        CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                        
                        [layer setFrame:innerRect];
                        layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                    }
                }
                
                [_imgToUseCoverLayer addSublayer:layer];
                layer=nil;
                
            }
            self.imgToUse.layer.sublayers=nil;
            [self.imgToUse.layer addSublayer:_imgToUseCoverLayer];
            _imgToUseCoverLayer=nil;
        
        }
    
        _backBtn.enabled=YES;
        _imgSelectBtn.enabled=YES;
        _detectBtn.enabled=YES;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

#pragma mark - UIPopoverControllerDelegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    _backBtn.enabled=YES;
    [self.imgSelectBtn setEnabled:YES];
    [self.detectBtn setEnabled:YES];

    return YES;
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate=nil;
    picker=nil;
    if(_imgToUseCoverLayer){
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer.sublayers=nil;
        _imgToUseCoverLayer=nil;
    }
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _imgToUse.image=nil;
    _imgToUse.layer.sublayers=nil;
    _imgToUse.image = [image fixOrientation];//将图片压缩以上传服务器
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _detectBtn.enabled=YES;
    image=nil;
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate=nil;
    picker=nil;
    _backBtn.enabled=YES;
    _imgSelectBtn.enabled=YES;
    _detectBtn.enabled=YES;
    
    if(self.popover){
        [self.popover dismissPopoverAnimated:YES];
        self.popover=nil;
    }
}


@end
