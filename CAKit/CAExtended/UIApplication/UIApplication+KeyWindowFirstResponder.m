//
//  UIApplication+KeyWindowFirstResponder.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/6/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIApplication+KeyWindowFirstResponder.h"
#import "UIResponder+FindFirstResponder.h"

@implementation UIApplication (KeyWindowFirstResponder)

+ (UIResponder *)keyWindowFirstResponder
{
    return [UIApplication.sharedApplication findFirstResponder];
}

@end
