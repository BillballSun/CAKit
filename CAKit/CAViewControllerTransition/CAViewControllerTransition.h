//
//  CAViewControllerTransition.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/19.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CAViewControllerTransitionAnimationBlock)(BOOL isDismiss, id<UIViewControllerContextTransitioning> transitionContext);

#pragma mark - Initalization & Configurate Transition

@interface CAViewControllerTransition : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

- (instancetype)initWithDuration:(NSTimeInterval)duration
                       animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
       animationHandleCompletion:(BOOL)flag
                       isDismiss:(BOOL)dismiss;

- (void)configurationTransitionDuration:(NSTimeInterval)duration
                              animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
              animationHandleCompletion:(BOOL)flag
                              isDismiss:(BOOL)dismiss;

- (void)configurationTransitionDuration:(NSTimeInterval)duration
                              animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
              animationHandleCompletion:(BOOL)flag;

/**
 Observation happens when percentageObserver is not nil and percentageSelector is not NULL
 @param percentageSelector
 it has and only has one parameter (CAViewControllerTransition *)
 @discussion
 calling when interactive animation in process
 */
- (void)observeAnimationPercentageChange:(nonnull id<NSObject>)percentageObserver selector:(SEL)percentageSelector;

#pragma mark - Information & Status

#pragma mark property needs configurated before animation

// set this property when animationInProcess has not effect
@property(nonatomic, getter=isDismiss) BOOL dismiss;

// setting this method is only valid when animationInProcess is NO, default is YES
@property(nonatomic, getter=isWithoutInteraction) BOOL withoutInteraction;

// default is NO
@property BOOL wantAnimationPauseWhenHasInteractive;

// default is YES, you can set it at anytime, set at the time animation already end will complete transition
@property BOOL autoCompleteTransitionWhenAnimationReachEnd;

// default is NO, you can set it at anytime, set at the time animation already reach begin at reverse will cancel transition
@property BOOL autoCompleteTransitionWhenAnimationReachBegin;

#pragma mark property configurated during animation

// access this property is only valid if withoutInteraction is NO, otherwise return 1.0 by default
@property(nonatomic) CGFloat percentage;

@property(getter=isReversedAnimation) BOOL reversedAnimation;

- (void)pauseAnimation;

- (void)resumeAnimation;

- (void)completeTransiton;

- (void)cancelTransiton;

#pragma mark readonly property

@property(readonly, getter=isInteractive) BOOL interactive;

@property(readonly) NSTimeInterval duration;

@property(copy, readonly) CAViewControllerTransitionAnimationBlock animationBlock;

@property(readonly, weak) id<NSObject> percentageObserver;

@property(readonly) SEL percentageSelector;

@property(readonly, getter=isAnimationInProcess) BOOL animationInProcess;

@property(readonly) BOOL animationPaused;

@property(readonly) BOOL animationHandleCompletion;

@end
