#include <time.h>

struct tm *localtime_r(const time_t *timer, struct tm *result)
{
	struct tm *local_result = localtime(timer);
	if(local_result == NULL || result == NULL)
		return NULL;
	*result = *local_result;
	return result;
}
