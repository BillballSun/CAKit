//
//  UIView+ContentDrawing.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ContentDrawing)

- (UIImage *)captureCurrentViewHierachyWithinBounds;

- (UIImage *)captureCurrentViewHierachyEncloseAllSubviews;

@end
