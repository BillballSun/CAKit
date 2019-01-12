//
//  CAFluidDrawerView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidDrawerView.h"
#import "CAFluidDrawerController+Private.h"

@interface CAFluidDrawerView ()
@property(weak) IBOutlet CAFluidDrawerController *controller;
@end

@implementation CAFluidDrawerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *superResult = [super hitTest:point withEvent:event];
    if(superResult == self)
        return nil;
    return superResult;
}

- (void)setFrame:(CGRect)frame
{
    if(CGSizeEqualToSize(self.frame.size, frame.size))
        [self.controller updateScrollContraints];
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds
{
    if(CGSizeEqualToSize(self.bounds.size, bounds.size))
        [self.controller updateScrollContraints];
    [super setBounds:bounds];
}

@end
