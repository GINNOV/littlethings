/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: realpath.c,v 1.1 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <proto/dos.h>
#pragma default-align
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "conv.h"


char *realpath(const char *restrict file_name, char *restrict resolved_name)
{
  BPTR lock;
  char *buf;

  if (file_name==NULL) {
    errno = EINVAL;
    return NULL;
  }

  if (resolved_name==NULL) {
    buf = malloc(PATH_MAX);
    if (buf==NULL)
    {
      errno = ENOMEM;
      return NULL;
    }
  }
  else
    buf = resolved_name;

  if (lock = Lock((STRPTR)__convert_path(file_name),ACCESS_READ)) {
#ifdef KEEP_AMIGAPATH
    if (NameFromLock(lock,buf,PATH_MAX)) {
      UnLock(lock);
      return buf;
    }
#else
    if (NameFromLock(lock,buf+1,PATH_MAX-1)) {
      char *p;
      UnLock(lock);
      buf[0]='/';
      if (p=strchr(buf,':'))
        *p = '/';
      p=strchr(buf,0)-1;
      if (*p=='/')
        *p = 0;
      return buf;
    }
#endif
    if (IoErr()==ERROR_LINE_TOO_LONG)
      errno = ENAMETOOLONG;
    else
      errno = EIO;
    UnLock(lock);
  }
  else {
    if (IoErr()==ERROR_OBJECT_IN_USE)
      errno = EACCES;    /* @@@ unlike Unix, AmigaOS doesn't allow that */
    else
      errno = ENOENT;
  }

  if (resolved_name==NULL)
    free( buf );
  return NULL;
}
