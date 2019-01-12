//
//  UIImage+DisplayInView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIImage+DisplayInView.h"

@implementation UIImage (DisplayInView)

- (UIImageView *)displayInView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = self.size;
    imageView.frame = frame;
    return imageView;
}

@end
