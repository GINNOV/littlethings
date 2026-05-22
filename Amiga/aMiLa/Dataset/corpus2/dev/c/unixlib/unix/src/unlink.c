#include "amiga.h"
#include "files.h"
#include <amiga/ioctl.h>

int ioctl(int fd, int request, void *data);

static int delete_open_file(char *name)
{
    BPTR nlock = Lock(name, SHARED_LOCK);

    if (nlock) {
	int err = errno, i;

	i = _last_fd();
	while (--i >= 0)
	    if (ioctl(i, _AMIGA_DELETE_IF_ME, &nlock) == 0) {
		errno = err;
		return 0;
	    }
	UnLock(nlock);
    }
    return -1;
}

int unlink(const char *file)
{
    long err;

    __chkabort();
    if (DeleteFile(file))
	return 0;
    err = IoErr();
    if (err == ERROR_DELETE_PROTECTED) {
	if (SetProtection(file, 0) && DeleteFile(file))
	    return 0;
	err = IoErr();
    }
    if (err == ERROR_OBJECT_IN_USE && delete_open_file(file) == 0)
	return 0;
    errno = convert_oserr(err);
    return -1;
}

int remove(const char *file)
{
    return(unlink(file));
}
