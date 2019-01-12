//
//  CAFluidDrawerDialogueView.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/7.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidDrawerDialogueView.h"
#import "CAExtended.h"

#define CAFluidDrawerDialogueViewPreferredContentAmount 4
#define CAFluidDrawerDialogueViewPreferredWidth 75.0
#define CAFluidDrawerDialogueViewPreferredEndianSpace 16
#define CAFluidDrawerDialogueViewPreferredInternalSpace 8

@interface CAFluidDrawerDialogueView ()
@property(readwrite) CGFloat endianSpace;
@property(readwrite) CGFloat internalSpace;
@end

@implementation CAFluidDrawerDialogueView

- (void)addContent:(nonnull __kindof UIView *)content
{
    [self addSubview:content];
    [self setNeedsLayout];
}

- (void)addContents:(NSArray<__kindof UIView *> *)contents
{
    for(UIView *each in contents)
        [self addSubview:each];
    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
        [self additionalInitialization];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
        [self additionalInitialization];
    return self;
}

- (instancetype)init
{
    if(self = [super init])
        [self additionalInitialization];
    return self;
}

- (void)additionalInitialization
{
    self.autoresizesSubviews = YES;
    self.preferredWidth = CAFluidDrawerDialogueViewPreferredWidth;
    self.endianSpace = CAFluidDrawerDialogueViewPreferredEndianSpace;
    self.internalSpace = CAFluidDrawerDialogueViewPreferredInternalSpace;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    NSUInteger count = self.subviews.count;
    if(count == 0) return;
    
    NSArray<UIView *> *subViews = self.subviews;
    CGFloat endianSpace = self.endianSpace;
    CGFloat internalSpace = self.internalSpace;
    CGFloat preferredWidth = self.preferredWidth;
    CGSize layoutSpace = self.frame.size;
    
    if(count == 1)
    {
        if(layoutSpace.width >= preferredWidth)
            [subViews[0] setSize:CGSizeMake(preferredWidth, layoutSpace.height) center:CGPointMake(layoutSpace.width / 2, layoutSpace.height / 2)];
        else
            subViews[0].frame = CGRectMake(0, 0, layoutSpace.width, layoutSpace.height);
    }
    else
    {
        if(count * preferredWidth + (count - 1) * internalSpace + endianSpace * 2 <= layoutSpace.width)
            internalSpace = (layoutSpace.width - endianSpace * 2 - count * preferredWidth)/(count - 1);
        else if(count * preferredWidth + (count + 1) * MIN(internalSpace, endianSpace) <= layoutSpace.width)
        {
            if(internalSpace > endianSpace)
                internalSpace = (layoutSpace.width - count * preferredWidth - 2 * endianSpace) / (count - 1);
            else
                endianSpace = (layoutSpace.width - count * preferredWidth - (count - 1) * internalSpace) / 2;
        }
        else if(count * preferredWidth <= layoutSpace.width)
        {
            internalSpace = (layoutSpace.width - count * preferredWidth) / (count + 1);
            endianSpace = internalSpace;
        }
        else
        {
            internalSpace = 0;
            endianSpace = 0;
            preferredWidth = layoutSpace.width / count;
        }
        for(NSUInteger index = 0; index < count; index++)
            subViews[index].frame = CGRectMake(endianSpace + (preferredWidth + internalSpace) * index, 0, preferredWidth, layoutSpace.height);
    }
}

@end


















































