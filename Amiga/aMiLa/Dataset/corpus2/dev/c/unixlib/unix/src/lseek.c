#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int __lseek(int fd, long rpos, int mode)
{
    struct fileinfo *fi;

    __chkabort();
    if (fi = _find_fd(fd)) {
	return fi->lseek(fi->userinfo, rpos, mode);
    }
    return -1;
}
