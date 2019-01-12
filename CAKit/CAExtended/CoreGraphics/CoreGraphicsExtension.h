//
//  CoreGraphicsExtension.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#ifndef CoreGraphicsExtension_h
#define CoreGraphicsExtension_h

#include <CoreFoundation/CoreFoundation.h>
#include <CoreGraphics/CoreGraphics.h>

CGRect CGRectContainRect(CGRect outside, CGRect inside);

CGRect CGRectCombine(CGRect one, CGRect another);

#endif /* CoreGraphicsExtension_h */
