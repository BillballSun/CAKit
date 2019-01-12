//
//  CAPthreadDispatchWork.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/11/17.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import <pthread.h>

#import "CAPthreadDispatchWork.h"
#import "CAThread.h"

#define MysteryNumber 42    // used to initial resourcesArray (MSMutableArray) capacity initialization size
#define LOOP for(;;)

@interface CAPthreadDispatchWork ()

/* Lock Access begin */
@property(readwrite, assign, nonatomic) pthread_mutex_t _threadMutex;
@property(readwrite, assign, nonatomic) pthread_cond_t _threadDataChangeCondition;
@property(readwrite, assign, nonatomic) pthread_cond_t _threadLifeStatusCondition;  /* this is only used for thread callback and received exit */
@property(readwrite, retain, nonatomic) NSMutableArray *_resourcesArray;
@property(readwrite, assign, nonatomic, getter=isDispatchActive) BOOL _dispatchActive;
@property(readwrite, assign, nonatomic) BOOL _threadDidCallBack;
@property(readwrite, assign, nonatomic) BOOL *_threadShouldExit;
/* Lock Access end */

/* terminate Lock */
@property(readwrite, assign, nonatomic) pthread_mutex_t _activeTerminateMutex;

@property(readwrite, weak, nonatomic) id target;
@property(readwrite, assign, nonatomic) SEL selector;

@end

@implementation CAPthreadDispatchWork

@synthesize _threadMutex = __threadMutex,
            _activeTerminateMutex = __activeTerminateMutex,
            _threadDataChangeCondition = __threadDataChangeCondition,
            _threadLifeStatusCondition = __threadLifeStatusCondition;

- (instancetype)initWithTarget:(id)target selector:(nonnull SEL)sel
{
    if(self = [super init])
    {
        /* access & terminate mutex creation */
        pthread_mutexattr_t mutexAttr;
        pthread_mutexattr_init(&mutexAttr);
        pthread_mutex_init(&__threadMutex, &mutexAttr);
        pthread_mutex_init(&__activeTerminateMutex, &mutexAttr);
        pthread_mutexattr_destroy(&mutexAttr);
        
        /* condition creation */
        pthread_condattr_t condAttr;
        pthread_condattr_init(&condAttr);
        pthread_cond_init(&__threadDataChangeCondition, &condAttr);
        pthread_cond_init(&__threadLifeStatusCondition, &condAttr);
        pthread_condattr_destroy(&condAttr);

        self._dispatchActive = NO;
        self._threadDidCallBack = NO;
        self._threadShouldExit = NULL; /* intialization is not much useful */
        self._resourcesArray = [[NSMutableArray alloc] initWithCapacity:MysteryNumber];

        self.target = target;
        self.selector = sel;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)dealloc
{
    [self stopDispatch];
    pthread_mutex_destroy(&__threadMutex);
    pthread_cond_destroy(&__threadLifeStatusCondition);
    pthread_cond_destroy(&__threadDataChangeCondition);
    pthread_mutex_destroy(&__activeTerminateMutex);
}

- (void)threadEntrance
{
    pthread_mutex_lock(&__threadMutex);
    BOOL threadShouldExit = NO;
    self._threadDidCallBack = YES;
    self._threadShouldExit = &threadShouldExit;
    pthread_cond_broadcast(&__threadLifeStatusCondition);
    pthread_mutex_unlock(&__threadMutex);
    
    LOOP
    {
        POSIX_COND(!threadShouldExit && self._resourcesArray.count == 0, __threadDataChangeCondition, __threadMutex);

        if(threadShouldExit)
        {
            self._dispatchActive = NO;
            pthread_cond_broadcast(&__threadLifeStatusCondition);
            pthread_mutex_unlock(&__threadMutex);
            return;
        }

        id resource = self._resourcesArray[0];
        [self._resourcesArray removeObjectAtIndex:0];
        pthread_mutex_unlock(&__threadMutex);
        ((void (*)(id, SEL, id))objc_msgSend)(self.target, self.selector, resource);
    }
}

#pragma mark - Configuration

- (void)activeDispatch
{
    pthread_mutex_lock(&__activeTerminateMutex);
    BOOL shouldActive = NO;
    pthread_mutex_lock(&__threadMutex);
        if(!self._dispatchActive)
        {
            self._dispatchActive = YES;
            self._threadDidCallBack = NO;
            self._threadShouldExit = NULL;
            shouldActive = YES;
        }
    pthread_mutex_unlock(&__threadMutex);
    if(shouldActive)
        [NSThread detachNewThreadSelector:@selector(threadEntrance) toTarget:self withObject:nil];
    pthread_mutex_unlock(&__activeTerminateMutex);
}

- (void)stopDispatch
{
    pthread_mutex_lock(&__activeTerminateMutex);
    pthread_mutex_lock(&__threadMutex);
    if(self._dispatchActive)
    {
        if(self._threadDidCallBack)
        {
            if(!*self._threadShouldExit)
            {
                *self._threadShouldExit = YES;
                pthread_cond_broadcast(&__threadDataChangeCondition);
                POSIX_COND(!self._dispatchActive, __threadLifeStatusCondition, __threadMutex);  /* only dispatchWork: would happen */
            }
        }
        else
        {
            POSIX_COND(self._threadDidCallBack, __threadLifeStatusCondition, __threadMutex);    /* only dispatchWork: would happen */
            *self._threadShouldExit = YES;
            pthread_cond_broadcast(&__threadDataChangeCondition);
        }
    }
    pthread_mutex_unlock(&__threadMutex);
    pthread_mutex_unlock(&__activeTerminateMutex);
}

- (void)dispatchWork:(id)resource
{
    pthread_mutex_lock(&__threadMutex);
    [self._resourcesArray addObject:resource];
    pthread_cond_broadcast(&__threadDataChangeCondition);
    pthread_mutex_unlock(&__threadMutex);
}

#pragma mark - Access status

- (BOOL)isActive
{
    pthread_mutex_lock(&__threadMutex);
    BOOL result = self._dispatchActive;
    pthread_mutex_unlock(&__threadMutex);
    return result;
}

- (NSArray *)remainWork
{
    pthread_mutex_lock(&__threadMutex);
    NSArray *result = [self._resourcesArray copy];
    pthread_mutex_unlock(&__threadMutex);
    return result;
}

@end
