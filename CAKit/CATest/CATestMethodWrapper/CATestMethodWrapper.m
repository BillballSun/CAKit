//
//  CATestMethodWrapper.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <objc/NSObjCRuntime.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "CATestMethodWrapper.h"
#import "CATestMethodHierachy.h"

@implementation CATestMethodWrapper

//static IMP previousIMP;

+ (void)begin
{
//    IMP hitTestUIView = class_getMethodImplementation(UIView.class, @selector(hitTest:withEvent:));
//    previousIMP = hitTestUIView;
//    IMP replaced = class_getMethodImplementation(self.class, @selector(replaceHitTest:withEvent:));
//    class_replaceMethod(UIView.class, @selector(hitTest:withEvent:), replaced, "@@:{CGPoint=dd}@");
}

//- (UIView *)replaceHitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSUInteger depth = [CATestMethodHierachy goDeepInto];
//
//    for(NSUInteger index = 0; index < depth; index++)
//        putchar(' ');
//    fprintf(stdout, "%s\n", NSStringFromClass(self.class).UTF8String);
//
//    UIView *result = ((UIView * (*)(id, SEL, CGPoint, UIEvent *))previousIMP)(self, _cmd, point, event);
//
//    for(NSUInteger index = 0; index < depth; index++)
//        putchar(' ');
//    fprintf(stdout, "result: %s\n", result == nil ? "nil" : NSStringFromClass(result.class).UTF8String);
//    [CATestMethodHierachy comeout];
//    return result;
//}

+ (void)end
{
    
}

@end
