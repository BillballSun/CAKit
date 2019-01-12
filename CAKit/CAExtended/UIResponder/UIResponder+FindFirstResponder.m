//
//  UIResponder+FindFirstResponder.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/6/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIResponder+FindFirstResponder.h"

@implementation UIResponder (FindFirstResponder)

- (__kindof UIResponder *)findFirstResponder
{
    __kindof UIResponder *temp;
    if (self.isFirstResponder)
        return self;
    if([self isKindOfClass:UIViewController.class])
    {
        if(((__kindof UIViewController *)self).presentedViewController != nil)
            if((temp = [((__kindof UIViewController *)self).presentedViewController findFirstResponder]) != nil)
                return temp;
        return [((__kindof UIViewController *)self).view findFirstResponder];
    }
    else if([self isKindOfClass:UIView.class])
    {
        for(UIView *eachSub in ((__kindof UIView *)self).subviews)
            if((temp = [eachSub findFirstResponder]) != nil)
                return temp;
    }
    else if([self isKindOfClass:UIWindow.class])
    {
        return [((__kindof UIWindow *)self).rootViewController findFirstResponder];
    }
    else if([self isKindOfClass:UIApplication.class])
    {
        if(((__kindof UIApplication *)self).keyWindow != nil)
            return [((__kindof UIApplication *)self).keyWindow findFirstResponder];
    }
    else
    {
        [[NSException exceptionWithName:@"CAExceptionInvalidSelf"
                                 reason:@"-[UIResponder findFirstResponder] unknown type"
                               userInfo:nil] raise];
    }
    return nil;
}

@end
