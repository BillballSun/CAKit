//
//  UIImage+PlainImage.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/24.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (PlainImage)

+ (UIImage *)plainImageWithSize:(CGSize)size;
+ (UIImage *)plainImageWithSize:(CGSize)size scale:(CGFloat)scale;
+ (UIImage *)plainImageWithSize:(CGSize)size scale:(CGFloat)scale color:(UIColor *)color;

@end
