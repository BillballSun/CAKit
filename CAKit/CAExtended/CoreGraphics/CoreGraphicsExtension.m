//
//  CoreGraphicsExtension.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#include "CoreGraphicsExtension.h"

CGRect CGRectContainRect(CGRect outside, CGRect inside)
{
    CGFloat left = inside.origin.x,
            right = inside.origin.x + inside.size.width,
            top = inside.origin.y,
            bottom = inside.origin.y + inside.size.height;
    CGFloat leftMax = outside.origin.x,
            rightMax = outside.origin.x + outside.size.width,
            topMax = outside.origin.y,
            bottomMax = outside.origin.y + outside.size.height;
    
    if(left < rightMax && right > leftMax && top > bottomMax && bottom < topMax)
    {
        if(left < leftMax) left = leftMax;
        if(right > rightMax) right = rightMax;
        if(top > topMax) top = topMax;
        if(bottom < bottomMax) bottom = bottomMax;
        CGPoint origin = CGPointMake(left, top);
        CGSize size = CGSizeMake(right - left, bottom - top);
        return (CGRect){origin, size};
    }
    return CGRectZero;
}

CGRect CGRectCombine(CGRect one, CGRect another) {
    CGRect result;
    result.origin.x = fmin(one.origin.x, another.origin.x);
    result.origin.y = fmin(one.origin.y, another.origin.y);
    result.size.width = fmax(one.size.width + one.origin.x - result.origin.x, another.size.width + another.origin.x - result.origin.x);
    result.size.height = fmax(one.size.height + one.origin.y - result.origin.y, another.size.height + another.origin.y - result.origin.y);
    return result;
}
