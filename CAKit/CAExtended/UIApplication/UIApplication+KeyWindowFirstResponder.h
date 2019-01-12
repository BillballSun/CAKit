//
//  UIApplication+KeyWindowFirstResponder.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/6/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (KeyWindowFirstResponder)

@property(readonly, nonatomic, class) UIResponder *keyWindowFirstResponder;

@end
