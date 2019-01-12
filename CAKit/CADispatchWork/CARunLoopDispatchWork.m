//
//  CARunLoopDispatchWork.m
//  CaptainAllred
//
//  Created by Bill Sun on 2018/11/18.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <objc/message.h>

#import "CARunLoopDispatchWork.h"
#import "NSException+ExtendedName.h"

#define MysteryNumber 42    // used to initial resourcesArray (MSMutableArray) capacity initialization size
#define LOOP for(;;)

#define POSIX_COND(condition, pthread_cond, pthread_mutex) do { pthread_mutex_lock(&pthread_mutex); while(condition) pthread_cond_wait(&pthread_cond, &pthread_mutex);} while(0)

static void runLoopSourcePerformHandle(void *);

@interface CARunLoopDispatchWork()

/* Lock Access begin */
@property(readwrite, retain, nonatomic) NSCondition *_accessLock;
@property(readwrite, retain, nonatomic) NSLock *_activeTerminateLock;
@property(readwrite, retain, nonatomic) NSMutableArray *_resourcesArray;
@property(readwrite, assign, nonatomic, getter=isDispatchActive) BOOL _dispatchActive;
@property(readwrite, assign, nonatomic) CFRunLoopRef _threadRunLoop;
@property(readwrite, assign, nonatomic) BOOL _threadDidCallback;
@property(readwrite, assign, nonatomic) BOOL _threadShouldExit;
/* Lock Access end */

@property(readwrite, weak, nonatomic) id target;
@property(readwrite, assign, nonatomic) SEL selector;
@property(readwrite, assign, nonatomic) CFRunLoopSourceRef _runLoopResource;    /* ownership retained */

@end

@implementation CARunLoopDispatchWork

@synthesize _accessLock = __accessLock, _runLoopResource = __runLoopResource;

- (instancetype)initWithTarget:(id)target selector:(nonnull SEL)sel
{
    if(self = [super init])
    {
        /* lock creation */
        self._accessLock = [[NSCondition alloc] init];
        self._activeTerminateLock = [[NSLock alloc] init];
        
        self._dispatchActive = NO;
        self._threadShouldExit = NO;
        self._threadDidCallback = NO;
        self._threadRunLoop = NULL;
        self._resourcesArray = [[NSMutableArray alloc] initWithCapacity:MysteryNumber];
        
        /* RunLoop Resources */
        CFRunLoopSourceContext ctx = {
            .version = 0,
            .info = (__bridge void *)self,
            .copyDescription = NULL,
            .equal = NULL,
            .schedule = NULL,
            .cancel = NULL,
            .perform = runLoopSourcePerformHandle
        };
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 1, &ctx);
        if(source == NULL) [NSException exceptionWithName:CAProcessFailed
                                                   reason:@"[CARunLoopDispatchWork initWithTarget:selector:] create CFRunLoopSource failed"
                                                 userInfo:nil];
        
        self._runLoopResource = source;
        CFRelease(source);
        
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

#pragma mark - Configuration

- (void)activeDispatch
{
    [self._activeTerminateLock lock];
    BOOL shouldActive = NO;
    [self._accessLock lock];
    if(!self._dispatchActive)
    {
        self._dispatchActive = YES;
        self._threadShouldExit = NO;
        self._threadDidCallback = NO;
        self._threadRunLoop = NULL;
        shouldActive = YES;
    }
    [self._accessLock unlock];
    
    if(shouldActive)
        [NSThread detachNewThreadSelector:@selector(threadEntrance) toTarget:self withObject:nil];
    [self._activeTerminateLock unlock];
}

#pragma mark - Access status

- (BOOL)isActive
{
    [self._accessLock lock];
    BOOL result = self._dispatchActive;
    [self._accessLock unlock];
    return result;
}

- (NSArray *)remainWork
{
    [self._accessLock lock];
    NSArray *result = [self._resourcesArray copy];
    [self._accessLock unlock];
    return result;
}

- (void)set_runLoopResource:(CFRunLoopSourceRef)runLoopResource {
    CFRetain(runLoopResource);
    if(__runLoopResource != NULL)
        CFRelease(__runLoopResource);
    __runLoopResource = runLoopResource;
}

- (CFRunLoopSourceRef)_runLoopResource {
    return __runLoopResource;
}

- (void)dealloc
{
    if(self._runLoopResource != NULL) CFRelease(self._runLoopResource);
}

- (void)threadEntrance
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    [self._accessLock lock];
    self._threadDidCallback = YES;
    self._threadRunLoop = runLoop;
    CFRunLoopAddSource(runLoop, self._runLoopResource, kCFRunLoopDefaultMode);
    [self._accessLock broadcast];
    [self._accessLock unlock];
    CFRunLoopRun();
    [self._accessLock lock];
    self._dispatchActive = NO;
    [self._accessLock unlock];
}

- (void)stopDispatch
{
    [self._activeTerminateLock lock];
    [self._accessLock lock];
    if(self._dispatchActive && self._threadDidCallback && !self._threadShouldExit)
    {
        if(!self._threadDidCallback)
        {
            do [self._accessLock wait]; while(!self._threadDidCallback);    /* in wait, only dispatchWork: could happen */
            self._threadShouldExit = YES;
            CFRunLoopRemoveSource(self._threadRunLoop, self._runLoopResource, kCFRunLoopDefaultMode);
            CFRunLoopWakeUp(self._threadRunLoop);
        }
        else if(!self._threadShouldExit)
        {
            self._threadShouldExit = YES;
            CFRunLoopRemoveSource(self._threadRunLoop, self._runLoopResource, kCFRunLoopDefaultMode);
            CFRunLoopWakeUp(self._threadRunLoop);
        }
    }
    [self._accessLock unlock];
    [self._activeTerminateLock unlock];
}

- (void)dispatchWork:(id)resource
{
    [self._accessLock lock];
    [self._resourcesArray addObject:resource];
    if(self._dispatchActive)
    {
        while(self._dispatchActive && !self._threadDidCallback) [self._accessLock wait];
        
        if(self._dispatchActive && !self._threadShouldExit)
        {
            CFRunLoopSourceSignal(self._runLoopResource);
            CFRunLoopWakeUp(self._threadRunLoop);
        }
    }
    [self._accessLock unlock];
}

@end

static void runLoopSourcePerformHandle(void *info)
{
    CARunLoopDispatchWork *work = (__bridge CARunLoopDispatchWork *)info;
    [work._accessLock lock];
    NSArray *workArr = [work._resourcesArray copy];
    [work._resourcesArray removeAllObjects];
    [work._accessLock unlock];
    
    for(id eachResource in workArr)
        ((void (*)(id, SEL, id))objc_msgSend)(work.target, work.selector, eachResource);
}
