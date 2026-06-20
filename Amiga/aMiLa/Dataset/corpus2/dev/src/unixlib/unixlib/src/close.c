#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int close(int fd)
{
  struct fileinfo *fi;

  chkabort();
  if (fi = _find_fd(fd))
    {
      int err = fi->close(fi->userinfo, fi->flags & O_NO_CLOSE);

      _free_fd(fd);
      return err;
    }
  return -1;
}
