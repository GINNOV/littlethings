#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

extern struct _device *_devtab[];
extern void Chk_Abort();

long lseek(h, where, how)
unsigned int h;
long where;
int how;
{
	register long rv;
	register struct _device *p;
	
	Chk_Abort();
	p = &((*_devtab)[h]);
	if ( h < OPEN_MAX && !p->fileHandle ) {
		errno = EBADF;
		return -1;
	}

	if ( Seek(p->fileHandle, where, (long)(how-1)) == -1 ) {
		errno = EFAULT;
		return -1;
	}

	/*
	 * Ask Amigados where we are relative to the start.
	 */

	rv = Seek( p->fileHandle, 0L, 0L);
	return rv;
}

long tell(h)
	int h;
	{
	return(lseek(h, 0L, SEEK_CUR));
	}
