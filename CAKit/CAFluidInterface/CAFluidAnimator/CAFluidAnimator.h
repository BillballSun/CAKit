//
//  CAFluidAnimator.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAViscousDampingFunction.h"

@class CAFluidAnimator;

typedef void (^CAFluidAnimationBlockType)(CAFluidAnimator *animator);

typedef enum : NSUInteger {
    CAFluidAnimatorStatusReady,
    CAFluidAnimatorStatusInProcess,
    CAFluidAnimatorStatusComplete,
    CAFluidAnimatorStatusCancelled
} CAFluidAnimatorStatus;

@interface CAFluidAnimator : NSObject

- (instancetype)initWithDampingFunction:(CAViscousDampingFunction *)function;

- (void)beginAnimationWithBlock:(CAFluidAnimationBlockType)block;

/**
 It is valid to call at anytime, set to cancel status and any latter animation is not performed
 */
- (void)cancelAnimation;

/**
 It is only valid to call it when in complete and cancel status
 */
- (void)resetToReadyStatus;

/**
 You should not try to modify this function
 */
@property(readonly) CAViscousDampingFunction *dampingFunction;

@property(nonatomic, readonly) CAFluidAnimatorStatus status;

@property(assign, readonly) double percentage;

@property(readonly) double currentDistance;

@property(readonly) NSTimeInterval accumulatedTime;

@property(readonly) double currentEnergy;

/**
 Default to 5%, it throws exception when modifying not in ready status
 */
@property(assign, nonatomic) double energyRemainingPercentageToComplete;

@end
