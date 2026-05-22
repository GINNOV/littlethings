#include "amiga.h"
#include <amiga/ioctl.h>

int ftruncate(int fd, off_t length)
{
  chkabort();
  return ioctl(fd, _AMIGA_TRUNCATE, &length);
}
