#ifndef TIME_H
#define TIME_H 1


struct tm
{
short tm_sec;
short tm_min;
short tm_hour;
short tm_mday;
short tm_mon;
short tm_year;
short tm_wday;
short tm_yday;
short tm_isdst;
short tm_hsec;
};

#ifndef STDIO_H
#include "stdio.h"
#endif

#ifndef __TIME_T
#define __TIME_T 1
typedef long time_t;
#endif

#ifndef __CLOCK_T
#define __CLOCK_T 1
typedef long clock_t;
#endif

#define CLK_TCK 1
#define CLOCK_TCK CLK_TCK

#ifdef ANSIC

clock_t clock(void);
time_t time(time_t *);
long difftime(time_t,time_t);
time_t mktime(struct tm *);
char *asctime(struct tm *);
char *ctime(time_t *);
struct tm *gmtime(time_t *);
struct tm *localtime(time_t *);
size_t strftime(char *,size_t,char *,struct tm *);

#else

clock_t clock();
time_t time();
long difftime();
time_t mktime();
char *asctime();
char *ctime();
struct tm *gmtime();
struct tm *localtime();
size_t strftime();

#endif

#endif

