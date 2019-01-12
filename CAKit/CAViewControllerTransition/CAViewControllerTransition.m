//
//  CAViewControllerTransition.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/19.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAViewControllerTransition.h"

@interface CAViewControllerTransition ()
@property(readwrite) NSTimeInterval duration;
@property(copy, readwrite) CAViewControllerTransitionAnimationBlock animationBlock;
@property(readwrite, weak) id percentageObserver;
@property(readwrite) SEL percentageSelector;
@property(readwrite, getter=isAnimationInProcess) BOOL animationInProcess;
@property(readwrite, getter=isInteractive) BOOL interactive;
@property CADisplayLink *displayLink;
@property(weak) CALayer *conteinerLayer;
@property(readwrite) BOOL animationPaused;
@property(weak) id<UIViewControllerContextTransitioning> transitionContext;
@property(readwrite) BOOL animationHandleCompletion;
@end

@implementation CAViewControllerTransition

@synthesize withoutInteraction = _withoutInteraction, percentage = _percentage, duration = _duration, dismiss = _dismiss;

#pragma mark - Initialization & Configuration

- (instancetype)initWithDuration:(NSTimeInterval)duration
                       animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
       animationHandleCompletion:(BOOL)flag
                       isDismiss:(BOOL)dismiss
{
    if(self = [super init])
    {
        self.animationInProcess = NO;
        self.interactive = NO;
        self.autoCompleteTransitionWhenAnimationReachBegin = NO;
        self.autoCompleteTransitionWhenAnimationReachEnd = YES;
        self.wantAnimationPauseWhenHasInteractive = NO;
        self.withoutInteraction = YES;
        
        self.duration = duration;
        self.animationBlock = animation;
        self.animationHandleCompletion = flag;
        self.dismiss = dismiss;
    }
    return self;
}

- (void)configurationTransitionDuration:(NSTimeInterval)duration
                              animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
              animationHandleCompletion:(BOOL)flag
                              isDismiss:(BOOL)dismiss
{
    if(self.animationInProcess == YES) return;
    self.duration = duration;
    self.animationBlock = animation;
    self.animationHandleCompletion = flag;
    self.dismiss = dismiss;
}

- (void)configurationTransitionDuration:(NSTimeInterval)duration
                              animation:(nonnull CAViewControllerTransitionAnimationBlock)animation
              animationHandleCompletion:(BOOL)flag
{
    if(self.animationInProcess == YES) return;
    self.duration = duration;
    self.animationBlock = animation;
    self.animationHandleCompletion = flag;
}

- (void)setDismiss:(BOOL)dismiss
{
    if(self.animationInProcess == YES) return;
    _dismiss = dismiss;
}

- (void)observeAnimationPercentageChange:(nonnull id<NSObject>)percentageObserver selector:(SEL)percentageSelector
{
    if(self.animationInProcess == YES) return;
    self.percentageObserver = percentageObserver;
    self.percentageSelector = percentageSelector;
}

- (void)setWithoutInteraction:(BOOL)withoutInteraction
{
    if(self.animationInProcess == YES) return;
    _withoutInteraction = withoutInteraction;
}

#pragma mark - Interactive Configuration

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if(self.withoutInteraction)
    {
        [self.transitionContext finishInteractiveTransition];
        [self animateTransition:transitionContext];
    }
    else
    {
        self.conteinerLayer = transitionContext.containerView.layer;
        self.conteinerLayer.speed = 0;
        self.animationPaused = self.wantAnimationPauseWhenHasInteractive;
        self.transitionContext = transitionContext;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)displayLinkCallBack:(CADisplayLink *)displayLink
{
    if(!self.animationPaused)
    {
        if(self.percentage == 1.0 && !self.reversedAnimation && self.autoCompleteTransitionWhenAnimationReachEnd)
            [self completeTransiton];
        else if(self.percentage == 0.0 && self.reversedAnimation && self.autoCompleteTransitionWhenAnimationReachBegin)
            [self cancelTransiton];
        else if(!self.reversedAnimation)
            self.percentage += displayLink.duration / self.duration;
        else
            self.percentage -= displayLink.duration / self.duration;
    }
}

- (CGFloat)percentage
{
    if(!self.animationInProcess || self.withoutInteraction)
        return 1.0;
    return _percentage;
}

- (void)setPercentage:(CGFloat)percentage
{
    if(!self.animationInProcess || self.withoutInteraction)
        return;
    if(percentage < 0.0) percentage = 0.0;
    else if(percentage > 1.0) percentage = 1.0;
    if(_percentage != percentage)
    {
        _percentage = percentage;
        self.conteinerLayer.timeOffset = self.duration * _percentage;
        [self.transitionContext updateInteractiveTransition:_percentage];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if(self.percentageObserver!=nil && self.percentageSelector!=NULL)
            [self.percentageObserver performSelector:self.percentageSelector withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)pauseAnimation
{
    if(!self.animationInProcess || self.withoutInteraction)
        return;
    self.animationPaused = YES;
}

- (void)resumeAnimation
{
    if(!self.animationInProcess || self.withoutInteraction)
        return;
    self.animationPaused = NO;
}

- (void)completeTransiton
{
    [self.displayLink invalidate];
    self.conteinerLayer.speed = 1.0;
    CFTimeInterval pausedTime = [self.conteinerLayer timeOffset];
    self.conteinerLayer.timeOffset = 0.0;
    self.conteinerLayer.beginTime = 0.0; // Need to reset to 0 to avoid flickering :S
    CFTimeInterval timeSincePause = [self.conteinerLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.conteinerLayer.beginTime = timeSincePause;
    [self.transitionContext finishInteractiveTransition];
    if(!self.animationHandleCompletion) [self.transitionContext completeTransition:YES];
}

- (void)cancelTransiton
{
    [self.displayLink invalidate];
    self.conteinerLayer.speed = 1.0;
    CFTimeInterval pausedTime = [self.conteinerLayer timeOffset];
    self.conteinerLayer.timeOffset = 0.0;
    self.conteinerLayer.beginTime = 0.0; // Need to reset to 0 to avoid flickering :S
    CFTimeInterval timeSincePause = [self.conteinerLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.conteinerLayer.beginTime = timeSincePause;
    [self.transitionContext cancelInteractiveTransition];
    if(!self.animationHandleCompletion) [self.transitionContext completeTransition:NO];
}

#pragma mark - UIKit required protocol wrap (less useful)

- (CGFloat)completionSpeed { return 1.0; }

- (UIViewAnimationCurve)completionCurve { return UIViewAnimationCurveLinear; }

- (BOOL)wantsInteractiveStart { return YES; }

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext { return self.duration; }

/* animationInProccess lock here */

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{ self.animationInProcess = YES; self.animationBlock(self.dismiss, transitionContext); }

- (void)animationEnded:(BOOL)transitionCompleted {self.animationInProcess = NO;}

@end
