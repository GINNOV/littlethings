#include "amiga.h"
#include <amiga/ioctl.h>

int isatty(int fd)
{
  int istty;

  chkabort();
  if (ioctl(fd, _AMIGA_INTERACTIVE, &istty) != 0) return 0;
  return istty;
}
