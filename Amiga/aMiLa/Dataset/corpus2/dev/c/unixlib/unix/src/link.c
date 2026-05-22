#include "amiga.h"

int link(const char *from, const char *to)
{
    BPTR from_lock = Lock(from, ACCESS_READ);

    __chkabort();
    if (from_lock) {
	int ok = MakeLink(to, from_lock, LINK_HARD);

	UnLock(from_lock);
	if (ok)
	    return 0;
    }
    ERROR;
}
