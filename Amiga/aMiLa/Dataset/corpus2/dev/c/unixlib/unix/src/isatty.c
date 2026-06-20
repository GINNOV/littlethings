#include "amiga.h"
#include <amiga/ioctl.h>

extern int ioctl(int fd, int request, void *data);

int isatty(int fd)
{
    int istty;

    __chkabort();
    if (ioctl(fd, _AMIGA_INTERACTIVE, &istty) != 0)
	return 0;
    return istty;
}
