//
//  CAVisualizedTouchAppearance.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVisualizedTouchAppearance.h"

@implementation CAVisualizedTouchAppearance

- (instancetype)initWithType:(CAVisualizedTouchAppearanceType)type
{
    if(self = [super init])
    {
        switch (type) {
            case CAVisualizedTouchAppearanceTypeSimpleCircle:
                self.mainCircleColor = UIColor.whiteColor;
                self.secondaryCircleColor = UIColor.whiteColor;
                break;
            default:
                [[NSException exceptionWithName:@"Invalid Argument"
                                         reason:@"- [CAVisualizedTouchAppearance initWithType:] unrecognized Type"
                                       userInfo:nil] raise];
                break;
        }
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
