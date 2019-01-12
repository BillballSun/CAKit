//
//  CAThread.h
//  CaptainAllred
//
//  Created by Bill Sun on 2018/11/18.
//  Copyright © 2018 Bill Sun. All rights reserved.
//

#ifndef CAThread_h
#define CAThread_h

#define POSIX_COND(condition, pthread_cond, pthread_mutex) do { \
    pthread_mutex_lock(&pthread_mutex);                         \
    while(condition)                                            \
        pthread_cond_wait(&pthread_cond, &pthread_mutex);       \
    } while(0)

#endif /* CAThread_h */
