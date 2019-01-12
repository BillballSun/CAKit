//
//  CAVisualizedTouchCircleView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAVisualizedTouchCircleView : UIView <CALayerDelegate>

@property(readonly) UIColor *circleColor;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color; /* designated */

@end
