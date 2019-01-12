//
//  UIImage+SimpleGraphics.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIImage+SimpleGraphics.h"

@implementation UIImage (SimpleGraphics)

+ (instancetype)roundRectWithSize:(CGSize)size scale:(CGFloat)scale radius:(CGFloat)radius color:(UIColor *)color
{
    if(radius * 2 > MIN(size.width, size.height)) radius = MIN(size.width, size.height) / 2;
    if(scale == 0) scale = UIScreen.mainScreen.scale;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:radius];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [color setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
