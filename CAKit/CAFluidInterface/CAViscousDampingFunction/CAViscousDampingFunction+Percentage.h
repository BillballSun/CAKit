//
//  CAViscousDampingFunction+Percentage.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAViscousDampingFunction.h"

@interface CAViscousDampingFunction (Percentage)

/**
 towards equilibrium complete percentage
 @return may be less than zero or more than 1
 */
- (double)equilibriumCompletePercentageAtTime:(double)time;

@end
