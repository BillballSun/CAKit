//
//  CAScrollView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAScrollView.h"
#import "CAExtended.h"
#import "CARubberbandFunction.h"
#import "CAFluidAnimator.h"
#import "CAViscousDampingFunction.h"
#import "CAAccelerateFunction.h"

#define CAScrollViewScrollAnimationSpeed 600
#define CAScrollViewZoomAnimationSpeed 1
#define CAScrollViewCriticalDataSynchronizeSerialQueueLabel "CAScrollViewCriticalDataSynchronizeSerialQueue"

typedef enum : NSUInteger {
    CAScrollViewAxisX,
    CAScrollViewAxisY
} CAScrollViewAxis;

typedef enum : NSUInteger {
    CAScrollViewSideZero,
    CAScrollViewSideMax,
} CAScrollViewSide;

typedef struct pinchFinalizeAnimationData {
    CGPoint originalOffset;
    CGFloat originalScale;
    CGSize originalSize;
    CGRect origianlFrame;
    CGFloat targetScale;
    CGSize targetContentSize;
    CGRect targetViewTargetFrame;
    CGPoint unfixedTargetContentOffset;
    CGFloat duration;
} pinchFinalizeAnimationData;

const CGFloat CAScrollViewDecelerationRateNormal = 400;
const CGFloat CAScrollViewDecelerationRateFast = 700;
const CGFloat CAScrollViewDecelerationRateSlow = 200;

@interface CAScrollView ()
@property(nonatomic, readwrite) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, readwrite) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property(nonatomic, readwrite, getter=isZooming) BOOL zooming;

@property(nonatomic, readonly) CGPoint maxContentOffset;
@property(nonatomic, readonly) CGFloat maxDecelerateAxisVelocity;
@property(nonatomic, readonly) CGFloat rubberResistanceFactor;
@property(nonatomic, readonly) CGFloat decelerateVelocityMutiply;
@property(nonatomic, readonly, getter=isHorizontalScrollable) BOOL horizontalScrollable;
@property(nonatomic, readonly, getter=isVerticalScrollable) BOOL verticalScrollable;
@property(nonatomic, readonly) CGFloat pinchBounceMutiplyFactor;

@property(nonatomic) pinchFinalizeAnimationData pinchFinalizeData;
@property(nonatomic) CGFloat panFinalizeAnimationDuration;
@property(nonatomic, getter=isPanGRRecgnizing) BOOL panGRRecognizing;
@property(nonatomic, getter=isPinchnGRRecgnizing) BOOL pinchGRRecognizing;
@property(nonatomic) CGPoint originalOffset;
@property(nonatomic) CADisplayLink *panDisplayLink;
@property(nonatomic) CADisplayLink *pinchDisplayLink;
@property(nonatomic) CGFloat accumulatedDuration2;
@property(nonatomic) CGPoint panVelocity;
@property(nonatomic) CGFloat pinchDisplayLinkAccumulatedDuration;
@property(nonatomic) CGFloat panDisplayLinkAccumulatedDuration;
@property(nonatomic) BOOL verticalAnimationComplete;
@property(nonatomic) BOOL horizontalAnimationComplete;
@property(nonatomic) CAFluidAnimator *xPanAnimator;
@property(nonatomic) CAFluidAnimator *yPanAnimator;
@property(nonatomic) UIView *targetView;
@property(nonatomic) CGSize zoomOriginalSize;
@property(nonatomic) CGPoint zoomOriginalOffset;
@property(nonatomic) CGPoint zoomOriginalCenter;
@property(nonatomic) CGRect zoomTargetViewOriginalFrame;
@property(nonatomic) CGFloat zoomOriginalContentScale;
@property(nonatomic) CGFloat zoomOriginalFromScale;
@property(nonatomic) CGPoint zoomTargetCenter;
@property(class, nonatomic, readonly) CGFloat panDampingEnergyRemainPercentageToComplete;
@property(class, nonatomic, readonly) CGFloat scrollDampingEnergyRemainPercentageToComplete;

@end

@implementation CAScrollView

@synthesize
contentSize = _contentSize,
contentOffset = _contentOffset,
zoomScale = _zoomScale,
contentInset = _contentInset,
contentInsetAdjustmentBehavior = _contentInsetAdjustmentBehavior,
scrollIndicatorInsets = _scrollIndicatorInsets;

- (CGFloat)pinchBounceMutiplyFactor
{ return 5; }

- (CGFloat)pinchAlreadyBounceThanBounceExternalMutiplyFactorForOriginalScale:(CGFloat)original tryingTargetScale:(CGFloat)target minScale:(CGFloat)minScale maxScale:(CGFloat)maxScale
{
    const CGFloat increasedFactor = 2.0;
    const CGFloat preMutiplier = 5.0;
    
    if(original < minScale)
        return (minScale / (minScale - original)) * increasedFactor + preMutiplier;
    else if(original > maxScale)
        return ((original - maxScale) / maxScale) * increasedFactor + preMutiplier;
    return preMutiplier;
}

- (CGFloat)rubberResistanceFactor
{ return 0.75; }

- (CGFloat)maxDecelerateAxisVelocity
{ return 2000; }

- (CGFloat)decelerateVelocityMutiply
{ return 0.4; }

+ (CGFloat)panDampingEnergyRemainPercentageToComplete
{ return 0.0001; }

+ (CGFloat)scrollDampingEnergyRemainPercentageToComplete
{ return 0.001; }

- (NSTimeInterval)pinchFinalizeAnimationDurationFromScale:(CGFloat)from toScale:(CGFloat)to
{
    NSTimeInterval maxDuration = 0.5;
    NSTimeInterval minDuration = 0.1;
    NSTimeInterval tryDuration = fabs(to - from) / 2.2;
    return MIN(maxDuration, MAX(tryDuration, minDuration));
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
        [self additionalInitializationForCAScrollView];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
        [self additionalInitializationForCAScrollView];
    return self;
}

- (void)additionalInitializationForCAScrollView
{
    /* property configuration */
    
    _contentSize = CGSizeZero;
    _contentOffset = CGPointZero;
    [self setSubviewTransformWithContentOffset:_contentOffset];
    _zoomScale = 1;
    _contentInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        _contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    } else {
        // Fallback on earlier versions
    }
    _scrollIndicatorInsets = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.pagingEnabled = NO;
    self.bounces = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = YES;
    self.decelerationRate = CAScrollViewDecelerationRateNormal;
    self.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = YES;
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
    self.bouncesZoom = YES;
    self.zooming = NO;
    self.panGRRecognizing = NO;
    self.pinchGRRecognizing = NO;
    
    /* GR intialization */
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRCallbacks:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 2;
    self.pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGRCallbacks:)];
    self.panGestureRecognizer.delegate = self;
    self.pinchGestureRecognizer.delegate = self;
    // pinch added latter
    
    [self addGestureRecognizer:self.panGestureRecognizer];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    
    /* self view customization */
    self.multipleTouchEnabled = YES;
    self.exclusiveTouch = YES;
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
}

+ (dispatch_queue_t)synchronizeSerialQueue
{
    static dispatch_queue_t queue;
    if(queue == nil)
        queue = dispatch_queue_create(CAScrollViewCriticalDataSynchronizeSerialQueueLabel, DISPATCH_QUEUE_SERIAL);
    return queue;
}

- (void)panGRCallbacks:(UIPanGestureRecognizer *)panGR
{
    UIGestureRecognizerState panGRState = panGR.state;
    
    if(self.pinchGRRecognizing)
    {
        if(panGRState == UIGestureRecognizerStateEnded || panGRState == UIGestureRecognizerStateChanged)
            self.panGRRecognizing = NO;
        return;
    }
    
    CGPoint translate = [panGR translationInView:self];
    BOOL verticalPossible = self.verticalScrollable;
    BOOL horizontalPossible = self.horizontalScrollable;
    CGPoint maxContentOffset = self.maxContentOffset;
    
    if(panGRState ==  UIGestureRecognizerStateBegan || panGRState == UIGestureRecognizerStateChanged)
    {
        if(panGR.state == UIGestureRecognizerStateBegan)
        {
            self.panGRRecognizing = YES;
            [self.xPanAnimator cancelAnimation];
            [self.yPanAnimator cancelAnimation];
            [self.panDisplayLink invalidate];
            self.originalOffset = self.contentOffset;
        }
        CGFloat caculatedOffsetInX = 0;
        CGFloat caculatedOffsetInY = 0;
        
        if(verticalPossible)
        {
            CGFloat plainOffsetInY = self.originalOffset.y - translate.y;
            BOOL verticalBounces = self.bounces && self.alwaysBounceVertical;
            
            if(plainOffsetInY < 0)
            {
                if(verticalBounces)
                    caculatedOffsetInY = - [CARubberbandFunction positionOffsetForTouchOffset:- plainOffsetInY resistanceFactor:self.rubberResistanceFactor];
                else
                {
                    caculatedOffsetInY = 0;
                    translate.y = self.originalOffset.y;
                    [panGR setTranslation:translate inView:self];
                }
            }
            else if(plainOffsetInY > maxContentOffset.y)
            {
                if(verticalBounces)
                    caculatedOffsetInY = maxContentOffset.y + [CARubberbandFunction positionOffsetForTouchOffset:plainOffsetInY - maxContentOffset.y resistanceFactor:self.rubberResistanceFactor];
                else
                {
                    caculatedOffsetInY = maxContentOffset.y;
                    translate.y = self.originalOffset.y - maxContentOffset.y;
                    [panGR setTranslation:translate inView:self];
                }
            }
            else
                caculatedOffsetInY = plainOffsetInY;
        }
        
        if(horizontalPossible)
        {
            CGFloat plainOffsetInX = self.originalOffset.x - translate.x;
            BOOL horizontalBounces = self.bounces && self.alwaysBounceHorizontal;
            
            if(plainOffsetInX < 0)
            {
                if(horizontalBounces)
                    caculatedOffsetInX = - [CARubberbandFunction positionOffsetForTouchOffset: - plainOffsetInX resistanceFactor:self.rubberResistanceFactor];
                else
                {
                    caculatedOffsetInX = 0;
                    translate.x = self.originalOffset.x;
                    [panGR setTranslation:translate inView:self];
                }
            }
            else if(plainOffsetInX > maxContentOffset.x)
            {
                if(horizontalBounces)
                    caculatedOffsetInX = maxContentOffset.x + [CARubberbandFunction positionOffsetForTouchOffset:plainOffsetInX - maxContentOffset.x resistanceFactor:self.rubberResistanceFactor];
                else
                {
                    caculatedOffsetInX = maxContentOffset.x;
                    translate.x = self.originalOffset.x - maxContentOffset.x;
                    [panGR setTranslation:translate inView:self];
                }
            }
            else
                caculatedOffsetInX = plainOffsetInX;
        }
        [self forceContentOffset:CGPointMake(caculatedOffsetInX, caculatedOffsetInY)];
    }
    else if(panGRState == UIGestureRecognizerStateEnded || panGRState == UIGestureRecognizerStateCancelled)
    {
        self.panGRRecognizing = NO;
        CGPoint velocity = [panGR velocityInView:self];
        CGFloat mutiplier = self.decelerateVelocityMutiply;
        velocity.x = copysign(MIN(self.maxDecelerateAxisVelocity, fabs(velocity.x * mutiplier)), velocity.x);
        velocity.y = copysign(MIN(self.maxDecelerateAxisVelocity, fabs(velocity.y * mutiplier)), velocity.y);
        self.panVelocity = velocity;
        self.panDisplayLinkAccumulatedDuration = 0;
        self.panFinalizeAnimationDuration = sqrt(velocity.x * velocity.x + velocity.y * velocity.y) / self.decelerationRate;
        self.originalOffset = self.contentOffset;
        
        if(verticalPossible)
            self.verticalAnimationComplete = NO;
        else
            self.verticalAnimationComplete = YES;
        if(horizontalPossible)
            self.horizontalAnimationComplete = NO;
        else
            self.horizontalAnimationComplete = YES;
        self.panDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(panDisplayLinkCallBack:)];
        [self.panDisplayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if((gestureRecognizer == self.panGestureRecognizer && otherGestureRecognizer == self.pinchGestureRecognizer) ||
       (gestureRecognizer == self.pinchGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer))
        return YES;
    return NO;
}

- (void)panDisplayLinkCallBack:(CADisplayLink *)displayLink
{
    CGPoint currentOffset = self.contentOffset;
    CGPoint maxContentOffset = self.maxContentOffset;
    CGPoint velocity = self.panVelocity;
    CGFloat displayLinkDuration = displayLink.duration;
    CGFloat currentAccumulatedDuration = (self.panDisplayLinkAccumulatedDuration += displayLinkDuration);
    CGFloat animationDuration = self.panFinalizeAnimationDuration;
    BOOL horizontalBounces = self.bounces && self.alwaysBounceHorizontal;
    BOOL verticalBounces = self.bounces && self.alwaysBounceVertical;
    
    if(!self.horizontalAnimationComplete)    /* It does not mean animation complete, it means its configuration is done */
    {
        if(currentOffset.x < 0)
        {
            if(horizontalBounces)
                [self animatedSideBounceAtAxis:CAScrollViewAxisX towards:CAScrollViewSideZero velocity:0 position:currentOffset.x increasePanAnimationInProcess:YES];
            else
                [self forceContentOffsetInX:0];
            self.horizontalAnimationComplete = YES;
        }
        else if(currentOffset.x > maxContentOffset.x)
        {
            if(horizontalBounces)
                [self animatedSideBounceAtAxis:CAScrollViewAxisX towards:CAScrollViewSideMax velocity:0 position:currentOffset.x increasePanAnimationInProcess:YES];
            else
                [self forceContentOffsetInX:maxContentOffset.x];
            self.horizontalAnimationComplete = YES;
        }
        else if(velocity.x != 0 && currentAccumulatedDuration < animationDuration)
        {
            CGFloat currentVelocity = velocity.x * (1 - currentAccumulatedDuration / animationDuration);
            CGFloat currentDistance = self.originalOffset.x - (currentVelocity + velocity.x) * currentAccumulatedDuration / 2;
            
            if(currentDistance < 0)
            {
                if(horizontalBounces)
                    [self animatedSideBounceAtAxis:CAScrollViewAxisX towards:CAScrollViewSideZero velocity:-currentVelocity position:0 increasePanAnimationInProcess:YES];
                else
                    [self forceContentOffsetInX:0];
                self.horizontalAnimationComplete = YES;
            }
            else if(currentDistance > maxContentOffset.x)
            {
                if(horizontalBounces)
                    [self animatedSideBounceAtAxis:CAScrollViewAxisX towards:CAScrollViewSideMax velocity:-currentVelocity position:maxContentOffset.x increasePanAnimationInProcess:YES];
                else
                    [self forceContentOffsetInX:maxContentOffset.x];
                self.horizontalAnimationComplete = YES;
            }
            else
                [self forceContentOffsetInX:currentDistance];
        }
        else
            self.horizontalAnimationComplete = YES;
    }
    
    if(!self.verticalAnimationComplete)
    {
        if(currentOffset.y < 0)
        {
            if(verticalBounces)
                [self animatedSideBounceAtAxis:CAScrollViewAxisY towards:CAScrollViewSideZero velocity:0 position:currentOffset.y increasePanAnimationInProcess:YES];
            else
                [self forceContentOffsetInY:0];
            self.verticalAnimationComplete = YES;
        }
        else if(currentOffset.y > maxContentOffset.y)
        {
            if(verticalBounces)
                [self animatedSideBounceAtAxis:CAScrollViewAxisY towards:CAScrollViewSideMax velocity:0 position:currentOffset.y increasePanAnimationInProcess:YES];
            else
                [self forceContentOffsetInY:maxContentOffset.y];
            self.verticalAnimationComplete = YES;
        }
        else if(velocity.y != 0 && currentAccumulatedDuration < animationDuration)
        {
            CGFloat currentVelocity = velocity.y * (1 - currentAccumulatedDuration / animationDuration);
            CGFloat currentDistance = self.originalOffset.y - (currentVelocity + velocity.y) * currentAccumulatedDuration / 2;
            
            if(currentDistance < 0)
            {
                if(verticalBounces)
                    [self animatedSideBounceAtAxis:CAScrollViewAxisY towards:CAScrollViewSideZero velocity:-currentVelocity position:0 increasePanAnimationInProcess:YES];
                else
                    [self forceContentOffsetInY:0];
                self.verticalAnimationComplete = YES;
            }
            else if(currentDistance > maxContentOffset.y)
            {
                if(verticalBounces)
                    [self animatedSideBounceAtAxis:CAScrollViewAxisY towards:CAScrollViewSideMax velocity:-currentVelocity position:maxContentOffset.y increasePanAnimationInProcess:YES];
                else
                    [self forceContentOffsetInY:maxContentOffset.y];
                self.verticalAnimationComplete = YES;
            }
            else
                [self forceContentOffsetInY:currentDistance];
        }
        else
            self.verticalAnimationComplete = YES;
    }
    else
        self.verticalAnimationComplete = YES;
    
    if(self.horizontalAnimationComplete && self.verticalAnimationComplete)
        [self.panDisplayLink invalidate];
}

- (void)animatedSideBounceAtAxis:(CAScrollViewAxis)axis
                         towards:(CAScrollViewSide)side
                        velocity:(CGFloat)velocity
                        position:(CGFloat)position
                 increasePanAnimationInProcess:(BOOL)increasePanAnimationInProcess
{
    CGPoint maxContentOffset = self.maxContentOffset;
    CGFloat thisAxisMaxOffset = (axis == CAScrollViewAxisX) ? maxContentOffset.x : maxContentOffset.y;
    CAViscousDampingFunction *function = [CAScrollView panDampingFunction];
    function.initialDistance = (side == CAScrollViewSideZero) ? position : position - thisAxisMaxOffset;
    function.initialVelocity = velocity;
    CAFluidAnimator *animator = [[CAFluidAnimator alloc] initWithDampingFunction:function];
    if(axis == CAScrollViewAxisX)
        self.xPanAnimator = animator;
    else
        self.yPanAnimator = animator;
    animator.energyRemainingPercentageToComplete = CAScrollView.panDampingEnergyRemainPercentageToComplete;
    [animator beginAnimationWithBlock:^(CAFluidAnimator *animator){
        CAFluidAnimatorStatus status = animator.status;
        if(status == CAFluidAnimatorStatusInProcess)
        {
            CGFloat currentDistance = animator.currentDistance;
            if(axis == CAScrollViewAxisX)
                [self forceContentOffsetInX:currentDistance + ((side == CAScrollViewSideZero) ? 0 : thisAxisMaxOffset)];
            else
                [self forceContentOffsetInY:currentDistance + ((side == CAScrollViewSideZero) ? 0 : thisAxisMaxOffset)];
        }
        else if(status == CAFluidAnimatorStatusComplete)
        {
            if(axis == CAScrollViewAxisX)
                [self forceContentOffsetInX:((side == CAScrollViewSideZero) ? 0 : thisAxisMaxOffset)];
            else
                [self forceContentOffsetInY:((side == CAScrollViewSideZero) ? 0 : thisAxisMaxOffset)];
        }
        else if(status == CAFluidAnimatorStatusCancelled)
        {
            if(axis == CAScrollViewAxisX)
            {
                if(side == CAScrollViewSideZero)
                {
                    if(self.contentOffset.x < 0 || self.contentOffset.x > thisAxisMaxOffset)
                        [self forceContentOffsetInX:0];
                }
                else
                {
                    if(self.contentOffset.x < 0 || self.contentOffset.x > thisAxisMaxOffset)
                        [self forceContentOffsetInX:thisAxisMaxOffset];
                }
            }
            else
            {
                if(side == CAScrollViewSideZero)
                {
                    if(self.contentOffset.y < 0 || self.contentOffset.y > thisAxisMaxOffset)
                        [self forceContentOffsetInY:0];
                }
                else
                {
                    if(self.contentOffset.y < 0 || self.contentOffset.y > thisAxisMaxOffset)
                        [self forceContentOffsetInY:thisAxisMaxOffset];
                }
            }
        }
    }];
}

+ (CAViscousDampingFunction *)panDampingFunction
{
    const CGFloat mass = 1, spring = 200, coefficient = sqrt(4 * mass * spring);
    return [[CAViscousDampingFunction alloc] initWithMass:mass spring:spring coefficient:coefficient];
}

- (void)setContentSize:(CGSize)contentSize { [self setContentSize:contentSize animated:NO]; }

- (void)setContentOffset:(CGPoint)contentOffset { [self setContentOffset:contentOffset animated:NO]; }

- (void)setZoomScale:(CGFloat)zoomScale { [self setZoomScale:zoomScale animated:NO]; }

- (void)setContentSize:(CGSize)contentSize animated:(BOOL)animated
{
    _contentSize = contentSize;
    [self fixContentOffsetAfterSizeChangeWithAnimation:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    CGPoint maxOffset = self.maxContentOffset;
    CGPoint realOffset = CGPointMake(MIN(maxOffset.x, contentOffset.x), MIN(maxOffset.y, contentOffset.y));
    if(animated)
    {
        CGPoint currentOffset = self.contentOffset;
        CGFloat distance = sqrt(pow(realOffset.x - currentOffset.x, 2) + pow(realOffset.y - currentOffset.y, 2));
        NSTimeInterval duration = distance / CAScrollViewScrollAnimationSpeed;
        [UIView animateWithDuration:duration animations:^{
            [self setSubviewTransformWithContentOffset:realOffset];
        }];
    }
    else
        [self setSubviewTransformWithContentOffset:realOffset];
    _contentOffset = realOffset;
}

- (void)forceContentOffset:(CGPoint)contentOffset
{
    [self setSubviewTransformWithContentOffset:contentOffset];
    _contentOffset = contentOffset;
}

- (void)forceContentOffsetInX:(CGFloat)xOffset
{
    CGPoint contentOffset = _contentOffset;
    contentOffset.x = xOffset;
    [self setSubviewTransformWithContentOffset:contentOffset];
    _contentOffset = contentOffset;
}

- (void)forceContentOffsetInY:(CGFloat)yOffset
{
    CGPoint contentOffset = _contentOffset;
    contentOffset.y = yOffset;
    [self setSubviewTransformWithContentOffset:contentOffset];
    _contentOffset = contentOffset;
}

- (CGPoint)maxContentOffset
{
    CGFloat maxWidth = self.contentSize.width - self.width;
    CGFloat maxHeight = self.contentSize.height - self.height;
    UIEdgeInsets adjustedInsert = self.adjustedContentInset;
    maxWidth += adjustedInsert.left + adjustedInsert.right;
    maxHeight += adjustedInsert.top + adjustedInsert.bottom;
    if(maxWidth < 0) maxWidth = 0;
    if(maxHeight < 0) maxHeight = 0;
    return CGPointMake(maxWidth, maxHeight);
}

- (BOOL)isHorizontalScrollable
{
    UIEdgeInsets adjusted = self.adjustedContentInset;
    return self.contentSize.width > (self.width - adjusted.left - adjusted.right);
}

- (BOOL)isVerticalScrollable
{
    UIEdgeInsets adjusted = self.adjustedContentInset;
    return self.contentSize.height > (self.height - adjusted.top - adjusted.bottom);
}

- (void)fixContentOffsetAfterSizeChangeWithAnimation:(BOOL)flag
{
    CGPoint maxOffset = self.maxContentOffset;
    CGPoint currentOffset = self.contentOffset;
    CGPoint realOffset = CGPointMake(MIN(maxOffset.x, currentOffset.x), MIN(maxOffset.y, currentOffset.y));
    if(realOffset.x < 0) realOffset.x = 0;
    if(realOffset.y < 0) realOffset.y = 0;
    [self setContentOffset:realOffset animated:flag];
}

- (void)setZoomScale:(CGFloat)zoomScale animated:(BOOL)animated
{
    zoomScale = MIN(zoomScale, self.maximumZoomScale);
    zoomScale = MAX(zoomScale, self.minimumZoomScale);
    CGFloat currentScale = self.zoomScale;
    if(zoomScale == currentScale) return;
    
    UIView *targetView;
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(viewForZoomingInCAScrollView:)])
        targetView = [self.delegate viewForZoomingInCAScrollView:self];
    else
        targetView = nil;
    
    CGFloat relativeScale = zoomScale / currentScale;
    
    CGSize newContentSize = self.contentSize;
    newContentSize.width *= relativeScale;
    newContentSize.height *= relativeScale;
    
    UIEdgeInsets adjusted = self.adjustedContentInset;
    
    CGPoint newContentOffset = self.contentOffset;
    newContentOffset.x *= relativeScale;
    newContentOffset.y *= relativeScale;
    newContentOffset.x += (self.width - adjusted.left - adjusted.right) / 2 * (relativeScale - 1);
    newContentOffset.y += (self.height - adjusted.top - adjusted.bottom) / 2 * (relativeScale - 1);
    newContentOffset = [CAScrollView fixedContentOffset:newContentOffset contentSize:newContentSize frameSize:self.size adjustedInsert:self.adjustedContentInset];
    
    CGRect newframe = CGRectZero;
    if(targetView != nil)
    {
        newframe = targetView.frame;
        newframe.size.width *= relativeScale;
        newframe.size.height *= relativeScale;
        newframe.origin.x *= relativeScale;
        newframe.origin.y *= relativeScale;
    }
    
    _contentOffset = newContentOffset;
    _contentSize = newContentSize;
    
    
    NSTimeInterval duration = relativeScale / CAScrollViewZoomAnimationSpeed;
    
    [UIView animateWithDuration:duration animations:^{
        if(targetView!=nil) targetView.frame = newframe;
        [self setSubviewTransformWithContentOffset:newContentOffset];
    }];
    
    _zoomScale = zoomScale;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CAScrollViewDidZoom:)])
        [self.delegate CAScrollViewDidZoom:self];
}

+ (CGPoint)fixedContentOffset:(CGPoint)offset contentSize:(CGSize)contentSize frameSize:(CGSize)frameSize adjustedInsert:(UIEdgeInsets)insert
{
    CGFloat maxWidth = contentSize.width - frameSize.width;
    CGFloat maxHeight = contentSize.height - frameSize.height;
    maxWidth += insert.left + insert.right;
    maxHeight += insert.top + insert.bottom;
    if(maxWidth < 0) maxWidth = 0;
    if(maxHeight < 0) maxHeight = 0;
    return CGPointMake(MAX(MIN(maxWidth, offset.x), 0), MAX(MIN(maxHeight, offset.y), 0));
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if(!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset))
    {
        _contentInset = contentInset;
        [self updateSubviewTransformBasedOnAdjustedContentInsetDidChange];
    }
}

- (UIEdgeInsets)adjustedContentInset
{
    UIEdgeInsets contentInsert = self.contentInset;
    UIEdgeInsets safeAreaInsert = UIEdgeInsetsZero;
    UIScrollViewContentInsetAdjustmentBehavior behavior = self.contentInsetAdjustmentBehavior;
    
    if(behavior == UIScrollViewContentInsetAdjustmentAutomatic || behavior == UIScrollViewContentInsetAdjustmentAlways)
        safeAreaInsert = self.safeAreaInsets;
    else if(behavior == UIScrollViewContentInsetAdjustmentScrollableAxes)
    {
        UIEdgeInsets safeArea = self.safeAreaInsets;
        if(self.contentSize.width > self.width)
        {
            safeAreaInsert.left = safeArea.left;
            safeAreaInsert.right = safeArea.right;
        }
        if(self.contentSize.height > self.height)
        {
            safeAreaInsert.top = safeArea.top;
            safeAreaInsert.bottom = safeArea.bottom;
        }
    }
    return UIEdgeInsetsMake(contentInsert.top + safeAreaInsert.top, contentInsert.left + safeAreaInsert.left, contentInsert.bottom + safeAreaInsert.bottom, contentInsert.right + safeAreaInsert.right);
}

- (void)safeAreaInsetsDidChange
{
    [self updateSubviewTransformBasedOnAdjustedContentInsetDidChange];
}

- (void)adjustedContentInsetDidChange
{
    
}

- (void)updateSubviewTransformBasedOnAdjustedContentInsetDidChange
{
    [self setSubviewTransformWithContentOffset:self.contentOffset];
    [self adjustedContentInsetDidChange];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CASrollViewDidChangeAdjustedContentInset:)])
        [self.delegate CASrollViewDidChangeAdjustedContentInset:self];
}

- (void)setSubviewTransformWithContentOffset:(CGPoint)offset
{
//    CGPoint previousOffset = _contentOffset;
//    if(sqrt(pow(offset.x - previousOffset.x, 2) + pow(offset.y - previousOffset.y, 2)) > 50)
//        raise(SIGINT);
    UIEdgeInsets adjustedInsert = self.adjustedContentInset;
    self.layer.sublayerTransform = CATransform3DMakeTranslation(adjustedInsert.left - offset.x, adjustedInsert.top - offset.y, 0);
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CAScrollViewDidScroll:)])
        [self.delegate CAScrollViewDidScroll:self];
}

- (void)flashScrollIndicators
{
    
}

- (void)zoomToRect:(CGRect)rect
          animated:(BOOL)animated
{
    CGSize contentSize = self.contentSize;
    CGRect targetRect = CGRectContainRect((CGRect){CGPointZero, contentSize}, rect);
    if(!CGRectEqualToRect(targetRect, CGRectZero))
    {
        UIEdgeInsets adjusted = self.adjustedContentInset;
        CGSize displaySize = CGSizeMake(self.width - adjusted.left - adjusted.right,
                                        self.height - adjusted.top - adjusted.bottom);
        CGFloat tryRelativeScale = 0;
        if(targetRect.size.height * (displaySize.width / targetRect.size.width) <= displaySize.height)
            tryRelativeScale = displaySize.width / targetRect.size.width;
        else
            tryRelativeScale = displaySize.height / targetRect.size.height;
        CGFloat zoomScale = self.zoomScale;
        CGFloat relativeScale = MIN(MAX(tryRelativeScale * zoomScale, self.minimumZoomScale), self.maximumZoomScale) / zoomScale;
        
        CGPoint targetOffset = CGPointMake(CGRectGetMidX(targetRect) * relativeScale - displaySize.width / 2, CGRectGetMidY(targetRect) * relativeScale - displaySize.height / 2);
        CGSize targetSize = CGSizeMake(contentSize.width * relativeScale, contentSize.height * relativeScale);
        CGFloat targetZoomScale = zoomScale * relativeScale;
        
        UIView *targetView;
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
            targetView = [self.delegate viewForZoomingInCAScrollView:self];
        
        CGRect targetViewFrame = CGRectZero;
        if(targetView != nil)
        {
            CGRect frame = targetView.frame;
            targetViewFrame = CGRectMake(frame.origin.x * relativeScale, frame.origin.y * relativeScale, frame.size.width * relativeScale, frame.size.height * relativeScale);
        }
        if(animated)
        {
            [self pinchFinalizeAnimationWithOriginalOffset:self.contentOffset
                                             originalScale:zoomScale
                                              originalSize:contentSize
                                                targetView:targetView
                                             originalFrame:targetView.frame
                                               targetScale:targetZoomScale
                                         targetContentSize:targetSize
                                     targetViewTargetFrame:targetViewFrame
                                unfixedTargetContentOffset:targetOffset];
        }
        else
        {
            _contentSize = targetSize;
            _zoomScale = targetZoomScale;
            [self forceContentOffset:targetOffset];
            if(targetView != nil)
                targetView.frame = targetViewFrame;
        }
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CAScrollViewDidZoom:)])
            [self.delegate CAScrollViewDidZoom:self];
    }
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint fakeOffset = CGPointMake(center.x - self.width / 2, center.y - self.height / 2);
    [self setContentOffset:fakeOffset animated:animated];
}

- (void)pinchFinalizeAnimationWithOriginalOffset:(CGPoint)originalOffset
                                   originalScale:(CGFloat)originalScale
                                    originalSize:(CGSize)originalSize
                                      targetView:(UIView *)targetView
                                   originalFrame:(CGRect)origianlFrame
                                     targetScale:(CGFloat)targetScale
                               targetContentSize:(CGSize)targetContentSize
                           targetViewTargetFrame:(CGRect)targetViewTargetFrame
                      unfixedTargetContentOffset:(CGPoint)unfixedTargetContentOffset
{
    NSTimeInterval duration = [self pinchFinalizeAnimationDurationFromScale:originalScale toScale:targetScale];
    pinchFinalizeAnimationData data = {
        .originalOffset = originalOffset,
        .originalScale = originalScale,
        .originalSize = originalSize,
        .origianlFrame = origianlFrame,
        .targetScale = targetScale,
        .targetContentSize = targetContentSize,
        .targetViewTargetFrame = targetViewTargetFrame,
        .unfixedTargetContentOffset = unfixedTargetContentOffset,
        .duration = duration
    };
    self.targetView = targetView;
    self.pinchFinalizeData = data;
    self.pinchDisplayLinkAccumulatedDuration = 0;
    self.userInteractionEnabled = NO;   /* block interaction */
    
    self.pinchDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(pinchDisplayLinkCallback:)];
    [self.pinchDisplayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)pinchDisplayLinkCallback:(CADisplayLink *)displayLink
{
    CGFloat accumulatedDuration = (self.pinchDisplayLinkAccumulatedDuration += displayLink.duration);
    pinchFinalizeAnimationData data = self.pinchFinalizeData;
    
    if(accumulatedDuration < data.duration)
    {
        CGFloat percentage = accumulatedDuration / data.duration;
        CGSize currentContentSize = CGSizeMake(data.originalSize.width + (data.targetContentSize.width - data.originalSize.width) * percentage,
                                               data.originalSize.height + (data.targetContentSize.height - data.originalSize.height) * percentage);
        CGRect currentFrame = CGRectMake(data.origianlFrame.origin.x + (data.targetViewTargetFrame.origin.x - data.origianlFrame.origin.x) * percentage,
                                         data.origianlFrame.origin.y + (data.targetViewTargetFrame.origin.y - data.origianlFrame.origin.y) * percentage,
                                         data.origianlFrame.size.width + (data.targetViewTargetFrame.size.width - data.origianlFrame.size.width) * percentage,
                                         data.origianlFrame.size.height + (data.targetViewTargetFrame.size.height - data.origianlFrame.size.height) * percentage);
        CGPoint currentOffset = CGPointMake(data.originalOffset.x + (data.unfixedTargetContentOffset.x - data.originalOffset.x) * percentage,
                                            data.originalOffset.y + (data.unfixedTargetContentOffset.y - data.originalOffset.y) * percentage);
        CGFloat currentScale = data.originalScale + (data.targetScale - data.originalScale) * percentage;
        
        currentOffset = [CAScrollView fixedContentOffset:currentOffset contentSize:currentContentSize frameSize:self.size adjustedInsert:self.adjustedContentInset];
        _contentSize = currentContentSize;
        if(self.targetView != nil) self.targetView.frame = currentFrame;
        _zoomScale = currentScale;
        [self forceContentOffset:currentOffset];
    }
    else
    {
        _contentSize = data.targetContentSize;
        if(self.targetView != nil) self.targetView.frame = data.targetViewTargetFrame;
        _zoomScale = data.targetScale;
        [self forceContentOffset:[CAScrollView fixedContentOffset:data.unfixedTargetContentOffset contentSize:data.targetContentSize frameSize:self.size adjustedInsert:self.adjustedContentInset]];
        [displayLink invalidate];
        self.userInteractionEnabled = YES; /* enable again */
    }
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CAScrollViewDidZoom:)])
        [self.delegate CAScrollViewDidZoom:self];
}

- (void)pinchGRCallbacks:(UIPinchGestureRecognizer *)pinchGR
{
    UIGestureRecognizerState state = pinchGR.state;
    NSUInteger numberOfTouches = pinchGR.numberOfTouches;
    
    if(numberOfTouches <= 1 || state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
        if(state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
        {
            self.zooming = NO;
            self.pinchGRRecognizing = NO;
            
            CGFloat originalScale = self.zoomScale;
            CGFloat targetScale = MIN(MAX(originalScale, self.minimumZoomScale), self.maximumZoomScale);
            CGSize originalSize = self.contentSize;
            CGPoint originalOffset = self.contentOffset;
            CGPoint originalCenter = [pinchGR locationInView:self];
            
            CGFloat relativeScale = targetScale / originalScale;
            
            CGSize targetContentSize = originalSize;
            targetContentSize.width *= relativeScale;
            targetContentSize.height *= relativeScale;
            
            UIEdgeInsets adjusted = self.adjustedContentInset;
            
            CGPoint targetContentOffset = originalOffset;
            targetContentOffset.x *= relativeScale;
            targetContentOffset.y *= relativeScale;
            targetContentOffset.x += originalCenter.x * (relativeScale - 1);
            targetContentOffset.y += originalCenter.y * (relativeScale - 1);
            targetContentOffset.x += adjusted.left * (1 - relativeScale);
            targetContentOffset.y += adjusted.top * (1 - relativeScale);
            
            UIView *targetView = self.targetView;
            CGRect targetViewTargetFrame = CGRectZero;
            if(targetView != nil)
            {
                targetViewTargetFrame = self.targetView.frame;
                targetViewTargetFrame.size.width *= relativeScale;
                targetViewTargetFrame.size.height *= relativeScale;
                targetViewTargetFrame.origin.x *= relativeScale;
                targetViewTargetFrame.origin.y *= relativeScale;
            }
            
            [self pinchFinalizeAnimationWithOriginalOffset:originalOffset
                                             originalScale:originalScale
                                              originalSize:originalSize
                                                targetView:targetView
                                             originalFrame:targetView != nil ? targetView.frame : CGRectZero
                                               targetScale:targetScale
                                         targetContentSize:targetContentSize
                                     targetViewTargetFrame:targetViewTargetFrame
                                unfixedTargetContentOffset:targetContentOffset];
        }
        else
        {
            if(self.zooming)
            {
                self.zooming = NO;
                self.zoomOriginalCenter = [pinchGR locationInView:self];
                self.zoomOriginalOffset = self.contentOffset;
            }
            CGPoint originalCenter = self.zoomOriginalCenter;
            CGPoint currentCenter = [pinchGR locationInView:self];
            CGPoint originalOffset = self.zoomOriginalOffset;
            CGPoint caculatedOffset = CGPointMake(originalOffset.x - (currentCenter.x - originalCenter.x), originalOffset.y - (currentCenter.y - originalCenter.y));
            [self forceContentOffset:caculatedOffset];
        }
    }
    else
    {
        self.zoomTargetCenter = [pinchGR locationInView:self];
        
        if(state == UIGestureRecognizerStateBegan)
        {
            [self.xPanAnimator cancelAnimation];
            [self.yPanAnimator cancelAnimation];
            [self.panDisplayLink invalidate];
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(viewForZoomingInCAScrollView:)])
                self.targetView = [self.delegate viewForZoomingInCAScrollView:self];
            else
                self.targetView = nil;
            self.pinchGRRecognizing = YES;
        }
        if(!self.zooming)
        {
            self.zooming = YES;
            self.zoomOriginalSize = self.contentSize;
            self.zoomOriginalCenter = [pinchGR locationInView:self];
            self.zoomOriginalOffset = self.contentOffset;
            if(self.targetView != nil)
                self.zoomTargetViewOriginalFrame = self.targetView.frame;
            self.zoomOriginalContentScale = self.zoomScale;
            self.zoomOriginalFromScale = pinchGR.scale;
        }
        
        CGFloat originalContentScale = self.zoomOriginalContentScale;
        CGFloat multiplier = self.pinchBounceMutiplyFactor;
        CGFloat maximumZoomScale = self.maximumZoomScale;
        CGFloat minimumZoomScale = self.minimumZoomScale;
        BOOL bouncesZoom = self.bouncesZoom;
        
        CGFloat targetScale = (pinchGR.scale / self.zoomOriginalFromScale) * originalContentScale;
        
        if(targetScale > maximumZoomScale)
        {
            if(bouncesZoom)
            {
                if(originalContentScale > maximumZoomScale)
                {
                    if(targetScale > originalContentScale)
                    {
                        CGFloat addExMultiplier = [self pinchAlreadyBounceThanBounceExternalMutiplyFactorForOriginalScale:originalContentScale
                                                                                                        tryingTargetScale:targetScale
                                                                                                                 minScale:minimumZoomScale
                                                                                                                 maxScale:maximumZoomScale];
                        CGFloat tryScale = originalContentScale + [CARubberbandFunction positionOffsetForTouchOffset:(targetScale - originalContentScale) * addExMultiplier] / addExMultiplier;
                        if(tryScale < targetScale)
                            targetScale = tryScale;
                    }
                }
                else
                    targetScale = maximumZoomScale + [CARubberbandFunction positionOffsetForTouchOffset:(targetScale -  maximumZoomScale) * multiplier] / multiplier;
            }
            else
            {
                targetScale = maximumZoomScale;
                self.zoomOriginalFromScale = pinchGR.scale;
                self.zoomOriginalContentScale = targetScale;
            }
        }
        else if(targetScale < minimumZoomScale)
        {
            if(bouncesZoom)
            {
                if(originalContentScale < minimumZoomScale)
                {
                    if(targetScale < originalContentScale)
                    {
                        CGFloat addExMultiplier = [self pinchAlreadyBounceThanBounceExternalMutiplyFactorForOriginalScale:originalContentScale
                                                                                                        tryingTargetScale:targetScale
                                                                                                                 minScale:minimumZoomScale
                                                                                                                 maxScale:maximumZoomScale];

                        CGFloat tryScale = originalContentScale - [CARubberbandFunction positionOffsetForTouchOffset:(originalContentScale - targetScale) * addExMultiplier] /  addExMultiplier;
                        if(tryScale > targetScale)
                            targetScale = tryScale;
                    }
                }
                else
                    targetScale = minimumZoomScale - [CARubberbandFunction positionOffsetForTouchOffset:(minimumZoomScale - targetScale) * multiplier] / multiplier;
            }
            else
            {
                targetScale = minimumZoomScale;
                self.zoomOriginalFromScale = pinchGR.scale;
                self.zoomOriginalContentScale = targetScale;
            }
        }
        
        if(isnan(targetScale))
            raise(SIGINT);
        
        [self zoomFromOriginalSize:self.zoomOriginalSize
                    originalOffset:self.zoomOriginalOffset
                    originalCenter:self.zoomOriginalCenter
                      targetCenter:self.zoomTargetCenter
                        targetView:self.targetView
           targetViewOriginalFrame:self.zoomTargetViewOriginalFrame
                     originalScale:self.zoomOriginalContentScale
                       targetScale:targetScale];
    }
}

+ (CAViscousDampingFunction *)zoomDampingFunction
{
    const CGFloat mass = 1, spring = 20, coefficient = sqrt(4 * mass * spring);
    return [[CAViscousDampingFunction alloc] initWithMass:mass spring:spring coefficient:coefficient];
}

- (void)zoomFromOriginalSize:(CGSize)originalSize
              originalOffset:(CGPoint)originalOffset
              originalCenter:(CGPoint)originalCenter
                targetCenter:(CGPoint)targetCenter
                  targetView:(UIView *)targetView
     targetViewOriginalFrame:(CGRect)targetViewOriginalFrame
               originalScale:(CGFloat)originalScale
                 targetScale:(CGFloat)targetScale
{
    CGFloat relativeScale = targetScale / originalScale;
    
    CGSize targetContentSize = originalSize;
    targetContentSize.width *= relativeScale;
    targetContentSize.height *= relativeScale;
    
    UIEdgeInsets adjusted = self.adjustedContentInset;
    
    CGPoint targetContentOffset = originalOffset;
    targetContentOffset.x *= relativeScale;
    targetContentOffset.y *= relativeScale;
    targetContentOffset.x += originalCenter.x * (relativeScale - 1);
    targetContentOffset.y += originalCenter.y * (relativeScale - 1);
    targetContentOffset.x += adjusted.left * (1 - relativeScale);
    targetContentOffset.y += adjusted.top * (1 - relativeScale);
    
    targetContentOffset.x -= targetCenter.x - originalCenter.x;
    targetContentOffset.y -= targetCenter.y - originalCenter.y;
    
    CGRect targetViewTargetFrame = CGRectZero;
    if(targetView != nil)
    {
        targetViewTargetFrame = targetViewOriginalFrame;
        targetViewTargetFrame.size.width *= relativeScale;
        targetViewTargetFrame.size.height *= relativeScale;
        targetViewTargetFrame.origin.x *= relativeScale;
        targetViewTargetFrame.origin.y *= relativeScale;
    }
    
    _contentSize = targetContentSize;
    if(targetView != nil)
        targetView.frame = targetViewTargetFrame;
    [self forceContentOffset:targetContentOffset];
    _zoomScale = targetScale;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(CAScrollViewDidZoom:)])
        [self.delegate CAScrollViewDidZoom:self];
}

- (BOOL)isTracking
{
    return self.panGRRecognizing || self.pinchGRRecognizing;
}

@end
