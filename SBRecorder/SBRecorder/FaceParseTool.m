//
//  FaceParseTool.m
//  SBRecorder
//
//  Created by qyb on 2018/1/31.
//  Copyright © 2018年 qyb. All rights reserved.
//
#import <iflyMSC/IFlyFaceSDK.h>
#import <CoreMotion/CoreMotion.h>
#import "FaceParseTool.h"
#import "IFlyFaceResultKeys.h"
#import "IFlyFaceImage.h"
#import "CalculatorTools.h"
#import "SBRecorderHeader.h"

NSString *const kFacePointsKey = @"kFacePointsKey";

NSString *const kFaceRectKey = @"kFaceRectKey";

NSString *const kFaceOriginsKey = @"kFaceOriginsKey";

@interface FaceParseTool ()
// Device orientation
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, retain) IFlyFaceDetector           *faceDetector;
@end
@implementation FaceParseTool

+ (FaceParseTool *)shareFaceParse{
    FaceParseTool *face = face = [FaceParseTool new];
    return face;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setupFaceSDK];
        [self getDeviceOrientation];
        [self setupFaceDetector];
    }
    return self;
}
#pragma mark - Face SDK
- (void)setupFaceSDK{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //设置log等级，此处log为默认在app沙盒目录下的msc.log文件
        [IFlySetting setLogFile:LVL_ALL];
        //输出在console的log开关
        [IFlySetting showLogcat:YES];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        //设置msc.log的保存路径
        [IFlySetting setLogFilePath:cachePath];
        //所有服务启动前，需要确保执行createUtility
        [IFlySpeechUtility createUtility:@"appid=5a69a3ad"];
    });
}
- (void)setupFaceDetector{
    self.faceDetector = [IFlyFaceDetector sharedInstance];
    if(self.faceDetector){
        [self.faceDetector setParameter:@"1" forKey:@"detect"];
        [self.faceDetector setParameter:@"1" forKey:@"align"];
    }
}
- (void)deallocFaceDetrctor{
    self.faceDetector = nil;
//    [IFlyFaceDetector purgeSharedInstance];
}
- (void)parseSampleBuffer:(CMSampleBufferRef)sampleBuffer cameraPosition:(AVCaptureDevicePosition)cameraPosition callBack:(void(^)(NSArray *array))callBack{
    IFlyFaceImage* faceImg = [self faceImageFromSampleBuffer:sampleBuffer cameraPosition:cameraPosition];
    //识别结果，json数据
    NSString* strResult = [self.faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    [self praseTrackResult:strResult OrignImage:faceImg cameraPosition:cameraPosition callBack:callBack];
    //此处清理图片数据，以防止因为不必要的图片数据的反复传递造成的内存卷积占用
    faceImg.data = nil;
    faceImg = nil;
}
/*
 人脸识别
 */
- (void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg cameraPosition:(AVCaptureDevicePosition)cameraPosition callBack:(void(^)(NSArray *array))callBack{
    if(!result){
        if (callBack) {
            dispatch_main_async_safa(^{
                callBack(nil);
            });
        }
        return;
    }
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            if (callBack) {
                dispatch_main_async_safa(^{
                    callBack(nil);
                });
            }
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            if (callBack) {
                dispatch_main_async_safa(^{
                    callBack(nil);
                });
            }
            return;
        }
        
        //检测到人脸
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* positionDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString = [self praseDetect:positionDic OrignImage:faceImg cameraPosition:cameraPosition];
                positionDic=nil;
                
                NSDictionary* landmarkDic = [faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableArray* strPoints = [self praseAlign:landmarkDic OrignImage:faceImg cameraPosition:cameraPosition];
                landmarkDic=nil;
                
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:kFaceRectKey];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:kFacePointsKey];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:kFaceOriginsKey];
                [arrPersons addObject:dicPerson] ;
                
                dicPerson=nil;
                if (callBack) {
                    dispatch_main_async_safa(^{
                        callBack(arrPersons);
                    });
                }
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

/*
 检测脸部轮廓
 */
- (NSString*)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg cameraPosition:(AVCaptureDevicePosition)cameraPosition{
    
    if(!positionDic){
        return nil;
    }
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = [UIScreen mainScreen].bounds.size.width / faceImg.height;
    CGFloat heightScaleBy = [UIScreen mainScreen].bounds.size.height / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    float cx = (left+right)/2;
    float cy = (top + bottom)/2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);
    BOOL isFrontCamera = cameraPosition == AVCaptureDevicePositionFront;
    if(!isFrontCamera){
        rectFace=rSwap(rectFace);
        rectFace=rRotate90(rectFace, faceImg.height, faceImg.width);
        
    }
    
    rectFace=rScale(rectFace, widthScaleBy, heightScaleBy);
    rectFace = CGRectMake(rectFace.origin.x, rectFace.origin.y, rectFace.size.width, rectFace.size.height);
    return NSStringFromCGRect(rectFace);
    
}



/*
 检测面部特征点
 */

-(NSMutableArray*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg cameraPosition:(AVCaptureDevicePosition)cameraPosition{
    if(!landmarkDic){
        return nil;
    }
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = [UIScreen mainScreen].bounds.size.width / faceImg.height;
    CGFloat heightScaleBy = [UIScreen mainScreen].bounds.size.height / faceImg.width;
    BOOL isFrontCamera = cameraPosition == AVCaptureDevicePositionFront;
    NSMutableArray *arrStrPoints = [NSMutableArray array] ;
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            if(!isFrontCamera){
                p=pSwap(p);
                p=pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p=pScale(p, widthScaleBy, heightScaleBy);
            
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
            
        }
    }
    return arrStrPoints;
    
}
#pragma mark - 判断视频帧方向
- (IFlyFaceImage *)faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer  cameraPosition:(AVCaptureDevicePosition)cameraPosition{
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *lumaBuffer  = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    size_t width  = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context=CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    IFlyFaceDirectionType faceOrientation = [self faceImageOrientation:cameraPosition];
    
    IFlyFaceImage* faceImage=[[IFlyFaceImage alloc] init];
    if(!faceImage){
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.data= (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width=width;
    faceImage.height=height;
    faceImage.direction=faceOrientation;
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    return faceImage;
}
-(IFlyFaceDirectionType)faceImageOrientation:(AVCaptureDevicePosition)cameraPosition{
    IFlyFaceDirectionType faceOrientation=IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera = cameraPosition == AVCaptureDevicePositionFront;
    switch (self.interfaceOrientation) {
        case UIDeviceOrientationPortrait:{//
            faceOrientation=IFlyFaceDirectionTypeLeft;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:{
            faceOrientation=IFlyFaceDirectionTypeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight:{
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeUp:IFlyFaceDirectionTypeDown;
        }
            break;
        default:{//
            faceOrientation=isFrontCamera?IFlyFaceDirectionTypeDown:IFlyFaceDirectionTypeUp;
        }
            break;
    }
    
    return faceOrientation;
}

#pragma mark  - 判断当前设备的方向
- (void)getDeviceOrientation{
    // 这里使用CoreMotion来获取设备方向以兼容iOS7.0设备 检测当前设备的方向 Home键向上还是向下。。。。
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 if (!error) {
                                                     [self updateAccelertionData:accelerometerData.acceleration];
                                                 }
                                                 else{
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}
- (void)updateAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == self.interfaceOrientation)
        return;
    
    self.interfaceOrientation = orientationNew;
}
@end
