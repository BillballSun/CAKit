//
//  NSValue+ToString.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//


#import "NSValue+ToString.h"

@implementation NSValue (ToString)

#if !TARGET_OS_IPHONE

+ (NSString *)glyphGeneratorLayoutOptionsToString:(NSUInteger)optionMask
{
//    enum : unsigned int {
//        NSShowControlGlyphs = (1 << 0),
//        NSShowInvisibleGlyphs = (1 << 1),
//        NSWantsBidiLevels = (1 << 2)
//    };
    BOOL isEmpty = YES;
    NSMutableString *string = [NSMutableString string];
    if(optionMask | NSShowControlGlyphs) (void)([string appendString:@"controlGlyphs"]), isEmpty = NO;
    if(optionMask | NSShowInvisibleGlyphs) (void)([string appendString: isEmpty ? @"InvisibleGlyphs" : @"+InvisibleGlyphs"]), isEmpty = NO;
    if(optionMask | NSWantsBidiLevels) (void)([string appendString: isEmpty ? @"BidiLevels" : @"+BidiLevels"]), isEmpty = NO;
    return isEmpty ? @"No-options" : [string copy];
}

#else

+ (NSString *)ConvertUIStatusBarStyleToString:(UIStatusBarStyle)style {
    switch (style) {
        case UIStatusBarStyleDefault:
            return @"defaultStyle";
        case UIStatusBarStyleLightContent:
            return @"lightStyle";
        default:
            return @"unkownStyle";
    }
}

#endif

@end
