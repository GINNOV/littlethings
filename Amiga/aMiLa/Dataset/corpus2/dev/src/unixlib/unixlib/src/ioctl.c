#include "amiga.h"
#include "files.h"

int ioctl(int fd, int request, caddr_t arg)
{
  struct fileinfo *fi;

  chkabort();
  if (fi = _find_fd(fd))
    {
      return fi->ioctl(fi->userinfo, request, arg);
    }
  return -1;
}
