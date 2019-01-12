//
//  CAVisualizedTouchCircleView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVisualizedTouchCircleView.h"

#define CAVisualizedTouchCircleViewCircleImageWidth 1334
#define CAVisualizedTouchCircleViewCacheImageMaxAmount 6

@interface CAVisualizedTouchCircleView ()
@property(readwrite) UIColor *circleColor;
@end

@implementation CAVisualizedTouchCircleView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    if(color == nil)
        [[NSException exceptionWithName:@"Invalid Arguments"
                                 reason:@"- [CAVisualizedTouchCircleView initWithFrame:color:] assign nil as color parameter"
                               userInfo:nil] raise];
    if(self = [super initWithFrame:frame])
    {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        self.circleColor = color;
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self.layer setNeedsDisplay];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.circleColor = UIColor.whiteColor;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.circleColor = UIColor.whiteColor;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

+ (CGImageRef)circleImageWithColor:(UIColor *)color
{
    static NSMutableDictionary<UIColor *, id> *cacheImageDictionary;
    
    if(cacheImageDictionary == nil)
        cacheImageDictionary = [NSMutableDictionary dictionaryWithCapacity:CAVisualizedTouchCircleViewCacheImageMaxAmount];
    
    if(cacheImageDictionary[color] != nil)
        return (__bridge CGImageRef)cacheImageDictionary[color];
    
    if(cacheImageDictionary.count >= CAVisualizedTouchCircleViewCacheImageMaxAmount)
        [cacheImageDictionary removeObjectForKey:cacheImageDictionary.allKeys[0]];
    CGImageRef newImage = [CAVisualizedTouchCircleView drawCricleImageWithColor:color];
    [cacheImageDictionary setObject:(__bridge id)newImage forKey:color];
    return newImage;
}

+ (CGImageRef)drawCricleImageWithColor:(UIColor *)color
{
    CGColorSpaceRef deviceRGB_CS = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             CAVisualizedTouchCircleViewCircleImageWidth,
                                             CAVisualizedTouchCircleViewCircleImageWidth,
                                             8,
                                             CAVisualizedTouchCircleViewCircleImageWidth * 4,
                                             deviceRGB_CS,
                                             kCGImageAlphaPremultipliedFirst);
    
    CGContextMoveToPoint(ctx,
                         CAVisualizedTouchCircleViewCircleImageWidth,
                         CAVisualizedTouchCircleViewCircleImageWidth/2);
    CGContextAddArc(ctx,
                    CAVisualizedTouchCircleViewCircleImageWidth/2,
                    CAVisualizedTouchCircleViewCircleImageWidth/2,
                    CAVisualizedTouchCircleViewCircleImageWidth/2,
                    0,
                    2 * M_PI,
                    0);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillPath(ctx);
    
    CGImageRef circleImage = (CGImageRef)CFAutorelease(CGBitmapContextCreateImage(ctx));
    
    CGColorSpaceRelease(deviceRGB_CS);
    CGContextRelease(ctx);
    
    return circleImage;
}

- (void)displayLayer:(CALayer *)layer
{
    layer.contents = (__bridge id)[CAVisualizedTouchCircleView circleImageWithColor:self.circleColor];
}

//- (void)drawRect:(CGRect)rect {}

@end
