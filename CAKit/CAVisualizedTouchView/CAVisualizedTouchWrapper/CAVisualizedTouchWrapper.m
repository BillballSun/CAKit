//
//  CAVisualizedTouchWrapper.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVisualizedTouchWrapper.h"

@interface CAVisualizedTouchWrapper ()

@property(weak, readwrite) UITouch *touch;

@end

@implementation CAVisualizedTouchWrapper

- (instancetype)initWithTouch:(UITouch *)touch
{
    if(self = [super init])
    {
        self.touch = touch;
        self.visualView = nil;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
