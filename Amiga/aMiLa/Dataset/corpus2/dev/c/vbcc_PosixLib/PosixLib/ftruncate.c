/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: ftruncate.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <stddef.h>
#include <errno.h>
#include "fdesc.h"


int ftruncate(int fd,off_t length)
{
  struct __fd_s *fp;

  if (!(fp = __chk_fd(fd)))
  {
    errno = EBADF;
    return -1;
  }

  if (fp->flags & (FDFL_DIRLOCK | FDFL_SOCKET)) {
    errno = EBADF;
    return -1;
  }

  if (length < 0) {
    errno = EINVAL;
    return -1;
  }

  /* BUG: SetFileSize doesn't zero out data if expanding file */
  if (SetFileSize(fp->file,length,OFFSET_BEGINNING) != length) {
    errno = EIO;
    return -1;
  }

  return 0;
}
