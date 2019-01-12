//
//  CAWindowEventObserving.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/12.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CAWindowEventObserving <NSObject>

@property(readonly, nonatomic) NSArray *eventObservers;

- (void)addEventObserver:(id)observer selector:(SEL)selector;
/* Parameters */
    // selector
    // selector must take and only take one single parameter UIEvent *
/* Discussion */
    // Events are dispatch before the events dispatch to the view hierachies
    // CAWindow will not keep ownership to your object

- (void)removeEventObserver:(id)observer;

- (void)removeEventObserver:(id)observer selector:(SEL)selector;

- (void)removeAllEventObserver:(id)observer;

@end
