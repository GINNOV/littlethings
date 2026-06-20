/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: gmtime_r.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#include <time.h>

struct tm *gmtime_r(const time_t *timer, struct tm *result)
{
	struct tm *local_result = gmtime(timer);
	if(local_result == NULL || result == NULL)
		return NULL;
	*result = *local_result;
	return result;
}
