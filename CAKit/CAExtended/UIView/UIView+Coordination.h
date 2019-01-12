//
//  UIView+Coordination.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Coordination)

@property(nonatomic) CGPoint origin;

@property(nonatomic) CGSize size;

@property(nonatomic) CGFloat width;

@property(nonatomic) CGFloat height;

- (NSArray<NSLayoutConstraint *> *)constraintEqualToView:(UIView *)view;

- (NSArray<NSLayoutConstraint *> *)constraintAtTopEqualWidthFixedHight:(UIView *)scrollView internalSpace:(CGFloat)internalSpace;

- (NSArray<NSLayoutConstraint *> *)constraintBelowViewFixedHight:(UIView *)formerView internalSpace:(CGFloat)internalSpace;

- (void)setSize:(CGSize)size center:(CGPoint)center;

@end
