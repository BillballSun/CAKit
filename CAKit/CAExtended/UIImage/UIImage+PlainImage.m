//
//  UIImage+PlainImage.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/24.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIImage+PlainImage.h"

@implementation UIImage (PlainImage)

+ (UIImage *)plainImageWithSize:(CGSize)size
{
    return [self plainImageWithSize:size scale:UIScreen.mainScreen.scale color:UIColor.whiteColor];
}

+ (UIImage *)plainImageWithSize:(CGSize)size scale:(CGFloat)scale
{
    return [self plainImageWithSize:size scale:scale color:UIColor.whiteColor];
}

+ (UIImage *)plainImageWithSize:(CGSize)size scale:(CGFloat)scale color:(UIColor *)color
{
    if(scale == 0) scale = UIScreen.mainScreen.scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, 0, cs, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(cs);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGRect rect = {0, 0, CGBitmapContextGetWidth(ctx), CGBitmapContextGetHeight(ctx)};
    CGContextFillRect(ctx, rect);
    CGImageRef CGImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    UIImage *image = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(CGImage);
    return image;
}

@end
