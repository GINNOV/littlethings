#include "amiga.h"
#include "timeconvert.h"
#include <time.h>
#include <proto/timer.h>

int _gettime(struct timeval *tp)
{
#ifdef USE_LOCAL
    struct tm *local;
    time_t gmt;
#endif

    GetSysTime(tp);
    /* Correct for different epoch (78 vs 70) */
    tp->tv_secs += 252460800;

#ifdef USE_LOCAL
    /* correct for timezone */
    local = gmtime(&now.tv_secs);
    local->tm_isdst = -1;	/* We don't know about dst */
    gmt = mktime(local);

    if (gmt == -1) {
	errno = EINVAL;
	return -1;
    }
    tp->tv_secs = gmt;
#endif
    return 0;
}

#ifdef USE_LOCAL

/* System is storing local time */

void _gmt2amiga(time_t time, struct DateStamp *date)
{
    struct tm *local, *gmt;

    local = localtime(&time);
    gmt = gmtime(&time);
    date->ds_Tick = 50 * local->tm_sec;
    date->ds_Minute = local->tm_min + local->tm_hour * 60;

    /* Now calculate the day assuming we are in GMT */
    date->ds_Days = (time - 252460800) / 86400;
    /* And correct by comparing local with GMT */
    if (local->tm_year < gmt->tm_year ||
	local->tm_year == gmt->tm_year && local->tm_yday < gmt->tm_yday)
	date->ds_Days--;
    if (local->tm_year > gmt->tm_year ||
	local->tm_year == gmt->tm_year && local->tm_yday > gmt->tm_yday)
	date->ds_Days++;
}

time_t _amiga2gmt(struct DateStamp *date)
{
    struct tm *local;
    time_t secs;

    secs = date->ds_Tick / 50 + date->ds_Minute * 60 + date->ds_Days * 86400 +
	252460800;
    local = gmtime(&secs);
    local->tm_isdst = -1;	/* We don't know about dst */

    return mktime(local);
}

#else

/* System is storing GMT */
/* Leap seconds are not handled !! */

void _gmt2amiga(time_t time, struct DateStamp *date)
{
    time_t time78, day_secs;

    time78 = time - 252460800;	/* Change Epoch */
    date->ds_Days = time78 / 86400;
    day_secs = time78 % 86400;
    date->ds_Minute = day_secs / 60;
    date->ds_Tick = 50 * (day_secs % 60);
}

time_t _amiga2gmt(struct DateStamp *date)
{
    time_t secs;

    secs = date->ds_Tick / 50 + date->ds_Minute * 60 + date->ds_Days * 86400 +
	252460800;

    return secs;
}

#endif
