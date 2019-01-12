//
//  CAVisualizedTouchView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAWindow.h"
#import "CAVisualizedTouchWrapper/CAVisualizedTouchDisplayView/CAVisualizedTouchDisplayViewDelegate.h"

@class CAVisualizedTouchAppearance;

/* multi-threading disabled */
@interface CAVisualizedTouchView : UIView <CAVisualizedTouchDisplayViewDelegate>

@property(nonatomic, assign, getter=isHidden) BOOL touchHidden;

@property(nonatomic, assign, readonly, getter=isAnimationEnabled) BOOL animationEnabled;
@property(readonly, getter=isTouchVisible) BOOL touchVisible;
@property(nonatomic, assign, readwrite) NSUInteger maxTouchAmount;
@property(strong) CAVisualizedTouchAppearance *appearance;

- (instancetype)initWithWindow:(CAWindow *)window;  /* designated intializer */

- (void)tryToStartAnimation;

- (void)tryToEndAnimation;

@end
