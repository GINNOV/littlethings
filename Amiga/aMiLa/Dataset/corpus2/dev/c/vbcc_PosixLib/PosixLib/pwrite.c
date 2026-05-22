/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: pwrite.c,v 1.1 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <unistd.h>
#include <errno.h>
#include "fdesc.h"


int pwrite(int fd,void *buf,size_t nbytes,off_t offset)
{
  struct FileInfoBlock fib; /* longword-aligned */
  struct __fd_s *fp;
  LONG oldpos,n;

  if (!(fp = __chk_fd(fd)))
    return -1;

  if (fp->flags & FDFL_DIRLOCK) {
    errno = EBADF;  /* we don't read directory objects */
    return -1;
  }

  if (fp->flags & FDFL_SOCKET) {
    errno = ESPIPE;
    return -1;
  }

  if (!ExamineFH(fp->file,&fib)) {
    errno = EIO;
    return -1;
  }

  if (offset > (off_t)fib.fib_Size)
  {
    if (SetFileSize(fp->file,offset,OFFSET_BEGINNING) != offset) {
      if (IoErr() == ERROR_DISK_FULL)
        errno = ENOSPC;
      else
        errno = EIO;
      return -1;
	}
  }

  if ((oldpos = Seek(fp->file,offset,OFFSET_BEGINNING)) == -1)
  {
    errno = EIO;
    return -1;
  }

  n = Write(fp->file,buf,nbytes);
  if (n == -1) {
    if (IoErr() == ERROR_DISK_FULL)
      errno = ENOSPC;
    else
      errno = EIO;
	return -1;
  }

  if (Seek(fp->file,oldpos,OFFSET_BEGINNING) == -1)
  {
    errno = EIO;
    return -1;
  }

  return n;
}
