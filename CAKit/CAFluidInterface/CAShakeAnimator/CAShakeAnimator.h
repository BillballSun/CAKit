//
//  CAShakeAnimator.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/18.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAViscousDampingFunction, CAShakeAnimator;

NS_ASSUME_NONNULL_BEGIN

@protocol CAShakeAnimatorDelegate <NSObject>
@optional

// No matter cancelled, or reached the end, it calls the method of the delegate
- (void)shakeAnimatorDidFinishAnimation:(CAShakeAnimator *)animator;

@end

@interface CAShakeAnimator : NSObject <NSCopying>

#pragma mark - Intialization

- (instancetype)initWithViscousDampingFunction:(CAViscousDampingFunction *)function;    /* designated intializer */

// This highly recommanded to use this function as result of lower memory cost, and highly performance
+ (instancetype)animatorWithDefaultSettings;

#pragma mark - Callbacks

@property(nonatomic) id<CAShakeAnimatorDelegate> delegate;

#pragma mark - Animation

- (void)animateWithView:(__kindof UIView *)view;

- (void)pauseAnimation;

- (void)resumeAnimaton;

- (void)cancelAnimation;

#pragma mark - information

@property(readonly, nonatomic) UIView *animatedView;

@property(readonly, nonatomic) CGFloat duration;

@property(readonly, nonatomic) CGFloat completeDuration;

@property(readonly, nonatomic, getter=isPaused) BOOL paused;

@property(readonly, nonatomic, getter=isCancelled) BOOL cancel;

@end

NS_ASSUME_NONNULL_END
