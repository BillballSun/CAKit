//
//  CAVisualizedTouchView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVisualizedTouchView.h"
#import "CAVisualizedTouchWrapper/CAVisualizedTouchWrapper.h"
#import "CAVisualizedTouchWrapper/CAVisualizedTouchDisplayView/CAVisualizedTouchAppearance/CAVisualizedTouchAppearance.h"

@interface CAVisualizedTouchView ()

@property(readwrite, getter=isTouchVisible) BOOL touchVisible;
@property(nonatomic, assign, readwrite, getter=isAnimationEnabled) BOOL animationEnabled;
@property(weak) UIWindow<CAWindowEventObserving> *targetWindow;

@property(nonatomic) NSMutableArray<CAVisualizedTouchWrapper *> *touchWrapperArray;

@end

@implementation CAVisualizedTouchView

@synthesize maxTouchAmount = _maxTouchAmount;

- (BOOL)isUserInteractionEnabled
{
    return NO;
}

- (void)setUserInteractionEnabled:(BOOL)b {}

- (instancetype)initWithWindow:(CAWindow *)window
{
    if(window == nil || ![window isKindOfClass:CAWindow.class])
    {
        NSString *exceptionReason = [NSString stringWithFormat:@"- [CAVisualizedView initWithWindow:], passing %@ as argument", window];
        [[NSException exceptionWithName:@"Invalid Arguments"
                                 reason:exceptionReason
                               userInfo:nil] raise];
    }
    if(self = [super initWithFrame:window.bounds])
    {
        self.touchWrapperArray = [NSMutableArray array];
        self.userInteractionEnabled = NO;
        self.touchVisible = NO;
        self.animationEnabled = NO;
        self.maxTouchAmount = 1;
        self.hidden = NO;
        self.targetWindow = window;
        self.appearance = [[CAVisualizedTouchAppearance alloc] initWithType:CAVisualizedTouchAppearanceTypeSimpleCircle];
        [super setUserInteractionEnabled:NO];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(receiveKeyWindowActive:)
                                                   name:UIWindowDidBecomeKeyNotification
                                                 object:nil];
        [self tryToStartAnimation];
    }
    return self;
}

- (instancetype)initWithDelegatedWindow:(UIWindow<CAWindowEventObserving> *)window
{
    if(window == nil || ![window isKindOfClass:CAWindow.class])
    {
        NSString *exceptionReason = [NSString stringWithFormat:@"- [CAVisualizedView initWithWindow:], passing %@ as argument", window];
        [[NSException exceptionWithName:@"Invalid Arguments"
                                 reason:exceptionReason
                               userInfo:nil] raise];
    }
    if(self = [super initWithFrame:window.bounds])
    {
        self.touchWrapperArray = [NSMutableArray array];
        self.userInteractionEnabled = NO;
        self.touchVisible = NO;
        self.animationEnabled = NO;
        self.maxTouchAmount = 1;
        self.hidden = NO;
        self.targetWindow = window;
        self.appearance = [[CAVisualizedTouchAppearance alloc] initWithType:CAVisualizedTouchAppearanceTypeSimpleCircle];
        [super setUserInteractionEnabled:NO];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(receiveKeyWindowActive:)
                                                   name:UIWindowDidBecomeKeyNotification
                                                 object:nil];
        [self tryToStartAnimation];
    }
    return self;
}

- (void)tryToStartAnimation
{
    if(self.targetWindow.keyWindow && self.window!=nil && !self.touchHidden && !self.animationEnabled)
        [self beginAnimation];
}

- (void)tryToEndAnimation
{
    if(self.animationEnabled)
        [self endAnimation];
}

- (void)receiveKeyWindowResigned:(NSNotification *)notification
{
    if(notification.object == self.targetWindow)
        [self tryToEndAnimation];
}

- (void)receiveKeyWindowActive:(NSNotification *)notification
{
    if(notification.object == self.window)
        [self tryToStartAnimation];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if(newWindow == nil)
        [self tryToEndAnimation];
    else
        [self tryToStartAnimation];
}

- (void)setTouchHidden:(BOOL)touchHidden
{
    _touchHidden = touchHidden;
    if(touchHidden)
        [self tryToEndAnimation];
    else
        [self tryToStartAnimation];
}

- (void)beginAnimation
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receiveKeyWindowResigned:)
                                               name:UIWindowDidResignKeyNotification
                                             object:nil];
    [self.targetWindow addEventObserver:self selector:@selector(eventUpdated:)];
    self.animationEnabled = YES;
}

- (void)endAnimation
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(receiveKeyWindowActive:)
                                               name:UIWindowDidBecomeKeyNotification
                                             object:nil];
    [self.targetWindow removeEventObserver:self];
    self.animationEnabled = NO;
}

- (void)touchArrayCleanUp
{
    NSUInteger count = self.touchWrapperArray.count;
    for(NSInteger index = 0; index < count; index++)
        if(self.touchWrapperArray[index].touch == nil && self.touchWrapperArray[index].visualView == nil)
        {
            [self.touchWrapperArray[index].visualView removeFromSuperview];
            [self.touchWrapperArray removeObjectAtIndex:index];
            count--;
        }
        else
            index++;
}

- (BOOL)touchWrapperArrayHasTouch:(UITouch *)touch
{
    for (CAVisualizedTouchWrapper *eachWrapper in self.touchWrapperArray)
        if(eachWrapper.touch == touch)
            return YES;
    return NO;
}

- (void)touchWrapperArrayInsertNewTouch:(UITouch *)touch
{
    CAVisualizedTouchWrapper *wrapper = [[CAVisualizedTouchWrapper alloc] initWithTouch:touch];
    [self.touchWrapperArray addObject:wrapper];
}

- (BOOL)touchWrapperArrayhasSpace
{
    if(self.touchWrapperArray.count >= self.maxTouchAmount)
        return NO;
    else
        return YES;
}

- (void)eventUpdated:(UIEvent *)event
{
    [self touchArrayCleanUp];
    NSArray<UITouch *> *thisTimeTouches = event.allTouches.allObjects;
    for(UITouch *eachTouch in thisTimeTouches)
        if(![self touchWrapperArrayHasTouch:eachTouch] && [self touchWrapperArrayhasSpace])
            [self touchWrapperArrayInsertNewTouch:eachTouch];
    [self updateTouchesDisplay];
}

- (void)touchDisplayViewDidCompleteFinalizeAnimation:(CAVisualizedTouchDisplayView *)displayView
{
    NSUInteger count = self.touchWrapperArray.count;
    for(NSInteger index = 0; index < count; index++)
        if(self.touchWrapperArray[index].visualView == displayView)
        {
            [self.touchWrapperArray[index].visualView removeFromSuperview];
            [self.touchWrapperArray removeObjectAtIndex:index];
            return;
        }
    [[NSException exceptionWithName:@"Unexpected Status"
                             reason:@"- [CAVisualizedTouchDisplayView touchDisplayViewDidCompleteFinalizeAnimation:] unexpected display view"
                           userInfo:nil] raise];
}

- (void)updateTouchesDisplay
{
    for(CAVisualizedTouchWrapper *eachWrapper in self.touchWrapperArray)
        if(eachWrapper.touch == nil || eachWrapper.touch.phase == UITouchPhaseEnded || eachWrapper.touch.phase == UITouchPhaseCancelled)
        {
            if(!eachWrapper.visualView.finalizeStatus)
                [eachWrapper.visualView startFinalizedAnimation];
        }
        else if(eachWrapper.visualView == nil)
        {
            CGPoint locationInWindow = [eachWrapper.touch locationInView:self.targetWindow];
            CGFloat radius = eachWrapper.touch.majorRadius;
            CAVisualizedTouchDisplayView *displayView = [[CAVisualizedTouchDisplayView alloc] initWithFrame:self.bounds
                                                                                                 appearance:self.appearance
                                                                                                   position:locationInWindow
                                                                                                     radius:radius];
            displayView.delegate = self;
            [self addSubview:displayView];
            eachWrapper.visualView = displayView;
        }
        else
        {
            CGPoint locationInWindow = [eachWrapper.touch locationInView:self.targetWindow];
            CGFloat radius = eachWrapper.touch.majorRadius;
            
            eachWrapper.visualView.position = locationInWindow;
            eachWrapper.visualView.radius = radius;
        }
}

- (void)setMaxTouchAmount:(NSUInteger)maxTouchAmount
{
    if(self.maxTouchAmount >= 5)
        _maxTouchAmount = 5;
    else if(self.maxTouchAmount == 0)
        _maxTouchAmount = 1;
    else
        _maxTouchAmount = maxTouchAmount;
}

@end
