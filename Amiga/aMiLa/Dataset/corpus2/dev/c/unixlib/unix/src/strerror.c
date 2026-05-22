#include <errno.h>

static char *uerr = "Unknown error code";

char *strerror(int err)
{
    if (err >= 0 && err <= sys_nerr)
	return sys_errlist[err];

    return uerr;
}
