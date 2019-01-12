//
//  UIImage+SimpleGraphics.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SimpleGraphics)

+ (instancetype)roundRectWithSize:(CGSize)size scale:(CGFloat)scale radius:(CGFloat)radius color:(UIColor *)color;

@end
