//
//  CAShakeAnimator.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/18.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAShakeAnimator.h"

@interface CAShakeAnimator ()
@property(readwrite, nonatomic) UIView *animatedView;
@property(readwrite, nonatomic) CGFloat duration;
@property(readwrite, nonatomic) CGFloat completeDuration;
@property(readwrite, nonatomic, getter=isPaused) BOOL paused;
@property(readwrite, nonatomic, getter=isCancelled) BOOL cancel;
@end

@implementation CAShakeAnimator

@synthesize
animatedView = _animatedView,
duration = _duration,
completeDuration = _completeDuration,
paused = _paused,
cancel = _cancel;

#pragma mark - Intialization

- (instancetype)initWithViscousDampingFunction:(CAViscousDampingFunction *)function
{
    if(self = [super init])
    {
        
    }
    return self;
}

- (instancetype)init { [self doesNotRecognizeSelector:_cmd]; return nil; }

+ (instancetype)animatorWithDefaultSettings
{
    return nil;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return nil;
}

#pragma mark - Animation

- (void)animateWithView:(__kindof UIView *)view
{
    
}

- (void)pauseAnimation
{
    
}

- (void)resumeAnimaton
{
    
}

- (void)cancelAnimation
{
    
}

@end
