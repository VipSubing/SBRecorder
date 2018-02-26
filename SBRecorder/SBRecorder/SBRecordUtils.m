//
//  SBRecordUtils.m
//  SBRecorder
//
//  Created by qyb on 2017/10/12.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBRecordUtils.h"

@implementation SBRecordUtils

+ (UIImage *)makeCircularImageWithSize:(CGSize)size
{
    // make a CGRect with the image's size
    CGRect circleRect = (CGRect) {CGPointZero, size};
    // begin the image context since we're not in a drawRect:
    UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);
    // create a UIBezierPath circle
    UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
    // clip to the circle
    [circle addClip];
    // create a border (for white background pictures)
    //#if StrokeRoundedImages
    circle.lineWidth = 12;
    [[UIColor whiteColor] set];
    [circle stroke];
    //#endif
    // get an image from the image context
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    // end the image context since we're not in a drawRect:
    UIGraphicsEndImageContext();
    return roundedImage;
}
+ (UIImage *)drawReturnIcon:(NSString *)name{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 0);
    UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:(CGRect){CGPointZero, CGSizeMake(120, 120)} cornerRadius:60];
    [circle addClip];
   
    UIImage *image = [UIImage imageNamed:name];
    float image_w = image.size.width;
    float image_h = image.size.height;
    float each_1 = 120.f / sqrt(pow(image_w, 2)+pow(image_h, 2));
    float img_w = each_1*image_w;
    float img_h = each_1*image_h;
    float x = (120 - each_1*image_w)/2;
    float y = (120 - each_1*image_h)/2;
    [image drawInRect:CGRectMake(x+img_w/4, y+img_h/4, img_w*0.5, img_h*0.5)];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}
static inline UIImage * drawCircleWithImage(UIImage *image,CGSize size){
    
    CGRect circleRect = (CGRect) {CGPointZero, size};
    UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);
    UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
    [circle addClip];
    [image drawInRect:circleRect];
    
    
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}
+ (UIImage *)drawSkinCareSelectImageForIndex:(NSInteger)index  select:(BOOL)flag{
    CGSize size = (CGSize){100,100};
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    float color_f = flag?0.0f:1.f;
    [[UIColor colorWithWhite:color_f alpha:0.8] set];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    NSString *number = [NSString stringWithFormat:@"%ld",index];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    UIColor *numberColor = flag?[UIColor whiteColor]:[UIColor colorWithWhite:0.0f alpha:0.8];
    UIFont *font = [UIFont boldSystemFontOfSize:40];
    [number drawInRect:CGRectMake(0, 100-font.pointSize, size.width, size.width) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:numberColor,NSParagraphStyleAttributeName:paragraph}];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawCircleWithImage(image,size);
}
+ (NSArray *)fileCountInDiskfolderWithDirectory:(NSString *)directory{
    
    NSFileManager *fm =  [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:&error];
    return files;
}

+ (int64_t) diskSpaceFree{
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) return -1;
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}
@end
