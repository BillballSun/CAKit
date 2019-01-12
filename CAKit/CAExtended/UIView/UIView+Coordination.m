//
//  UIView+Coordination.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIView+Coordination.h"

@implementation UIView (Coordination)

@dynamic origin, size, width, height;

- (void)setSize:(CGSize)size center:(CGPoint)center
{
    CGRect frame = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (NSArray<NSLayoutConstraint *> *)constraintEqualToView:(UIView *)view
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

- (NSArray<NSLayoutConstraint *> *)constraintAtTopEqualWidthFixedHight:(UIView *)scrollView internalSpace:(CGFloat)internalSpace
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:internalSpace];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:self.bounds.size.height];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

- (NSArray<NSLayoutConstraint *> *)constraintBelowViewFixedHight:(UIView *)formerView internalSpace:(CGFloat)internalSpace
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:internalSpace];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:self.bounds.size.height];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

@end
