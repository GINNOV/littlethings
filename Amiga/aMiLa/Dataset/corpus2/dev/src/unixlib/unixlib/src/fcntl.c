#include "amiga.h"
#include "files.h"
#include <fcntl.h>
#include <sys/filio.h>
#include <stdarg.h>

/* Flags that can be changed with fcntl */
#define FCNTL_FLAGS (O_NDELAY | O_APPEND)

int fcntl(int fd, int cmd, ...)
{
  struct fileinfo *fi;
  va_list args;
  int arg;

  chkabort();
  va_start(args, cmd);
  arg = va_arg(args, int);
  va_end(args);

  if (fi = _find_fd(fd))
    {
      switch (cmd)
	{
	default: errno = EINVAL; break;
	case F_GETFL: return fi->flags & FCNTL_FLAGS;
	case F_SETFL:
	  {
	    int oldfl = fi->flags;

	    fi->flags = (fi->flags & ~FCNTL_FLAGS) | (arg & FCNTL_FLAGS);
	    if ((oldfl & O_NDELAY) != (fi->flags & O_NDELAY))
	      {
		int ndelay = fi->flags & O_NDELAY;

		return fi->ioctl(fi->userinfo, FIONBIO, &ndelay);
	      }
	    return 0;
	  }
	}
    }
  return -1;
}
