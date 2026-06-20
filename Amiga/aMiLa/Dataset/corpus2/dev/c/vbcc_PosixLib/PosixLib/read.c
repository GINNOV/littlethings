/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2005
 *
 * $Id: read.c,v 1.4 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <stddef.h>
#include <errno.h>
#include "fdesc.h"
#include "bsdsocket.h"


int read(int fd,void *buf,size_t nbytes)
{
  struct __fd_s *fp;
  int n;

  if (!(fp = __chk_fd(fd)))
    return -1;

  if (nbytes == 0)
    return 0;

  if (fp->flags & FDFL_DIRLOCK) {
    errno = EISDIR;  /* we don't read directory objects */
    return -1;
  }

  if (fp->flags & FDFL_SOCKET) {
    if ((n = __init_bsdsocket(fd)) >= 0)
      return recv(n,buf,nbytes,0);
    return -1;
  }

  n = Read(fp->file,buf,nbytes);
  if (n < 0)
    errno = EIO;

  return n;
}
