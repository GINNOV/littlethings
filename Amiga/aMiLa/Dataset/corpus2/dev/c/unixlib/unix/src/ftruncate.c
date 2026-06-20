#include "amiga.h"
#include <amiga/ioctl.h>

int ioctl(int fd, int request, void *data);

int ftruncate(int fd, off_t length)
{
    __chkabort();
    return ioctl(fd, _AMIGA_TRUNCATE, &length);
}
