//
//  CAFluidDrawerPanGR.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/7.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidDrawerPanGR.h"

@implementation CAFluidDrawerPanGR

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer { return NO; }

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    if([preventedGestureRecognizer.view isDescendantOfView:self.view])
        return NO;
    return YES;
}

@end
