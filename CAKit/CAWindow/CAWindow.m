//
//  CAWindow.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#include <objc/message.h>

#import "CAWindow.h"
#import "CAWindowEventObserverWrapper/CAWindowEventObserverWrapper.h"

@interface CAWindow ()
@property(nonatomic, readonly) NSMutableArray<CAWindowEventObserverWrapper *> *eventsWrapperArray;
@end

@implementation CAWindow

@synthesize eventsWrapperArray = _eventsWrapperArray;

- (NSMutableArray *)eventsWrapperArray
{
    if(_eventsWrapperArray == nil)
        _eventsWrapperArray = [NSMutableArray array];
    else
        [self parseWrapperArray];
    return _eventsWrapperArray;
}

- (void)parseWrapperArray
{
    if(_eventsWrapperArray == nil)
        [[NSException exceptionWithName:@"Unexpected Status"
                                 reason:@"_eventswrapperArray set nil"
                               userInfo:nil] raise];
    NSUInteger count = _eventsWrapperArray.count;
    for(NSUInteger index = 0; index < count;)
        if(_eventsWrapperArray[index].target == nil)
        {
            [_eventsWrapperArray removeObjectAtIndex:index];
            count--;
        }
        else
            index++;
}

- (NSArray *)eventObservers
{
    return nil;
}

- (void)addEventObserver:(id)observer selector:(SEL)selector
{
    for(CAWindowEventObserverWrapper *eachWrapper in self.eventsWrapperArray)
        if(eachWrapper.target == observer && eachWrapper.selector == selector)
            return;
    CAWindowEventObserverWrapper *wrapper = [[CAWindowEventObserverWrapper alloc] initWithTargert:observer selector:selector];
    [self.eventsWrapperArray addObject:wrapper];
}

- (void)removeEventObserver:(id)observer
{
    NSUInteger count = self.eventsWrapperArray.count;
    for(NSUInteger index = 0; index < count;)
        if(self.eventsWrapperArray[index].target == observer)
        {
            [self.eventsWrapperArray removeObjectAtIndex:index];
            count--;
        }
        else
            index++;
}

- (void)removeEventObserver:(id)observer selector:(SEL)selector
{
    NSUInteger count = self.eventsWrapperArray.count;
    for(NSUInteger index = 0; index < count;)
        if(self.eventsWrapperArray[index].target == observer && self.eventsWrapperArray[index].selector == selector)
        {
            [self.eventsWrapperArray removeObjectAtIndex:index];
            count--;
        }
        else
            index++;
}

- (void)removeAllEventObserver:(id)observer
{
    [self.eventsWrapperArray removeAllObjects];
}

- (void)sendEvent:(UIEvent *)event
{
    for(CAWindowEventObserverWrapper *eachWrapper in self.eventsWrapperArray)
        ((void (*)(id, SEL, id))objc_msgSend)(eachWrapper.target, eachWrapper.selector, event);
    [super sendEvent:event];
}

@end
