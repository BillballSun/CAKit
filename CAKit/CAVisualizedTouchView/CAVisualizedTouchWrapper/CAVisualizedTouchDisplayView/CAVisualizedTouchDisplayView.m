//
//  CAVisualizedTouchDisplayView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVisualizedTouchDisplayView.h"
#import "CAVisualizedTouchCircleView/CAVisualizedTouchCircleView.h"

#define CAVisualizedTouchCircleDefultMainAlpha 1.0
#define CAVisualizedTouchCircleDefultSecondaryAlpha 0.5
#define CAVisualizedTouchCircleDefultAdvancedRadius 10.0

@interface CAVisualizedTouchDisplayView ()

@property(readwrite, getter=isFinalizeStatus) BOOL finalizeStatus;
@property(readwrite, getter=isFinalizedAnimationComplete) BOOL finalizeAnimationComplete;
@property(readwrite) CAVisualizedTouchAppearance *appearance;

@property(readwrite) CAVisualizedTouchCircleView *mainView;
@property(readwrite) CAVisualizedTouchCircleView *secondaryView;

@property(class, readonly) NSString *sizeAnimationKey;
@property(class, readonly) NSString *finalizeAnimationKey;

@end

@implementation CAVisualizedTouchDisplayView

@synthesize position = _position,
            radius = _radius,
            advancedRadius = _advancedRadius;

@dynamic mainAlpha, secondaryAlpha;

+ (NSTimeInterval)commonRadiusAnimationTime:(CGFloat)fromR to:(CGFloat)toR { return fabs(toR - fromR) / 60.0; }

+ (NSTimeInterval)finalizeRadiusAnimationTime:(CGFloat)fromR to:(CGFloat)toR { return fabs(toR - fromR) / 100.0; }

+ (NSString *)sizeAnimationKey { return @"CAVisualizedTouchCircleViewSecondaryViewAnimationKey"; }

+ (NSString *)finalizeAnimationKey { return @"CAVisualizedTouchCircleViewFinalizeAnimationKey"; }

- (instancetype)initWithFrame:(CGRect)frame
                   appearance:(CAVisualizedTouchAppearance *)appearance
                     position:(CGPoint)position
                       radius:(CGFloat)radius
{
    if(self = [super initWithFrame:frame])
    {
        self.finalizeStatus = NO;
        self.finalizeAnimationComplete = NO;
        
        switch (appearance.type) {
            case CAVisualizedTouchAppearanceTypeSimpleCircle:
                self.mainView = [[CAVisualizedTouchCircleView alloc]
                                 initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)
                                 color:appearance.mainCircleColor];
                self.secondaryView = [[CAVisualizedTouchCircleView alloc]
                                      initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)
                                      color:appearance.secondaryCircleColor];
                break;
            default:
                [[NSException exceptionWithName:@"Invalid Argument"
                                         reason:@"- [CAVisualizedTouchDisplayView initWithFrame:appearance:position:radius:] illegal appearance"
                                       userInfo:nil] raise];
                break;
        }
        [self addSubview:self.secondaryView];
        [self addSubview:self.mainView];
        
        self.appearance = appearance;
        self.mainAlpha = CAVisualizedTouchCircleDefultMainAlpha;
        self.secondaryAlpha = CAVisualizedTouchCircleDefultSecondaryAlpha;
        [self firstTimeSetRadius:radius advanceRadius:CAVisualizedTouchCircleDefultAdvancedRadius];
        self.position = position;
    }
    return self;
}

- (void)firstTimeSetRadius:(CGFloat)radius advanceRadius:(CGFloat)advanceRadius
{
    _radius = radius;
    _advancedRadius = advanceRadius;
    
    self.mainView.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    self.secondaryView.bounds = CGRectMake(0, 0, (radius + self.advancedRadius) * 2, (self.radius + self.advancedRadius) * 2);
    
    CGRect preBounds = self.mainView.bounds;
    CGRect nowBounds = self.secondaryView.bounds;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.cumulative = NO;
    animation.additive = NO;
    animation.duration = [CAVisualizedTouchDisplayView commonRadiusAnimationTime:radius to:radius + self.advancedRadius];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGRect:preBounds];
    animation.toValue = [NSValue valueWithCGRect:nowBounds];
    
    [self.secondaryView.layer addAnimation:animation forKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
}

- (void)setRadius:(CGFloat)nowFirstRadius
{
    if(self.finalizeStatus == YES) return;
    if(self.radius == nowFirstRadius) return;
    
    CGFloat preFirstRadius = self.mainView.layer.presentationLayer.bounds.size.width/2;
    CGFloat preSecondaryRadius = self.secondaryView.layer.presentationLayer.bounds.size.width/2;
    
    CGRect preFirstBounds = self.mainView.layer.presentationLayer.bounds;
    CGRect preSecondBounds = self.secondaryView.layer.presentationLayer.bounds;
    
    _radius = nowFirstRadius;
    
    CGFloat nowSecondaryRadius = nowFirstRadius + self.advancedRadius;
    
    self.mainView.bounds = CGRectMake(0, 0, nowFirstRadius * 2, nowFirstRadius * 2);
    self.secondaryView.bounds = CGRectMake(0, 0, nowSecondaryRadius * 2, nowSecondaryRadius * 2);
    
    CGRect nowSecondBounds = self.secondaryView.bounds;
    CABasicAnimation *secondAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    secondAnimation.cumulative = NO;
    secondAnimation.additive = NO;
    secondAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    secondAnimation.fromValue = [NSValue valueWithCGRect:preSecondBounds];
    secondAnimation.toValue = [NSValue valueWithCGRect:nowSecondBounds];
    secondAnimation.duration = [CAVisualizedTouchDisplayView commonRadiusAnimationTime:preSecondaryRadius to:nowSecondaryRadius];
    
    CGRect nowFirstBounds = self.mainView.bounds;
    CABasicAnimation *firstAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    firstAnimation.cumulative = NO;
    firstAnimation.additive = NO;
    firstAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    firstAnimation.fromValue = [NSValue valueWithCGRect:preFirstBounds];
    firstAnimation.toValue = [NSValue valueWithCGRect:nowFirstBounds];
    firstAnimation.duration = [CAVisualizedTouchDisplayView commonRadiusAnimationTime:preFirstRadius to:nowFirstRadius];
    
    [self.secondaryView.layer removeAnimationForKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    [self.secondaryView.layer addAnimation:secondAnimation forKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    
    [self.mainView.layer removeAnimationForKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    [self.mainView.layer addAnimation:firstAnimation forKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
}

- (void)setAdvancedRadius:(CGFloat)advancedRadius
{
    if(self.finalizeStatus == YES) return;
    if(self.advancedRadius == advancedRadius) return;
    
    CGFloat preSecondaryRadius = self.radius + self.advancedRadius;
    CGRect preSecondBounds = self.secondaryView.layer.presentationLayer.bounds;
    
    _advancedRadius = advancedRadius;
    
    self.secondaryView.bounds = CGRectMake(0, 0, (self.radius + self.advancedRadius) * 2, (self.radius + self.advancedRadius) * 2);
    CGFloat nowSecondaryRadius = self.radius + self.advancedRadius;
    CGRect nowBounds = self.secondaryView.bounds;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.cumulative = NO;
    animation.additive = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSValue valueWithCGRect:preSecondBounds];
    animation.toValue = [NSValue valueWithCGRect:nowBounds];
    animation.duration = [CAVisualizedTouchDisplayView commonRadiusAnimationTime:preSecondaryRadius to:nowSecondaryRadius];
    
    [self.secondaryView.layer removeAnimationForKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    [self.secondaryView.layer addAnimation:animation forKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    
}

- (void)setPosition:(CGPoint)position
{
    if(self.finalizeStatus == YES) return;
    if(CGPointEqualToPoint(self.position, position)) return;
    
    self.mainView.center = position;
    self.secondaryView.center = position;
    
    _position = position;
}

- (void)setMainAlpha:(CGFloat)alpha
{
    if(self.finalizeStatus == YES) return;
    
    if(alpha < 0.0) alpha = 0.0;
    else if(alpha > 1.0) alpha = 1.0;
    self.mainView.alpha = alpha;
}

- (void)setSecondaryAlpha:(CGFloat)alpha
{
    if(self.finalizeStatus == YES) return;
    
    if(alpha > self.mainAlpha) return;
    if(alpha < 0.0) alpha = 0.0;
    else if(alpha > 1.0) alpha = 1.0;
    self.secondaryView.alpha = alpha;
}

- (CGFloat)mainAlpha
{
    return self.mainView.alpha;
}

- (CGFloat)secondaryAlpha
{
    return self.secondaryView.alpha;
}

- (CGFloat)mainCircleAlpha
{
    return self.mainView.alpha;
}

- (CGFloat)secondaryCircleAlpha
{
    return self.secondaryView.alpha;
}

- (void)startFinalizedAnimation
{
    if(self.finalizeStatus == YES) return;
    self.finalizeStatus = YES;
    
    CGRect preMainBounds = self.mainView.layer.presentationLayer.bounds;
    CGRect preSecdBounds = self.secondaryView.layer.presentationLayer.bounds;
    
    NSTimeInterval firstAnimationTime = [CAVisualizedTouchDisplayView finalizeRadiusAnimationTime:0 to:fabs(preSecdBounds.size.width/2 - preMainBounds.size.width/2)];
    NSTimeInterval secondAnimationTime = [CAVisualizedTouchDisplayView finalizeRadiusAnimationTime:(self.radius + self.advancedRadius)/2 to:0];
    
    CGFloat firstAnimationTimeFraction = (CGFloat)firstAnimationTime / (firstAnimationTime + secondAnimationTime);
    
    CGRect midBounds = CGRectMake(0, 0, (preMainBounds.size.width + preSecdBounds.size.width)/2, (preMainBounds.size.height + preSecdBounds.size.height)/2);
    CGRect finalBounds = CGRectMake(0, 0, 0, 0);
    
    CAMediaTimingFunction *easeInTimingFuc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAKeyframeAnimation *firstViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    firstViewAnimation.duration = firstAnimationTime + secondAnimationTime;
    firstViewAnimation.values = @[@(preMainBounds), @(midBounds), @(finalBounds)];
    firstViewAnimation.keyTimes = @[@0.0, @(firstAnimationTimeFraction), @1.0];
    firstViewAnimation.timingFunctions = @[easeInTimingFuc, easeInTimingFuc];
    firstViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    firstViewAnimation.delegate = self;
    
    CAKeyframeAnimation *secondViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    secondViewAnimation.duration = firstAnimationTime + secondAnimationTime;
    secondViewAnimation.values = @[@(preSecdBounds), @(midBounds), @(finalBounds)];
    secondViewAnimation.keyTimes = @[@0.0, @(firstAnimationTimeFraction), @1.0];
    secondViewAnimation.timingFunctions = @[easeInTimingFuc, easeInTimingFuc];
    secondViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    NSString *finalizeAnimationKey = CAVisualizedTouchDisplayView.finalizeAnimationKey;
    
    self.mainView.bounds = CGRectMake(0, 0, 0, 0);
    self.secondaryView.bounds = CGRectMake(0, 0, 0, 0);
    
    [self.mainView.layer removeAnimationForKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    [self.secondaryView.layer removeAnimationForKey:CAVisualizedTouchDisplayView.sizeAnimationKey];
    
    [self.mainView.layer addAnimation:firstViewAnimation forKey:finalizeAnimationKey];
    [self.secondaryView.layer addAnimation:secondViewAnimation forKey:finalizeAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.finalizeAnimationComplete = YES;
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(touchDisplayViewDidCompleteFinalizeAnimation:)])
        [self.delegate touchDisplayViewDidCompleteFinalizeAnimation:self];
}

@end
