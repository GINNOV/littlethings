#include <fcntl.h>

int creat(filename, pmode)
register char *filename;
register int pmode;
{

	return ( open(filename, O_WRONLY|O_TRUNC|O_CREAT, pmode) );
}
