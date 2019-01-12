//
//  CAWindow.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/8.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAWindowEventObserving.h"

/* not multi-threading */

@interface CAWindow : UIWindow <CAWindowEventObserving>
@end
