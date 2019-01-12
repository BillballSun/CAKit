//
//  CAFluidAnimator.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidAnimator.h"
#import "CAViscousDampingFunction+Percentage.h"

@interface CAFluidAnimator ()
@property(nonatomic, readwrite) CAFluidAnimatorStatus status;
@property(readwrite) CAViscousDampingFunction *dampingFunction;
@property(assign, readwrite) double percentage;
@property(copy, readwrite) CAFluidAnimationBlockType block;
@property(readwrite) CADisplayLink *displayLink;
@property(readwrite) NSTimeInterval accumulatedTime;
@property(readwrite) double currentDistance;
@property(strong) id keepSelfAliveWhileInAnimation;
@end

@implementation CAFluidAnimator

@synthesize energyRemainingPercentageToComplete = _energyRemainingPercentageToComplete;

- (instancetype)initWithDampingFunction:(CAViscousDampingFunction *)function
{
    if(self = [super init])
    {
        self.status = CAFluidAnimatorStatusReady;
        self.dampingFunction = function;
        self.percentage = 0.0;
        self.accumulatedTime = 0.0;
        self.energyRemainingPercentageToComplete = 0.05;
        self.currentDistance = function.initialDistance;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setEnergyRemainingPercentageToComplete:(double)energyRemainingPercentage
{
    if(self.status != CAFluidAnimatorStatusReady)
        [[NSException exceptionWithName:@"Invalid Operation"
                                 reason:@"Change energy lost percentage not in ready status"
                               userInfo:nil]
         raise];
    if(energyRemainingPercentage <= 0.0) energyRemainingPercentage = 0.01;
    else if(energyRemainingPercentage >= 1.0) energyRemainingPercentage = 0.99;
    _energyRemainingPercentageToComplete = energyRemainingPercentage;
}

- (double)currentEnergy
{
    if(self.status != CAFluidAnimatorStatusInProcess && self.status != CAFluidAnimatorStatusComplete)
        [[NSException exceptionWithName:@"Invalid Operation"
                                 reason:@"get current energy not in process or complete"
                               userInfo:nil]
         raise];
    return [self.dampingFunction energyAtTime:self.accumulatedTime];
}

- (void)beginAnimationWithBlock:(CAFluidAnimationBlockType)block
{
    if(self.status != CAFluidAnimatorStatusReady) return;
    self.keepSelfAliveWhileInAnimation = self;
    if(self.dampingFunction.initialVelocity == 0 && self.dampingFunction.initialDistance == 0)
    {
        self.percentage = 1.0;
        self.status = CAFluidAnimatorStatusComplete;
        block(self);
        self.keepSelfAliveWhileInAnimation = nil;
        return;
    }
    self.block = block;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.status = CAFluidAnimatorStatusInProcess;
    self.accumulatedTime = 0.0;
}

- (void)displayLinkCallBack:(CADisplayLink *)displayLink
{
    NSTimeInterval timeInterval = displayLink.duration;
    self.accumulatedTime += timeInterval;
    self.percentage = [self.dampingFunction equilibriumCompletePercentageAtTime:self.accumulatedTime];
    self.currentDistance = [self.dampingFunction distanceAtTime:self.accumulatedTime];
    double eneryPercentage = [self.dampingFunction energyPercentageAtTime:self.accumulatedTime];
    if(eneryPercentage <= self.energyRemainingPercentageToComplete)
    {
        self.status = CAFluidAnimatorStatusComplete;
        [self.displayLink invalidate];
    }
    self.block(self);
    if(self.status == CAFluidAnimatorStatusComplete)
        self.keepSelfAliveWhileInAnimation = nil;
}

- (void)cancelAnimation
{
    BOOL previousInProcess = self.status == CAFluidAnimatorStatusInProcess;
    self.status = CAFluidAnimatorStatusCancelled;
    if(previousInProcess)
    {
        [self.displayLink invalidate];
        self.block(self);
    }
    self.keepSelfAliveWhileInAnimation = nil;
}

- (void)resetToReadyStatus
{
    if(self.status == CAFluidAnimatorStatusCancelled || self.status == CAFluidAnimatorStatusComplete)
    {
        self.status = CAFluidAnimatorStatusReady;
        self.percentage = 0.0;
        self.currentDistance = self.dampingFunction.initialDistance;
        self.accumulatedTime = 0.0;
    }
}

@end
