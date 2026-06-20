/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2004
 *
 * $Id: time.h,v 1.2 2021/07/28 14:40:31 phx Exp $
 */

#ifndef _TIME_H_
#define _TIME_H_

#include_next <time.h>


struct timespec {
        time_t  tv_sec;         /* seconds */
        long    tv_nsec;        /* and nanoseconds */
};


/* Prototypes */
struct tm *gmtime_r(const time_t *timer, struct tm *result);
struct tm *localtime_r(const time_t *timer, struct tm *result);
void tzset(void);

#endif /* _TIME_H_ */
