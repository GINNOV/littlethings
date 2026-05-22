/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2005
 *
 * $Id: symlink.c,v 1.3 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <string.h>
#include <limits.h>
#include <errno.h>
#include "conv.h"


int symlink(const char *oname,const char *lname)
{
  char lname_dos[PATH_MAX];

  if (strlen(oname)>=PATH_MAX || strlen(lname)>=SYMLINK_MAX) {
    errno = ENAMETOOLONG;
    return -1;
  }
  strcpy(lname_dos,__convert_path(lname));

#ifdef __amigaos4__
  if (MakeLink(lname_dos,(APTR)__convert_path(oname),LINK_SOFT)) {
#else
  if (MakeLink(lname_dos,(LONG)__convert_path(oname),LINK_SOFT)) {
#endif
    return 0;
  }

  switch (IoErr()) {  /* find reason for failure */
    case ERROR_DISK_WRITE_PROTECTED:
      errno = EROFS; break;
    case ERROR_DISK_FULL:
      errno = ENOSPC; break;
    case ERROR_OBJECT_EXISTS:
      errno = EEXIST; break;
    case ERROR_ACTION_NOT_KNOWN:
      errno = EOPNOTSUPP; break;
    default:
      errno = EIO; break;
  }

  return -1;
}
