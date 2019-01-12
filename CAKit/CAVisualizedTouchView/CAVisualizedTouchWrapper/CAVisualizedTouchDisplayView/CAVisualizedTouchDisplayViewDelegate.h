//
//  CAVisualizedTouchDisplayViewDelegate.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/13.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CAVisualizedTouchDisplayView;

@protocol CAVisualizedTouchDisplayViewDelegate <NSObject>
@optional

- (void)touchDisplayViewDidCompleteFinalizeAnimation:(CAVisualizedTouchDisplayView *)displayView;

@end
