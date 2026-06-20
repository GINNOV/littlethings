#include <errno.h>

extern long DeleteFile(), IoErr();

int rmdir(pathname)
char *pathname;
{
	if ( DeleteFile(pathname) != -1L ){
		errno = IoErr();
		return -1;
	}
	return 0;
}
