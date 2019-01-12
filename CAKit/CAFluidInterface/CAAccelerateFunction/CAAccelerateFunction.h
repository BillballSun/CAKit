//
//  CAAccelerateFunction.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/9.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAAccelerateFunction : NSObject

- (instancetype)initWithInitialVelocity:(double)initalVelocity accelerate:(double)accelerate initialDistance:(double)initialDistance;

@property(readonly) double initialVelocity;

@property(readonly) double accelerate;

@property(readonly) double initialDistance;

@property(readonly, getter=hasExtream) BOOL extream;

@property(readonly) double extreamTime;

@property(readonly) double extreamDistance;

- (double)distanceAtTime:(double)time;

- (double)velocityAtTime:(double)time;

@end
