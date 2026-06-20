#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int read(int fd, void *buffer, unsigned int length)
{
  struct fileinfo *fi;

  chkabort();
  if (fi = _find_fd(fd))
    {
      if (fi->flags & FI_READ) return fi->read(fi->userinfo, buffer, length);
      errno = EACCES;
    }
  return -1;
}
