#include "amiga.h"
#include "timeconvert.h"
#include <sys/time.h>
#include <sys/timeb.h>
#include <string.h>

extern char *tzname[2];
extern int daylight;

int gettimeofday(struct timeval *tp, struct timezone *tzp)
{
  struct timeval now;

  chkabort();

  _gettime(&now);
  if (tp) *tp = now;

  if (tzp)
    {
      int dst;
      struct tm *local;

      local = localtime(&now.tv_secs);
      
      tzp->tz_minuteswest = -local->tm_gmtoff / 60;
      /* Guess a value for tz_dsttime, based on tzname[1] */
      /* These guesses are not very good. */
      dst = DST_NONE;
      if (!strcmp(tzname[1], "MET DST")) dst = DST_MET;
      else if (!strcmp(tzname[1], "WET DST")) dst = DST_WET;
      else if (!strcmp(tzname[1], "EET DST")) dst = DST_EET;
      else if (!strcmp(tzname[1], "EDT")) dst = DST_USA;
      else if (!strcmp(tzname[1], "CDT")) dst = DST_USA;
      else if (!strcmp(tzname[1], "MDT")) dst = DST_USA;
      else if (!strcmp(tzname[1], "PDT")) dst = DST_USA;
      else if (!strcmp(tzname[1], "AKDT")) dst = DST_USA;
      tzp->tz_dsttime = dst;
    }
  return 0;
}

int ftime(struct timeb *ft)
{
  struct timeval now;
  struct timezone zone;

  gettimeofday(&now, &zone);
  ft->time = now.tv_sec;
  ft->millitm = now.tv_usec;
  ft->timezone = zone.tz_minuteswest;
  ft->dstflag = daylight;

  return 0;
}
