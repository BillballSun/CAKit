//
//  CAButton.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/7.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAButton.h"
#import "CAExtended.h"

@interface CAButton ()
@property(weak) UIView *normalView;
@property(weak) UIView *highlightedView;
@end

@implementation CAButton

- (instancetype)initWithNormalView:(nonnull UIView *)normal highlightedView:(nonnull UIView *)highlight
{
    if(self = [super initWithFrame:CGRectZero])
    {
        [self addSubview:normal];
        [self addSubview:highlight];
        self.normalView = normal;
        self.highlightedView = highlight;
        
        [normal constraintEqualToView:self];
        [highlight constraintEqualToView:self];
        
        self.autoresizesSubviews = YES;
        
        highlight.hidden = YES;
        self.multipleTouchEnabled = NO;
        
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        
        self.highlighted = NO;
    }
    return self;
}

- (void)touchDown
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(buttonWillTransistFromNormalView:toHighlightedView:)])
        [self.delegate buttonWillTransistFromNormalView:self.normalView toHighlightedView:self.highlightedView];
    self.normalView.hidden = YES;
    self.highlightedView.hidden = NO;
    self.highlighted = NO;
}

- (void)touchUp
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(buttonWillTransistFromHighlightedView:toNormalView:)])
        [self.delegate buttonWillTransistFromHighlightedView:self.highlightedView toNormalView:self.normalView];
    self.normalView.hidden = NO;
    self.highlightedView.hidden = YES;
    self.highlighted = YES;
}

@end
