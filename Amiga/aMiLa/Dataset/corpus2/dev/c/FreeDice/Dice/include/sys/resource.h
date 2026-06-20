
/*
 *  SYS/RUSAGE.H
 *
 */

#ifndef SYS_RESOURCE_H
#define SYS_RESOURCE_H

struct rtime {
    long tv_sec;
    long tv_usec;
};

struct rusage {
    struct rtime ru_utime;
    struct rtime ru_stime;
};

#endif
