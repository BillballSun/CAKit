//
//  CAWindowEventObserverWrapper.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/12.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAWindowEventObserverWrapper.h"

@interface CAWindowEventObserverWrapper ()

@property(readwrite, weak) id target;

@property(readwrite) SEL selector;

@end

@implementation CAWindowEventObserverWrapper

- (instancetype)initWithTargert:(id)target selector:(SEL)selector
{
    if(self = [super init])
    {
        self.target = target;
        self.selector = selector;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
