//
//  CAFluidControl.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/3.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import "CAFluidControl.h"

@implementation CAFluidControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragExit|UIControlEventTouchCancel];
    }
    return self;
}

- (void)touchDown
{
    /* stop previous animation, turn to highlight instantly */
    /* animation should run with interactionEnabled */
}

- (void)touchUp
{
    /* create fade out highlight animation to normal status */
}

@end
