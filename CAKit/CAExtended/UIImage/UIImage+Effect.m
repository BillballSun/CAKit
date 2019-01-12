//
//  UIImage+Effect.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "UIImage+Effect.h"

#define UIImageBlurEffectDefaultRadius 50

@implementation UIImage (Effect)

- (UIImage *)blurImage
{
    return [self blurImageWithRadius:UIImageBlurEffectDefaultRadius];
}

- (UIImage *)blurImageWithRadius:(CGFloat)radius
{
    if(radius<=0) return self;
    CGSize originalSize = self.size;
    CGFloat originalScale = self.scale;
    if(radius >= MIN(originalSize.width, originalSize.height))
        radius = MIN(originalSize.width, originalSize.height);
    CGImageRef originalCG = CGImageRetain(self.CGImage);
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGSize processSize = CGSizeMake(originalSize.width + 2 * radius, originalSize.height + 2 * radius);
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             processSize.width * originalScale,
                                             processSize.height * originalScale,
                                             8,
                                             processSize.width * originalScale * 4,
                                             cs,
                                             kCGImageAlphaPremultipliedFirst);
    CGContextTranslateCTM(ctx, radius * originalScale, (originalSize.height * 2 + radius) * originalScale);
    CGContextScaleCTM(ctx, -1, -1);
    CGRect imageRect = CGRectMake(0, 0, originalSize.width * originalScale, originalSize.height * originalScale);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextTranslateCTM(ctx, 2 * originalSize.width * originalScale, 0);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, - 2 * originalSize.height * originalScale);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextTranslateCTM(ctx, - 2 * originalSize.width * originalScale, 0);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    CGContextTranslateCTM(ctx, 2 * originalSize.width * originalScale, 0);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, imageRect, originalCG);
    
    CGImageRef proccessedImage = CGBitmapContextCreateImage(ctx);
    
    CIImage *ciImage = [CIImage imageWithCGImage:proccessedImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" withInputParameters:@{@"inputImage":ciImage, @"inputRadius": @(radius * originalScale)}];
    CIContext *ciCtx = [CIContext context];
    CGImageRef unclippedCG = [ciCtx createCGImage:filter.outputImage
                                         fromRect:CGRectMake(0, 0, processSize.width * originalScale, processSize.height * originalScale)];

    CGImageRef resultCG = CGImageCreateWithImageInRect(unclippedCG, CGRectMake(radius * originalScale, radius * originalScale, originalSize.width * originalScale, originalSize.height * originalScale));
    
    UIImage *result = [UIImage imageWithCGImage:resultCG scale:originalScale orientation:UIImageOrientationUp];
    
    CGImageRelease(originalCG);
    CGColorSpaceRelease(cs);
    CGContextRelease(ctx);
    CGImageRelease(proccessedImage);
    CGImageRelease(unclippedCG);
    CGImageRelease(resultCG);
    
    return result;
}

@end
