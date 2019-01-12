//
//  CAVisualizedTouchAppearance.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CAVisualizedTouchAppearanceType : NSUInteger {
    CAVisualizedTouchAppearanceTypeSimpleCircle,
} CAVisualizedTouchAppearanceType;

@interface CAVisualizedTouchAppearance : NSObject

@property UIColor *mainCircleColor;

@property UIColor *secondaryCircleColor;

- (instancetype)initWithType:(CAVisualizedTouchAppearanceType)type;

@property CAVisualizedTouchAppearanceType type;

@end
