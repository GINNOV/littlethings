#include "amiga.h"
#include "files.h"
#include "amigados.h"
#include <utility/tagitem.h>
#include <stdarg.h>
#include <fcntl.h>
#include <string.h>

int __open(const char *path, int flags,...)
{
    int fd, acc = flags & 3, rd, wr, exists = TRUE, amode;
    struct FileInfoBlock *fib;
    BPTR plock, fh;
    long fdflags, protection;
    APTR pwindow = _us->pr_WindowPtr;

    __chkabort();

    rd = acc == O_RDONLY || acc == O_RDWR;
    wr = acc == O_WRONLY || acc == O_RDWR;

    if (stricmp(path, "NIL:") == 0)
	amode = -1;
    else {
	_us->pr_WindowPtr = (APTR) - 1;
	plock = Lock(path, ACCESS_READ);
	_us->pr_WindowPtr = pwindow;
	if (!plock) {
	    int err = convert_oserr(IoErr());

	    /* Devices like pipe: don't like Lock ... */
	    if (err == ENOENT && (flags & O_CREAT) ||
		_OSERR == ERROR_ACTION_NOT_KNOWN ||
		_OSERR == 0) {	/* Some devices (tape:) don't set IoErr() ... */
		va_list vmode;

		exists = FALSE;
		if (flags & O_CREAT) {
		    if (flags & 0x8000)		/* SAS C runtime called us, no mode */
			amode = FIBF_EXECUTE;	/* Maybe 0 ? */
		    else {
			va_start(vmode, flags);
			amode = _make_protection(va_arg(vmode, int));
			va_end(vmode);
		    }
		} else
		    amode = -1;	/* Assume complete access */
	    } else {
		errno = err;
		return -1;
	    }
	} else {		/* File already exists, play with it */
	    /* Get protection */
	    if (!((fib = AllocDosObjectTags(DOS_FIB, TAG_END)) &&
		  Examine(plock, fib))) {
		if (fib)
		    FreeDosObject(DOS_FIB, fib);
		ERROR;
	    }
	    amode = fib->fib_Protection;
	    FreeDosObject(DOS_FIB, fib);
	    UnLock(plock);

	    /* Check access */
	    if ((flags & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL)) {
		errno = EEXIST;
		return -1;
	    }
	    if ((rd && (amode & FIBF_READ) || wr && (amode & FIBF_WRITE))) {
		errno = EACCES;
		return -1;
	    }
	    /* Truncate files, by opening in MODE_NEWFILE, then closing it. This
	       allows the file to be opened in shared mode after that (READWRITE
	       or OLDFILE), which is consistent with the unix semantics. */
	    if (flags & O_TRUNC) {
		BPTR tfh;

		if (tfh = Open(path, MODE_NEWFILE))
		    Close(tfh);
		else
		    ERROR;
	    }
	}
    }

    if (flags & O_CREAT) {
	if (!(fh = Open(path, MODE_READWRITE)))
	    fh = Open(path, MODE_NEWFILE); /* Devices like pipe: want this */
    } else {
	fh = Open(path, MODE_OLDFILE);
    }
    if (!fh)
	ERROR;

    /* Protection is set when file is closed because OFS & FFS
       don't appreciate it being done on MODE_NEWFILE files. */
    if ((flags & O_TRUNC) || !exists)
	protection = amode;
    else
	protection = -1;

    fdflags = 0;
    if (rd)
	fdflags |= FI_READ;
    if (wr)
	fdflags |= FI_WRITE;
    if (flags & O_APPEND)
	fdflags |= O_APPEND;

    fd = _alloc_amigafd(fh, protection, fdflags);
    if (fd < 0) {
	_us->pr_WindowPtr = (APTR) - 1;
	Close(fh);
	_us->pr_WindowPtr = pwindow;
    }
    return fd;
}
