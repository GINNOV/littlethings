/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2005
 *
 * $Id: unlink.c,v 1.5 2021/08/02 10:38:06 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#ifdef __amigaos4__
#include <dos/dosextens.h>
#include <dos/obsolete.h>
#endif
#include <proto/dos.h>
#pragma default-align
#include <errno.h>
#include "conv.h"

#ifndef EPERM
#define EPERM 1 /* vbcc's errno.h doesn't define EPERM */
#endif


int unlink(const char *path)
{
  if (DeleteFile((STRPTR)__convert_path(path)))
    return 0;
  switch (IoErr()) {
    case ERROR_DIR_NOT_FOUND:
    case ERROR_INVALID_COMPONENT_NAME:
      errno = ENOTDIR; break;
    case ERROR_OBJECT_NOT_FOUND:
      errno = ENOENT; break;
    case ERROR_DISK_WRITE_PROTECTED:
      errno = EROFS; break;
    case ERROR_OBJECT_IN_USE:
      errno = EBUSY; break;
    case ERROR_DIRECTORY_NOT_EMPTY:
    case ERROR_DELETE_PROTECTED:
      errno = EPERM; break;  /* @@@ Unix doesn't care! */
    default:
      errno = EIO; break;
  }
  return -1;
}
