//
//  CAViscousDampingFunction.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/2.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAViscousDampingFunction.h"
#import "CAViscousDampingFunction+Percentage.h"

@interface CAViscousDampingFunction ()
@property(nonatomic, readwrite) double mass;
@property(nonatomic, readwrite) double spring;
@property(nonatomic, readwrite) double coefficient;
@end

@implementation CAViscousDampingFunction

- (instancetype)initWithMass:(double)m spring:(double)k coefficient:(double)c distance:(double)s velocity:(double)v
{
    if(self = [super init])
    {
        self.mass = m;
        self.spring = k;
        self.coefficient = c;
        self.initialDistance = s;
        self.initialVelocity = v;
    }
    return self;
}

- (instancetype)initWithMass:(double)m spring:(double)k coefficient:(double)c
{
    return [self initWithMass:m spring:k coefficient:c distance:0 velocity:0];
}

- (CAViscousDampingType)dampingType
{
    double m = self.mass;
    double c = self.coefficient;
    double k = self.spring;
    if(c * c < 4 * m * k) return CAViscousDampingTypeUnderDamped;
    else if(c * c == 4 * m * k) return CAViscousDampingTypeCriticalDamped;
    else return CAViscousDampingTypeOverDamped;
}

- (void)setInitialDistance:(double)distance velocity:(double)velocity
{
    self.initialDistance = distance;
    self.initialVelocity = velocity;
}

- (double)distanceAtTime:(double)x
{
    double m = self.mass;
    double c = self.coefficient;
    double k = self.spring;
    double s = self.initialDistance;
    double v = self.initialVelocity;
    double result;
    
    double real, imaginary;
    double C1, C2;
    double r;
    double delta;
    double r1, r2;
    
    switch (self.dampingType) {
        case CAViscousDampingTypeUnderDamped:
            delta = sqrt(4.0 * m * k - c * c);
            real = - c / (2.0 * m);
            imaginary = delta / (2.0 * m);
            C1 = s;
            C2 = (2.0 * m * v + c * s) / delta;
            result = exp(real * x) * (C1 * cos(imaginary * x) + C2 * sin(imaginary * x));
            return result;
        case CAViscousDampingTypeCriticalDamped:
            C1 = v + (c * s) / (2.0 * m);
            C2 = s;
            r = - c / (2.0 * m);
            result = (C1 * x + C2) * exp(r * x);
            return result;
        case CAViscousDampingTypeOverDamped:
            delta = sqrt(c * c - 4.0 * m * k);
            r1 = (-c + delta) / (2.0 * m);
            r2 = (-c - delta) / (2.0 * m);
            C1 = (s * (delta + c) + 2.0 * m * v) / (2.0 * delta);
            C2 = (s * (delta - c) - 2.0 * m * v) / (2.0 * delta);
            result = C1 * exp(r1 * x) + C2 * exp(r2 * x);
            return result;
    }
}

- (double)velocityAtTime:(double)x
{
    double m = self.mass;
    double c = self.coefficient;
    double k = self.spring;
    double s = self.initialDistance;
    double v = self.initialVelocity;
    double result;
    
    double delta;
    double real, imaginary;
    double r;
    double C1, C2;
    double r1, r2;
    
    switch (self.dampingType) {
        case CAViscousDampingTypeUnderDamped:
            delta = sqrt(4.0 * m * k - c * c);
            real = - c / (2.0 * m);
            imaginary = delta / (2.0 * m);
            result = exp(real * x) * (((-2.0 * k * s - v * c) / delta) * sin(imaginary * x) + v * cos(imaginary * x));
            return result;
        case CAViscousDampingTypeCriticalDamped:
            r = - c / (2.0 * m);
            C1 = - (c * (2.0 * m * v + c * s)) / (4.0 * m * m);
            C2 = v;
            result = (C1 * x + C2) * exp(r * x);
            return result;
        case CAViscousDampingTypeOverDamped:
            delta = sqrt(c * c - 4.0 * m * k);
            r1 = (- c + delta) / (2.0 * m);
            r2 = (- c - delta) / (2.0 * m);
            C1 = (v * (delta - c) - 2.0 * k * s) / (2.0 * delta);
            C2 = (v * (delta + c) + 2.0 * k * s) / (2.0 * delta);
            result = C1 * exp(r1 * x) + C2 * exp(r2 * x);
            return result;
    }
}

- (double)energyAtTime:(double)x
{
    double k = self.spring;
    double m = self.mass;
    
    double velocity = [self velocityAtTime:x];
    double distance = [self distanceAtTime:x];
    return 0.5 * k * distance * distance + 0.5 * m * velocity * velocity;
}

- (double)energyPercentageAtTime:(double)time
{
    double m = self.mass;
    double k = self.spring;
    double s = self.initialDistance;
    double v = self.initialVelocity;
    
    double initialEnergy = 0.5 * k * s * s + 0.5 * m * v * v;
    double currentEnergy = [self energyAtTime:time];
    
    return currentEnergy / initialEnergy;
}

- (double)equilibriumCompletePercentageAtTime:(double)time;
{
    double currentDistance = [self distanceAtTime:time];
    double initialDistance = self.initialDistance;
    return (initialDistance - currentDistance) / initialDistance;
}

@end
