//
//  CAVisualizedTouchDisplayView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAVisualizedTouchAppearance/CAVisualizedTouchAppearance.h"
#import "CAVisualizedTouchDisplayViewDelegate.h"

@interface CAVisualizedTouchDisplayView : UIView <CAAnimationDelegate>

- (instancetype)initWithFrame:(CGRect)frame
                   appearance:(CAVisualizedTouchAppearance *)appearance
                     position:(CGPoint)position
                       radius:(CGFloat)radius;   /* designated */

@property(nonatomic) CGPoint position;
@property(nonatomic) CGFloat radius;

@property(nonatomic) CGFloat advancedRadius;
@property(nonatomic) CGFloat mainAlpha;
@property(nonatomic) CGFloat secondaryAlpha;
@property id<CAVisualizedTouchDisplayViewDelegate> delegate;

@property(readonly) CAVisualizedTouchAppearance* appearance;
@property(readonly, getter=isFinalizeStatus) BOOL finalizeStatus;
@property(readonly, getter=isFinalizedAnimationComplete) BOOL finalizeAnimationComplete;

- (void)startFinalizedAnimation;

@end
