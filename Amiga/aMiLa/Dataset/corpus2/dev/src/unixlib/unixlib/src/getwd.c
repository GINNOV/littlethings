#include "amiga.h"
#include <sys/param.h>

char *getwd (char *pathname)
{
  chkabort();
  return getcwd(pathname, MAXPATHLEN);
}
