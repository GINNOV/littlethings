/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003
 *
 * $Id: time.h,v 1.4 2021/07/28 14:40:31 phx Exp $
 */

#ifndef _SYS_TIME_H_
#define _SYS_TIME_H_

#include <time.h>

/* workaround to coexist with AmigaOS timeval structure */
#ifndef TIMERNAME /* defined in devices/timer.h */
struct timeval {
        long    tv_sec;         /* seconds */
        long    tv_usec;        /* and microseconds */
};
#else
#define tv_sec tv_secs
#define tv_usec tv_micro
#endif

#define TIMEVAL_TO_TIMESPEC(tv, ts) {                                   \
        (ts)->tv_sec = (tv)->tv_sec;                                    \
        (ts)->tv_nsec = (tv)->tv_usec * 1000;                           \
}
#define TIMESPEC_TO_TIMEVAL(tv, ts) {                                   \
        (tv)->tv_sec = (ts)->tv_sec;                                    \
        (tv)->tv_usec = (ts)->tv_nsec / 1000;                           \
}

struct timezone {
        int tz_minuteswest;     /* minutes west of Greenwich */
        int tz_dsttime;         /* type of dst correction */
};

#define DST_NONE  0  /* not on dst */
#define DST_USA   1  /* USA style dst */
#define DST_AUST  2  /* Australian style dst */
#define DST_WET   3  /* Western European dst */
#define DST_MET   4  /* Middle European dst */
#define DST_EET   5  /* Eastern European dst */
#define DST_CAN   6  /* Canada dst */


/* Prototypes */

int futimes(int,const struct timeval *);
int gettimeofday(struct timeval *,void *);
int utimes(const char *,const struct timeval *);
int settimeofday(const struct timeval *,void *);

#endif /* _SYS_TIME_H_ */
