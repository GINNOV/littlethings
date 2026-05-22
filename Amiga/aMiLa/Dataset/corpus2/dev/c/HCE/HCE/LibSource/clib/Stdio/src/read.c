#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

extern struct _device *_devtab[];
extern long Read(), IoErr();

int read(h, data, len)
unsigned int h;
char *data;
unsigned int len;
{
	register long rv;
	register struct _device *p;

	Chk_Abort();
	p = &((*_devtab)[h]);
	if ( h >= OPEN_MAX || p->fileHandle == 0)
		return (errno = EBADF);

	rv = Read( p->fileHandle, data, (unsigned long) len );

	if(rv < 0)
		errno = IoErr();
	return(rv);
}
