//
//  UIView+ContentDrawing.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIView+ContentDrawing.h"
#import "UIView+ViewHierachy.h"

@implementation UIView (ContentDrawing)

- (UIImage *)captureCurrentViewHierachyWithinBounds
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.contentScaleFactor);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)captureCurrentViewHierachyEncloseAllSubviews {
    UIViewContentMode contentMode = self.contentMode;
    BOOL autoResizeSubviews = self.autoresizesSubviews;
    CGRect previousBounds = self.bounds;
    
    CGRect warpAllRect = [self rectWrapAllSubviews];
    
    CGRect tranlatedBounds = warpAllRect;
    tranlatedBounds.origin = CGPointZero;
    
    CGPoint translatedMove = warpAllRect.origin;
    
    self.contentMode = UIViewContentModeTopLeft;
    self.autoresizesSubviews = NO;
    self.bounds = tranlatedBounds;
    
    for(UIView *eachSubview in self.subviews) {
        CGPoint caculatedCenter = eachSubview.center;
        caculatedCenter.x -= translatedMove.x;
        caculatedCenter.y -= translatedMove.y;
        eachSubview.center = caculatedCenter;
    }
    
    UIGraphicsBeginImageContextWithOptions(warpAllRect.size, NO, self.contentScaleFactor);
    [self drawViewHierarchyInRect:tranlatedBounds afterScreenUpdates:NO];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for(UIView *eachSubview in self.subviews) {
        CGPoint caculatedCenter = eachSubview.center;
        caculatedCenter.x += translatedMove.x;
        caculatedCenter.y += translatedMove.y;
        eachSubview.center = caculatedCenter;
    }
    
    self.bounds = previousBounds;
    self.contentMode = contentMode;
    self.autoresizesSubviews = autoResizeSubviews;
    
    return result;
}

@end
