//
//  CAScrollViewDelegate.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/9.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAScrollView;

@protocol CAScrollViewDelegate <NSObject>
@optional

- (void)CAScrollViewDidScroll:(CAScrollView *)scrollView; // any offset changes
- (void)CAScrollViewDidZoom:(CAScrollView *)scrollView;   // any zoom scale changes

- (UIView *)viewForZoomingInCAScrollView:(CAScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens

/* Also see -[UIScrollView adjustedContentInsetDidChange]
 */
- (void)CASrollViewDidChangeAdjustedContentInset:(CAScrollView *)scrollView;

@end
