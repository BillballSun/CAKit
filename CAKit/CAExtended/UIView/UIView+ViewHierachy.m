//
//  UIView+ViewHierachy.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/27.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIView+ViewHierachy.h"
#import "CATestMethodHierachy.h"
#import "CoreGraphicsExtension.h"

@implementation UIView (ViewHierachy)

- (CGRect)rectWrapAllSubviews {
    CGRect result = self.bounds;
    for(UIView *eachSubView in self.subviews) {
        CGRect subViewCoord = [eachSubView rectWrapAllSubviews];
        CGRect currentCoord = [self convertRect:subViewCoord fromView:eachSubView];
        result = CGRectCombine(result, currentCoord);
    }
    return result;
}

- (void)displayViewHierachyWithDiscriptor:(void (^)(__kindof UIView *))discriptor
{
    [CATestMethodHierachy begin];
    [self _displayViewHierachyWithDiscriptor:discriptor];
    [CATestMethodHierachy commit];
}

- (void)_displayViewHierachyWithDiscriptor:(void (^)(__kindof UIView *))discriptor
{
    NSString *classString = NSStringFromClass(self.class);
    [CATestMethodHierachy goDeepIntoAndOutputSpace];
    printf("%s ", [classString UTF8String]);
    if(discriptor != nil)
        discriptor(self);
    putchar('\n');
    for(UIView *each in self.subviews)
        [each _displayViewHierachyWithDiscriptor:discriptor];
    [CATestMethodHierachy comeout];
}

- (BOOL)isSubviewOf:(UIView *)view
{
    for(UIView *each in view.subviews)
        if(view == each)
            return YES;
    return NO;
}

- (NSUInteger)indexOfSubview:(UIView *)subview
{
    NSUInteger index = 0;
    for(UIView *each in self.subviews)
    {
        if(each == subview) return index;
        index++;
    }
    [[NSException exceptionWithName:@"Invalid Operation" reason:@"- [UIView indexOfSubView] view is not a subview of current view" userInfo:nil] raise];
    return NSUIntegerMax;
}

@end
