//
//  UIView+Animation.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/19.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

@end

UIViewAnimationOptions UIViewAnimationCurveToOption(UIViewAnimationCurve curve)
{
    return curve << 16;
}

