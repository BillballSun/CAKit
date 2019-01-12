//
//  CAAccelerateFunction.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/9.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <float.h>
#import "CAAccelerateFunction.h"

@interface CAAccelerateFunction ()
@property(readwrite) double initialVelocity;
@property(readwrite) double accelerate;
@property(readwrite) double initialDistance;
@end

@implementation CAAccelerateFunction

- (instancetype)initWithInitialVelocity:(double)initalVelocity accelerate:(double)accelerate initialDistance:(double)initialDistance
{
    if(self = [super init])
    {
        self.initialVelocity = initalVelocity;
        self.accelerate = accelerate;
        self.initialDistance = initialDistance;
    }
    return self;
}

- (double)distanceAtTime:(double)time
{
    double a = self.accelerate;
    double s0 = self.initialDistance;
    double v0 = self.initialVelocity;
    return 0.5 * a * time * time + v0 * time + s0;
}

- (double)velocityAtTime:(double)time
{
    double a = self.accelerate;
    double v0 = self.initialVelocity;
    return a * time + v0;
}

- (BOOL)hasExtream
{
    if(self.accelerate * self.initialVelocity > 0)
        return NO;
    return YES;
}

- (double)extreamDistance
{
    if(!self.extream) return DBL_MAX;
    return [self distanceAtTime:self.extreamTime];
}

- (double)extreamTime
{
    if(!self.extream) return DBL_MAX;
    return fabs(self.initialVelocity) / fabs(self.accelerate);
}

@end
