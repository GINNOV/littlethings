#ifndef _TIMEB_H
#define _TIMEB_H

struct timeb
{
  time_t   time;
  unsigned short millitm;
  short    timezone;
  short    dstflag;
};

#endif
