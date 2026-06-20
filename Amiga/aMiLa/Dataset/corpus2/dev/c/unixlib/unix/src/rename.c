#include "amiga.h"

int rename(const char *from, const char *to)
{
    long err;

    __chkabort();
    if (Rename(from, to))
	return 0;
    err = IoErr();
    if (err == ERROR_OBJECT_EXISTS) {
	if (DeleteFile(to) && Rename(from, to))
	    return 0;
	err = IoErr();

	if (err == ERROR_DELETE_PROTECTED) {
	    if (SetProtection(to, 0) && DeleteFile(to) && Rename(from, to))
		return 0;
	    err = IoErr();
	}
    }
    errno = convert_oserr(err);
    return -1;
}
