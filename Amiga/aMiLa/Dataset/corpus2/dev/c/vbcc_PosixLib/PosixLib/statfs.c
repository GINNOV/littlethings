/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2005
 *
 * $Id: statfs.c,v 1.4 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <errno.h>
#include "conv.h"
#include "info2statfs.h"


int statfs(const char *path,struct statfs *buf)
{
  struct InfoData info;  /* long-word aligned! */
  BPTR lock;

  if (lock = Lock((STRPTR)__convert_path(path),ACCESS_READ)) {
    if (Info(lock,&info)) {
      UnLock(lock);
      return __info2statfs(&info,buf);
    }
    else
      errno = EIO;
    UnLock(lock);
  }
  else {
    if (IoErr() == ERROR_OBJECT_IN_USE)
      errno = EACCES;    /* @@@ unlike Unix, AmigaOS doesn't allow that */
    else
      errno = ENOENT;
  }
  return -1;
}
