//
//  NSValue+ToString.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <TargetConditionals.h>

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#define SelfSTR (self.description.UTF8String)
#define RangeSTR(range) ([NSValue valueWithRange:(range)].description.UTF8String)
#define IntegerSTR(integer) ([NSNumber numberWithInteger:(integer)].description.UTF8String)
#define UIntegerSTR(uinteger) ([NSNumber numberWithUnsignedInteger:(uinteger)].description.UTF8String)
#define Transform3DSTR(transform3D) ([NSValue valueWithCATransform3D:(transform3D)].description.UTF8String)
#define EdgeInsetsSTR(edgeInsets) ([NSValue valueWithUIEdgeInsets:(edgeInsets)].description.UTF8String)
#define DirectionaryEdgeInsetsSTR(directionaryEdgeInsets) ([NSValue valueWithDirectionalEdgeInsets:(directionaryEdgeInsets)].description.UTF8String)
#define WritingDirectionSTR(direction) (((const char * []){"Natural", "LeftToRight", "RightToLeft"})[(direction) + 1])
#define BOOLSTR(b) ([NSNumber numberWithBool:(b)].description.UTF8String)
#define textStorageEditActionsSTR(editMask) (((const char * []){"attribute", "character", "attribute+character"})[(editMask)])
#define lineBreakModeSTR(mode) (((const char * []){"wordWraping(I am)", "charWraping(I am Bi)", "clipping(I am Bil)", "truncatedHead(...wxyz)", "truncatedTail(abcd...)", "truncatedMiddle(ab...yz)"})[(mode)])

#if TARGET_OS_IPHONE

#define UIStatusBarStyleSTR(style) ([NSValue ConvertUIStatusBarStyleToString:(style)].description.UTF8String)
#define RectSTR(rect) ([NSValue valueWithCGRect:(rect)].description.UTF8String)
#define SizeSTR(size) ([NSValue valueWithCGSize:(size)].description.UTF8String)
#define PointSTR(point) ([NSValue valueWithCGPoint:(point)].description.UTF8String)
#define VectorSTR(vector) ([NSValue valueWithCGVector:(vector)].description.UTF8String)
#define AffineTransformSTR(affineTransform) ([NSValue valueWithCGAffineTransform:(affineTransform)].description.UTF8String)
#define OffsetSTR(offset) ([NSValue valueWithUIOffset:(offset)].description.UTF8String)

#else

#define RectSTR(rect) ([NSValue valueWithRect:(rect)].description.UTF8String)
#define SizeSTR(size) ([NSValue valueWithSize:(size)].description.UTF8String)
#define PointSTR(point) ([NSValue valueWithPoint:(point)].description.UTF8String)
#define glyphGeneratorLayoutOptionsSTR(optionMask) ([NSValue glyphGeneratorLayoutOptionsToString:(optionMask)].description.UTF8String)

#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (ToString)

#if TARGET_OS_IPHONE

+ (NSString *)ConvertUIStatusBarStyleToString:(UIStatusBarStyle)style;

#else

+ (NSString *)glyphGeneratorLayoutOptionsToString:(NSUInteger)optionMask;

#endif

@end

NS_ASSUME_NONNULL_END
