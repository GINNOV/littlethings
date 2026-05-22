/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2005
 *
 * $Id: rmdir.c,v 1.5 2021/08/11 10:09:01 phx Exp $
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


int rmdir(const char *path)
{
  struct FileInfoBlock fib;  /* long-word aligned! */
  BPTR lock;
  char *cpath = __convert_path(path);

  if (lock = Lock((STRPTR)cpath,ACCESS_READ)) {
    if (Examine(lock,&fib)) {
      UnLock(lock);
      if (fib.fib_DirEntryType >= 0) {
        if (DeleteFile((STRPTR)cpath))
          return 0;

        switch (IoErr()) {
          case ERROR_DISK_WRITE_PROTECTED:
            errno = EROFS; break;
          case ERROR_OBJECT_IN_USE:
            errno = EBUSY; break;
          case ERROR_DELETE_PROTECTED:
            errno = EPERM; break;  /* @@@ Unix doesn't care! */
          case ERROR_DIRECTORY_NOT_EMPTY:
            errno = ENOTEMPTY; break;
          default:
            errno = EIO; break;
        }
      }
      else
        errno = ENOTDIR;  /* not a directory */
    }
    else {
      UnLock(lock);
      errno = EIO; /* @@@ */
    }
  }
  else {
    if (IoErr() == ERROR_OBJECT_IN_USE)
      errno = EBUSY;
    else
      errno = ENOENT;
  }

  return -1;
}
