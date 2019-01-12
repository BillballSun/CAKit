//
//  CATestMethodHierachy.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/8/17.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>

#define CATestInfoBegin(message) [CATestMethodHierachy goDeepIntoAndOutputSpace], fprintf(stdout, ""message"\n")
#define CATestInfoBeginWithFormat(message, ...) [CATestMethodHierachy goDeepIntoAndOutputSpace], fprintf(stdout, ""message"\n", __VA_ARGS__)
#define CATestInfoEnd() [CATestMethodHierachy comeout]
#define CATestInfoResult(message) \
do {[CATestMethodHierachy goDeepIntoAndOutputSpace]; fprintf(stdout, ""message"\n"); [CATestMethodHierachy comeout];} while(0)
#define CATestInfoResultWithFormat(message, ...) \
do {[CATestMethodHierachy goDeepIntoAndOutputSpace]; fprintf(stdout, ""message"\n", __VA_ARGS__); [CATestMethodHierachy comeout];} while(0)

/* obstole */
//#define CATestInfo(message, ...)                                            \
//do                                                                          \
//{                                                                           \
//CATestInfoBegin(message),                                                   \
//((void(*)(struct objc_super *, SEL, ...))objc_msgSendSuper)                 \
//(&(struct objc_super)                                                       \
//{.receiver = self,                                                          \
//.super_class = class_getSuperclass(self.class)},                            \
//_cmd, __VA_ARGS__);                                                         \
//CATestInfoEnd();                                                            \
}while (0)

@interface CATestMethodHierachy : NSObject

+ (void)begin;

+ (void)commit;

+ (NSUInteger)goDeepInto;

+ (void)comeout;

+ (NSUInteger)goDeepIntoAndOutputSpace;

+ (NSUInteger)currentDepth;

+ (NSUInteger)outputCurrentDepthSpace;

@end
