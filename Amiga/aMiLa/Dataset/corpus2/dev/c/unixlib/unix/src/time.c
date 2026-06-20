#include "amiga.h"
#include "timeconvert.h"

time_t time(time_t * clock)
{
    struct timeval now;

    if (_gettime(&now) < 0)
	return -1;
    if (clock)
	*clock = now.tv_secs;

    return (time_t) now.tv_secs;
}
