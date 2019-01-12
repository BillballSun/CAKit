//
//  UIResponder+FindFirstResponder.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/6/25.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (FindFirstResponder)

- (__kindof UIResponder *)findFirstResponder;

@end
