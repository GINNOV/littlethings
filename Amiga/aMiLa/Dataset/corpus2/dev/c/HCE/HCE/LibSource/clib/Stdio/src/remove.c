#include <errno.h>

extern long DeleteFile(), IoErr();

int remove(filename)
char *filename;
{

	if ( DeleteFile(filename) != -1L ){
		errno = IoErr();
		return -1;
	}

	return 0;
}

int unlink(filename)
char *filename;
{
	return remove(filename);
}
