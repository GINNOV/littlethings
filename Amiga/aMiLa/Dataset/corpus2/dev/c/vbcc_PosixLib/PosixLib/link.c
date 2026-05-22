/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2005
 *
 * $Id: link.c,v 1.3 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <errno.h>
#include "conv.h"


int link(const char *oname,const char *lname)
{
  BPTR fl;

  if (fl = Lock(__convert_path(oname),SHARED_LOCK)) {
#ifdef __amigaos4__
    if (MakeLink(__convert_path(lname),(APTR)fl,LINK_HARD)) {
#else
    if (MakeLink(__convert_path(lname),(LONG)fl,LINK_HARD)) {
#endif
      UnLock(fl);
      return 0;
    }
    UnLock(fl);
  }

  switch (IoErr()) {  /* find reason for failure */
    case ERROR_OBJECT_NOT_FOUND:
      errno = ENOENT; break;
    case ERROR_DISK_WRITE_PROTECTED:
      errno = EROFS; break;
    case ERROR_DISK_FULL:
      errno = ENOSPC; break;
    case ERROR_OBJECT_EXISTS:
      errno = EEXIST; break;
    case ERROR_OBJECT_WRONG_TYPE:
      errno = EXDEV; break;
    case ERROR_ACTION_NOT_KNOWN:
      errno = EOPNOTSUPP; break;
    default:
      errno = EIO; break;
  }

  return -1;
}
