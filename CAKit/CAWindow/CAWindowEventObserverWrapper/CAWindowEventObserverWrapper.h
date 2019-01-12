//
//  CAWindowEventObserverWrapper.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/12.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAWindowEventObserverWrapper : NSObject

@property(weak, readonly) id target;

@property(readonly) SEL selector;

- (instancetype)initWithTargert:(id)target selector:(SEL)selector; /* desingated */

@end
