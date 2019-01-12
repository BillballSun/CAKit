//
//  CAVerticalScrollView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/5.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAVerticalScrollView.h"
#import "CAExtended.h"

@interface CAVerticalScrollView ()
@property UIView *containerView;
@property NSMutableArray<NSArray<NSLayoutConstraint *> *> *contentConstraints;
@property BOOL needSetContentSizeAfterLayout;
@property CGFloat accumulatedHeight;
@end

@implementation CAVerticalScrollView

@synthesize needSpaceAtTop = _needSpaceAtTop, internalSpaceBetweenContents = _internalSpaceBetweenContents;

- (NSArray<UIView *> *)contents
{
    return self.containerView.subviews;
}

- (void)setNeedSpaceAtTop:(BOOL)needSpaceAtTop
{
    if(_needSpaceAtTop != needSpaceAtTop)
    {
        if(self.containerView.subviews.count >= 1)
        {
            if(needSpaceAtTop)
            {
                [NSLayoutConstraint deactivateConstraints:self.contentConstraints[0]];
                [self.contentConstraints replaceObjectAtIndex:0 withObject:[self.containerView.subviews[0] constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:self.internalSpaceBetweenContents]];
            }
            else
            {
                [NSLayoutConstraint deactivateConstraints:self.contentConstraints[0]];
                [self.contentConstraints replaceObjectAtIndex:0 withObject:[self.containerView.subviews[0] constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:0]];
            }
            [self.containerView setNeedsLayout];
        }
        _needSpaceAtTop = needSpaceAtTop;
    }
}

- (void)setInternalSpaceBetweenContents:(CGFloat)internalSpaceBetweenContents
{
    if(_internalSpaceBetweenContents != internalSpaceBetweenContents)
    {
        NSUInteger count = self.containerView.subviews.count;
        if(count >= 1 && self.needSpaceAtTop)
        {
            [NSLayoutConstraint deactivateConstraints:self.contentConstraints[0]];
            [self.contentConstraints replaceObjectAtIndex:0 withObject:[self.containerView.subviews[0] constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:_internalSpaceBetweenContents]];
        }
        if(count >= 2)
        {
            for(NSUInteger index = 1; index < count; index++)
            {
                [NSLayoutConstraint deactivateConstraints:self.contentConstraints[index]];
                [self.contentConstraints replaceObjectAtIndex:index withObject:[self.containerView.subviews[index] constraintBelowViewFixedHight:self.containerView.subviews[index - 1] internalSpace:_internalSpaceBetweenContents]];
            }
        }
        _internalSpaceBetweenContents = internalSpaceBetweenContents;
        [self.containerView setNeedsLayout];
    }
}

- (void)addContent:(UIView *)content
{
    NSUInteger count = self.containerView.subviews.count;
    [self.containerView addSubview:content];
    if(count == 0)
        [self.contentConstraints addObject:[content constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:self.needSpaceAtTop ? self.internalSpaceBetweenContents : 0]];
    else
        [self.contentConstraints addObject:[content constraintBelowViewFixedHight:self.containerView.subviews[count - 1] internalSpace:self.internalSpaceBetweenContents]];
    self.accumulatedHeight += content.height + (((count == 0 && self.needSpaceAtTop) || count > 0) ? self.internalSpaceBetweenContents : 0);
    self.contentSize = CGSizeMake(self.width, self.accumulatedHeight);
    [self.containerView setNeedsLayout];
}

- (void)addContent:(UIView *)content animated:(BOOL)animated
{
    NSUInteger count = self.containerView.subviews.count;
    [self.containerView addSubview:content];
    if(count == 0)
        [self.contentConstraints addObject:[content constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:self.needSpaceAtTop ? self.internalSpaceBetweenContents : 0]];
    else
        [self.contentConstraints addObject:[content constraintBelowViewFixedHight:self.containerView.subviews[count - 1] internalSpace:self.internalSpaceBetweenContents]];
    self.accumulatedHeight += content.height + (((count == 0 && self.needSpaceAtTop) || count > 0) ? self.internalSpaceBetweenContents : 0);
    self.contentSize = CGSizeMake(self.width, self.accumulatedHeight);
    [self.containerView setNeedsLayout];
}

- (void)removeContent:(UIView *)content
{
    if(![content isSubviewOf:self.containerView]) return;
    NSUInteger index = [self.containerView indexOfSubview:content];
    NSUInteger count = self.contentConstraints.count;
    [NSLayoutConstraint deactivateConstraints:self.contentConstraints[index]];
    if(index + 1 < count) [NSLayoutConstraint deactivateConstraints:self.contentConstraints[index + 1]];
    [self.contentConstraints removeObjectAtIndex:index];
    [self.containerView.subviews[index] removeFromSuperview];
    if(index + 1 < count)
    {
        [self.contentConstraints removeObjectAtIndex:index];
        if(index == 0)
            [self.contentConstraints insertObject:[self.containerView.subviews[index] constraintAtTopEqualWidthFixedHight:self.containerView internalSpace:self.needSpaceAtTop ? self.internalSpaceBetweenContents : 0] atIndex:index];
        else
            [self.contentConstraints insertObject:[self.containerView.subviews[index] constraintAtTopEqualWidthFixedHight:self.containerView.subviews[index - 1] internalSpace:self.internalSpaceBetweenContents] atIndex:index];
    }
    self.accumulatedHeight -= content.height + (((index == 0 && self.needSpaceAtTop) || index > 0) ? self.internalSpaceBetweenContents : 0);
    self.contentSize = CGSizeMake(self.width, self.accumulatedHeight);
    [self.containerView setNeedsLayout];
}

- (void)removeContentAtIndex:(NSUInteger)index;
{
    if(index >= self.containerView.subviews.count) return;
    [self removeContent:self.containerView.subviews[index]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
        [self additionalInitializationForCAVerticalScrollView];
    return self;
}

- (instancetype)init
{
    if(self = [super init])
        [self additionalInitializationForCAVerticalScrollView];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
        [self additionalInitializationForCAVerticalScrollView];
    return self;
}

- (void)additionalInitializationForCAVerticalScrollView
{
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    [self addSubview:self.containerView];
    self.containerView.clipsToBounds = NO;
    self.containerView.autoresizesSubviews = YES;
    self.containerView.autoresizingMask = UIViewAutoresizingNone;
    self.contentConstraints = [NSMutableArray array];
    self.contentSize = CGSizeMake(self.width, 0);
    self.contentOffset = CGPointMake(0, 0);
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.needSetContentSizeAfterLayout = NO;
    self.accumulatedHeight = 0;
    self.needSpaceAtTop = NO;
    self.internalSpaceBetweenContents = 0.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.needSetContentSizeAfterLayout = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.needSetContentSizeAfterLayout)
    {
        self.needSetContentSizeAfterLayout = NO;
        self.contentSize = CGSizeMake(self.width, self.accumulatedHeight);
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.containerView.width = bounds.size.width;
    CGSize contentSize = self.contentSize;
    contentSize.width = bounds.size.width;
    self.contentSize = contentSize;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.containerView.width = frame.size.width;
    CGSize contentSize = self.contentSize;
    contentSize.width = frame.size.width;
    self.contentSize = contentSize;
}

@end
