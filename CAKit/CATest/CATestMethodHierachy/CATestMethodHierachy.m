//
//  CATestMethodHierachy.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/17.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CATestMethodHierachy.h"

@interface CATestMethodHierachy ()
@property(class, readonly) NSMutableArray *depthStack;
@end

@implementation CATestMethodHierachy

+(NSMutableArray<NSNumber *> *)depthStack
{
    static NSMutableArray<NSNumber *> *stack;
    if(stack == nil) stack = [NSMutableArray array];
    return stack;
}

+ (void)begin
{
    [CATestMethodHierachy.depthStack addObject:@0];
}

+ (void)commit
{
    [CATestMethodHierachy deepStackNotEmptyExceptionCheck];
    
    [CATestMethodHierachy.depthStack removeLastObject];
}

+ (NSUInteger)goDeepInto
{
    [CATestMethodHierachy deepStackNotEmptyExceptionCheck];
    NSUInteger depth = [CATestMethodHierachy.depthStack.lastObject unsignedIntegerValue];
    [CATestMethodHierachy.depthStack removeLastObject];
    [CATestMethodHierachy.depthStack addObject:@(depth+1)];
    return depth;
}

+ (NSUInteger)goDeepIntoAndOutputSpace
{
    NSUInteger depth = [self goDeepInto];
    for(NSUInteger index = 0; index < depth; index++)
        putchar(' ');
    return depth;
}

+ (NSUInteger)currentDepth
{
    [CATestMethodHierachy deepStackNotEmptyExceptionCheck];
    NSUInteger depth = [CATestMethodHierachy.depthStack.lastObject unsignedIntegerValue];
    return depth;
}

+ (NSUInteger)outputCurrentDepthSpace
{
    NSUInteger depth = [self currentDepth];
    for(NSUInteger index = 0; index < depth; index++)
        putchar(' ');
    return depth;
}

+ (void)comeout
{
    [CATestMethodHierachy deepStackNotEmptyExceptionCheck];
    NSUInteger depth = [CATestMethodHierachy.depthStack.lastObject unsignedIntegerValue];
    if(depth == 0)
        [[NSException exceptionWithName:@"Unexpected Status" reason:@"+[CATestMethodHierachy comeout] without mathcing goDeepInto method" userInfo:nil] raise];
    
    [CATestMethodHierachy.depthStack removeLastObject];
    [CATestMethodHierachy.depthStack addObject:@(depth-1)];
}

+ (void)deepStackNotEmptyExceptionCheck
{
    if(CATestMethodHierachy.depthStack.count == 0)
        [[NSException exceptionWithName:@"Unexpected Status" reason:@"+[CATestMethodHierachy deepStackNotEmptyExceptionCheck] without matching +begin method" userInfo:nil] raise];
}

@end
