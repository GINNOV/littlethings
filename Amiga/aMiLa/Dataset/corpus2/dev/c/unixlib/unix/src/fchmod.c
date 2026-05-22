#include "amiga.h"
#include <amiga/ioctl.h>

int ioctl(int fd, int request, void *data);

int fchmod(int fd, int mode)
{
    long amode = _make_protection(mode);

    __chkabort();
    return ioctl(fd, _AMIGA_SETPROTECTION, &amode);
}
