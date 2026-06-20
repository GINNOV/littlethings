#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int _pseudo_close(int fd)
{
    struct fileinfo *fi;

    __chkabort();
    if (fi = _find_fd(fd)) {
	int err = 0;
	if (fi->count == 1)
	    err = fi->close(fi->userinfo, TRUE);
/*
 * On return err is 0 if no error occurred, and negative otherwise.
 * But if fd was the descriptor of a socket we get a positive value
 * and thus not free the slot: the callback function called by AmiTCP
 * will do that for us.
 */
	if (err <= 0)
	    _free_fd(fd);
	else
	    err = 0;
	return err;
    }
    return -1;
}
