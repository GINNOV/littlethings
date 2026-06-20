#include "amiga.h"

int __near errno;

int convert_oserr(int ioerr)
{
    extern int _OSERR;

    _OSERR = ioerr;
    switch (ioerr) {
	case 0:
	    return 0;
	case ERROR_NO_FREE_STORE:
	    return ENOMEM;
	case ERROR_TASK_TABLE_FULL:
	    return EAGAIN;
	case ERROR_BAD_TEMPLATE:
	case ERROR_REQUIRED_ARG_MISSING:
	case ERROR_BAD_NUMBER:
	case ERROR_KEY_NEEDS_ARG:
	case ERROR_TOO_MANY_ARGS:
	case ERROR_UNMATCHED_QUOTES:
	    return EINVAL;
	case ERROR_LINE_TOO_LONG:
	    return E2BIG;
	case ERROR_FILE_NOT_OBJECT:
	    return ENOEXEC;
	case ERROR_OBJECT_IN_USE:
	    return EBUSY;
	case ERROR_OBJECT_EXISTS:
	    return EEXIST;
	case ERROR_DIR_NOT_FOUND:
	    return ENOENT;
	case ERROR_OBJECT_NOT_FOUND:
	    return ENOENT;
	case ERROR_BAD_STREAM_NAME:
	    return EINVAL;
	case ERROR_OBJECT_TOO_LARGE:
	    return E2BIG;
	case ERROR_ACTION_NOT_KNOWN:
	    return EINVAL;
	case ERROR_INVALID_COMPONENT_NAME:
	    return ENAMETOOLONG;
	case ERROR_INVALID_LOCK:
	    return EINVAL;
	case ERROR_OBJECT_WRONG_TYPE:
	    return EINVAL;
	case ERROR_DISK_WRITE_PROTECTED:
	    return EROFS;
	case ERROR_RENAME_ACROSS_DEVICES:
	    return EXDEV;
	case ERROR_DIRECTORY_NOT_EMPTY:
	    return ENOTEMPTY;
	case ERROR_TOO_MANY_LEVELS:
	    return ELOOP;
	case ERROR_DEVICE_NOT_MOUNTED:
	    return ENODEV;
	case ERROR_SEEK_ERROR:
	    return EINVAL;
	case ERROR_DISK_FULL:
	    return ENOSPC;
	case ERROR_DELETE_PROTECTED:
	    return EACCES;
	case ERROR_WRITE_PROTECTED:
	    return EACCES;
	case ERROR_READ_PROTECTED:
	    return EACCES;
	default:
	    return EOSERR;
    }
}

void _seterr(void)
{
    errno = convert_oserr(IoErr());
}
