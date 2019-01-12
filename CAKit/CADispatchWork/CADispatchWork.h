//
//  CADispatchWork.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/11/18.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CADispatchWork <NSObject>

- (instancetype)initWithTarget:(id)target selector:(nonnull SEL)selector; /* designated intializer */

#pragma mark - Dispatch work

- (void)activeDispatch;

- (void)stopDispatch;

- (void)dispatchWork:(id)resource;

#pragma mark - Access status

@property(nonatomic, readonly, assign, getter=isActive) BOOL active;

@property(nonatomic, readonly) NSArray *remainWork;

@property(nonatomic, readonly, weak) id target;

@property(nonatomic, readonly, assign) SEL selector;

@end

NS_ASSUME_NONNULL_END
