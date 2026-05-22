#include "amiga.h"

int symlink(const char *from, const char *to)
{
    __chkabort();
    if(MakeLink(to, (long)from, LINK_SOFT))
	return 0;
    ERROR;
}
