//
//  CARubberbandFunction.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CARubberbandFunction.h"

@implementation CARubberbandFunction

static double resistanceFactor = 0.7;

+ (double)resistanceFactor
{
    return resistanceFactor;
}

+ (void)setResistanceFactor:(double)r
{
    if(r >= 1.0) r = 0.9;
    else if(r <= 0.0) r = 0.1;
    resistanceFactor = r;
}

+ (double)positionOffsetForTouchOffset:(double)touchOffset
{
    return [self positionOffsetForTouchOffset:touchOffset resistanceFactor:resistanceFactor];
}

+ (double)positionOffsetForTouchOffset:(double)touchOffset resistanceFactor:(double)rf
{
    return pow(touchOffset, rf);
}

@end
