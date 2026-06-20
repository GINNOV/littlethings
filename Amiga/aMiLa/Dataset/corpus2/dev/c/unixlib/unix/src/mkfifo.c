#include "amiga.h"

int mkfifo(char *path, int mode, int dev)
{
    errno = EOSERR;
    return -1;
}
int mknod(char *path, int mode, int dev)
{
    errno = EOSERR;
    return -1;
}
