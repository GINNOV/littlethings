#ifndef _INCLUDE_TIME_H
#define _INCLUDE_TIME_H

typedef unsigned time_t;
typedef unsigned clock_t;

struct tm
{ int tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year,
      tm_wday, tm_yday, tm_isdst;
};

time_t time(time_t*);
struct tm *gmtime(const time_t*);
struct tm *localtime(const time_t*);
time_t mktime(struct tm*);

#define CLOCKS_PER_SEC 50
clock_t clock(void);
double difftime(time_t, time_t);

int strftime(char *, unsigned, const char*, const struct tm*);
char *asctime(const struct tm*);
char *ctime(const time_t *);

#endif

