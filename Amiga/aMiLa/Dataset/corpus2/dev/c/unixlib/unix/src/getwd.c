#include "amiga.h"
#include <sys/param.h>

char *getwd(char *pathname)
{
    __chkabort();
    return getcwd(pathname, MAXPATHLEN);
}
