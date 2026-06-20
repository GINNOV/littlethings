#include "amiga.h"
#include <amiga/ioctl.h>

int fchmod(int fd, int mode)
{
  long amode = _make_protection(mode);

  chkabort();
  return ioctl(fd, _AMIGA_SETPROTECTION, &amode);
}
