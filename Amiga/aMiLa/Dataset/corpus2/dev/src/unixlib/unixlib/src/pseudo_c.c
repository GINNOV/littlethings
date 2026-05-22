#include "amiga.h"
#include "files.h"
#include <fcntl.h>

int _pseudo_close(int fd)
{
  struct fileinfo *fi;

  chkabort();
  if (fi = _find_fd(fd))
    {
      int err = fi->close(fi->userinfo, TRUE);

      _free_fd(fd);
      return err;
    }
  return -1;
}
