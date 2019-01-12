//
//  UIView+ViewHierachy.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/27.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewHierachy)

- (void)displayViewHierachyWithDiscriptor:(void (^)(__kindof UIView *))discriptor;

- (BOOL)isSubviewOf:(UIView *)view;

- (NSUInteger)indexOfSubview:(UIView *)subview;

- (CGRect)rectWrapAllSubviews;

@end
