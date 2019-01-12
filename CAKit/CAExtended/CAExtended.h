//
//  CAExtended.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/6/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#ifndef CAExtended_h
#define CAExtended_h

#ifdef TARGET_OS_IPHONE
#import "UIApplication/UIApplication+KeyWindowFirstResponder.h"
#import "UIResponder/UIResponder+FindFirstResponder.h"
#import "UIView/UIView+ViewHierachy.h"
#import "UIView/UIView+Coordination.h"
#import "UIView/UIView+ContentDrawing.h"
#import "UIView/UIView+Animation.h"
#import "UIImage/UIImage+PlainImage.h"
#import "UIImage/UIImage+DisplayInView.h"
#import "UIImage/UIImage+Effect.h"
#import "UIImage+SimpleGraphics.h"
#else
#endif

#import "CoreGraphics/CoreGraphicsExtension.h"
#import "NSValue/NSValue+ToString.h"

#endif /* CAExtended_h */
