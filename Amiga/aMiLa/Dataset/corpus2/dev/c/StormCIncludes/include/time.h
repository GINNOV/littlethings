#ifndef _INCLUDE_TIME_H
#define _INCLUDE_TIME_H

/*
**  $VER: time.h 2.0 (22.08.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

struct tm
{
    int tm_sec, tm_min, tm_hour;
    int tm_mday, tm_mon, tm_year;
    int tm_wday, tm_yday;
    int tm_isdst;
};
#define tm_idst tm_isdst

time_t time(time_t *);
struct tm *gmtime(const time_t *);
struct tm *localtime(const time_t *);
time_t mktime(struct tm *);

#define CLOCKS_PER_SEC 50
clock_t clock(void);
double difftime(time_t, time_t);

size_t strftime(char *, size_t, const char *, const struct tm *);
char *asctime(const struct tm *);
char *ctime(const time_t *);

#ifdef __cplusplus
}
#endif

#endif  /* _INCLUDE_TIME_H */
