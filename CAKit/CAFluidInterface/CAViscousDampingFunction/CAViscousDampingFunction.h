//
//  CAViscousDampingFunction.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/2.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

typedef enum : NSUInteger {
    CAViscousDampingTypeUnderDamped,
    CAViscousDampingTypeCriticalDamped,
    CAViscousDampingTypeOverDamped,
} CAViscousDampingType;

@interface CAViscousDampingFunction : NSObject

/**
 Designated Initializer
 Pysical Note
 @param m means the mass
 @param k spring constant, the force of spring equals k multiply distance
 @param c the Resistance of Viscous coefficient, the force equals c multiply velocity
 @return a configurated echo-system of damping
 */
- (instancetype)initWithMass:(double)m spring:(double)k coefficient:(double)c distance:(double)s velocity:(double)v;

- (instancetype)initWithMass:(double)m spring:(double)k coefficient:(double)c;

@property(nonatomic) double initialDistance;

/**
 IMPORTANT: towards the equilibrium, it needs the opposite positive-negative status of initialDistance
 */
@property(nonatomic) double initialVelocity;

- (void)setInitialDistance:(double)distance velocity:(double)velocity;

@property(nonatomic, readonly) double mass;

@property(nonatomic, readonly) double spring;

@property(nonatomic, readonly) double coefficient;

@property(nonatomic, readonly) CAViscousDampingType dampingType;

- (double)distanceAtTime:(double)time;

- (double)velocityAtTime:(double)time;

- (double)energyAtTime:(double)time;

- (double)energyPercentageAtTime:(double)time;

@end
