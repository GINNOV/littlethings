
#include "amiga.h"

int chmod(const char *name, int mode)
{
    __chkabort();
    if (SetProtection(name, _make_protection(mode)))
	return 0;
    ERROR;
}
