/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: readlink.c,v 1.2 2021/12/18 15:53:32 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#ifdef __amigaos4__
#include <dos/dosextens.h>
#include <dos/obsolete.h>
#endif
#include <proto/dos.h>
#pragma default-align
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include "conv.h"

ssize_t readlink(const char *restrict path,char *restrict buf,size_t bufsize)
{
  struct FileLock *fl;
  char c,*cpath,*filepart;
  BPTR lock;
  LONG len;

  cpath = __convert_path(path);
  filepart = FilePart(cpath);
  c = *filepart;
  *filepart = 0;

  if (c==0) {
    errno = ENOENT;
    return -1;
  }

  if (lock = Lock((STRPTR)cpath,ACCESS_READ)) {
    *filepart = c;
    fl = BADDR(lock);
    /* ReadLink returns RES1 from ACTION_READ_LINK, not BOOL */
    if (ReadLink(fl->fl_Task,lock,filepart,cpath,PATH_MAX)>=0) {
      UnLock(lock);
      return __path_from_ados(cpath,buf,bufsize);
    }
    UnLock(lock);
    errno = EINVAL;
  }
  else
    errno = ENOENT;
  return -1;
}
