//
//  CAFluidDrawerDialogueView.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/9/7.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAFluidDrawerDialogueView : UIView
@property(nonatomic, assign) CGFloat preferredWidth;

- (void)addContent:(nonnull __kindof UIView *)content;

- (void)addContents:(NSArray<__kindof UIView *> *)contents;

@end
