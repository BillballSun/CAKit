//
//  CAVisualizedTouchWrapper.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAVisualizedTouchDisplayView/CAVisualizedTouchDisplayView.h"

@interface CAVisualizedTouchWrapper : NSObject

@property(weak, readonly) UITouch *touch;

@property(weak, readwrite) CAVisualizedTouchDisplayView *visualView;

- (instancetype)initWithTouch:(UITouch *)touch; /* desginated */

@end
