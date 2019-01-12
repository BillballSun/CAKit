//
//  CARubberbandFunction.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CARubberbandFunction : NSObject

@property(class, readonly, nonatomic) double resistanceFactor;

+ (double)positionOffsetForTouchOffset:(double)touchOffset;

+ (double)positionOffsetForTouchOffset:(double)touchOffset resistanceFactor:(double)reresistanceFactor;

@end
