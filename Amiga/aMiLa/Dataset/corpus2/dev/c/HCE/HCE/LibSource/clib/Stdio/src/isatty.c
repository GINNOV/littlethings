#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

extern struct _device *_devtab[];

int
isatty(fd)
unsigned int fd;
{
	extern long IsInteractive();
	register struct _device *fp;

	fp = &((*_devtab)[fd]);
	if ( fd >=OPEN_MAX || !fp->fileHandle ) {
		errno = EBADF;
		return -1;
	}

	return ( IsInteractive(fp->fileHandle) != 0 );
}
