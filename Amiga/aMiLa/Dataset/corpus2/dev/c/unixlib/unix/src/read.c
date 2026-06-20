#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int __read(int fd, void *buffer, unsigned int length)
{
    struct fileinfo *fi;

    __chkabort();
    if (fi = _find_fd(fd)) {
	if (fi->flags & FI_READ)
	    return fi->read(fi->userinfo, buffer, length);
	errno = EACCES;
    }
    return -1;
}
