#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

extern struct _device *_devtab[];
extern long Write(), IoErr();

int write(h, data, len)
int h;
char *data;
unsigned int len;
{
	register long rv;
	register struct _device *p;

	Chk_Abort();
	p = &((*_devtab)[h]);
	if ( h >= OPEN_MAX || !p->fileHandle )
		return (errno = EBADF);

	rv = Write(p->fileHandle, data, (unsigned long) len);
	if(rv < 0)
		errno = IoErr();
	return(rv);
}
