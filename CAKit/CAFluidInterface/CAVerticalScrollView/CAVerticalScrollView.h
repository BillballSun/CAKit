//
//  CAVerticalScrollView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAScrollView.h"

@interface CAVerticalScrollView : CAScrollView

@property(readonly) NSArray<UIView *> *contents;

@property(nonatomic) CGFloat internalSpaceBetweenContents;

@property(nonatomic) BOOL needSpaceAtTop;

- (void)addContent:(UIView *)content;

- (void)addContent:(UIView *)content animated:(BOOL)animated;

- (void)removeContent:(UIView *)content;

- (void)removeContentAtIndex:(NSUInteger)index;

@end
