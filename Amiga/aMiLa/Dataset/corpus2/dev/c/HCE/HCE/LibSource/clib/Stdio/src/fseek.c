#include <stdio.h>
#include <errno.h>

extern long lseek();

long ftell(fp)
	register FILE *fp;
	{
	register long rv;

	fflush(fp);
	rv = lseek(fp->_file, 0L, 1);
	return((rv < 0) ? ((errno = ((int) rv)), (-1)) : rv);
	}

int fseek(fp, offset, origin)
	register FILE *fp;
	long offset;
	int origin;
	{
	register long rv;

	fflush(fp);
	rv = lseek(fp->_file, offset, origin);
	return((rv < 0) ? ((errno = ((int) rv)), (-1)) : 0);
	}

void rewind(fp)
	register FILE *fp;
	{
	register long rv;

	fflush(fp);
	rv = lseek(fp->_file, 0L, SEEK_SET);
	if(rv < 0)
		errno = ((int) rv);
	fp->_flag &= ~(_IOEOF|_IOERR);
	}
