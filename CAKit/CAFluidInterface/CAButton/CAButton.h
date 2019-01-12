//
//  CAButton.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/7.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CAButtonDelegate <NSObject>
@optional

- (void)buttonWillTransistFromNormalView:(UIView *)normal toHighlightedView:(UIView *)highlighted;

- (void)buttonWillTransistFromHighlightedView:(UIView *)normal toNormalView:(UIView *)highlighted;

@end

@interface CAButton : UIControl

- (instancetype)initWithNormalView:(nonnull UIView *)normal highlightedView:(nonnull UIView *)highlight;

@property id<CAButtonDelegate> delegate;

@end
