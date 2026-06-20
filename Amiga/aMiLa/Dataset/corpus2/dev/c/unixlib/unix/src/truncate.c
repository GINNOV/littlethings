#include "amiga.h"
#include "amigados.h"

int truncate(char *path, off_t length)
{
    BPTR fh = Open(path, MODE_OLDFILE);
    int err;

    __chkabort();
    if (fh) {
	int ret = _do_truncate(fh, length);

	if (Close(fh) || ret)
	    return ret;
	err = IoErr();
    } else
	err = IoErr();

    errno = convert_oserr(err);
    return -1;
}
