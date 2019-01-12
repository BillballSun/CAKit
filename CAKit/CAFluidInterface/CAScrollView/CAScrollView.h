//
//  CAScrollView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAScrollViewDelegate.h"

extern const CGFloat CAScrollViewDecelerationRateNormal;
extern const CGFloat CAScrollViewDecelerationRateFast;
extern const CGFloat CAScrollViewDecelerationRateSlow;

@interface CAScrollView : UIView <NSCoding, UIGestureRecognizerDelegate>

@property(nonatomic, weak) id<CAScrollViewDelegate> delegate;

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;

- (void)adjustedContentInsetDidChange;

@property(nonatomic, readonly, getter=isTracking) BOOL tracking;

@property(nonatomic, readonly, getter=isZooming) BOOL zooming;

- (void)flashScrollIndicators;

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated;

@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer;

- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated;

- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated;

@property(nonatomic) CGSize contentSize;
@property(nonatomic) CGPoint contentOffset;
@property(nonatomic) UIEdgeInsets contentInset;
@property(nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property(nonatomic, getter=isPagingEnabled) BOOL pagingEnabled;
@property(nonatomic) BOOL bounces;
@property(nonatomic) BOOL alwaysBounceVertical;
@property(nonatomic) BOOL alwaysBounceHorizontal;
@property(nonatomic) CGFloat decelerationRate;
@property(nonatomic) UIScrollViewIndicatorStyle indicatorStyle;
@property(nonatomic) UIEdgeInsets scrollIndicatorInsets;
@property(nonatomic) BOOL showsHorizontalScrollIndicator;
@property(nonatomic) BOOL showsVerticalScrollIndicator;
@property(nonatomic) CGFloat zoomScale;
@property(nonatomic) CGFloat maximumZoomScale;
@property(nonatomic) CGFloat minimumZoomScale;
@property(nonatomic) BOOL bouncesZoom;
@property(nonatomic, readonly) UIEdgeInsets adjustedContentInset;

@property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior __attribute((availability(ios, introduced=11.0)));

@end
