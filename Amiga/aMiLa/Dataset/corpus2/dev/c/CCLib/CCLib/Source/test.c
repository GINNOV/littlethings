#define ANSIC 1

#include "stdio.h"
#include "time.h"

short _math = 0;

void main(long argc, char *argv[])
{
time_t t;
struct tm *tm;
char buf[80];
t = time(0L);
tm = localtime(&t);
strftime(buf,79,"%A %B, %d %Y %I:%M %p",tm);
printf("%s\n",buf);
}

