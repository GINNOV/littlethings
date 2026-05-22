#include <errno.h>

extern long Rename(), IoErr();

int rename(oldname, newname)
char *oldname, *newname;
{

	if ( Rename(oldname, newname) != -1L ){
		errno = IoErr();
		return -1;
	}
	return 0;
}
