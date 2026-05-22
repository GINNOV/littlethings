/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: convpath.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "conv.h"


/*
  Converts AmigaDOS style path to POSIX style path in buf

  return number of bytes written to buf

  define KEEP_AMIGAPATH to disable conversion and pass AmigaDOS paths directly
  to the application
*/
size_t __path_from_ados(const char *path,char *buf,size_t bufsize)
{
#ifdef KEEP_AMIGAPATH
  size_t len = strlen(path)+1;
  if (len>bufsize)
    len = bufsize;
  memcpy(buf,path,len);
  return len;
#else
  size_t i = 0;
  char c;

  if (strchr(path,':') && bufsize)
    buf[i++] = '/';

  while (c=*path++) {
    if (c=='/' && (i==0 || buf[i-1]=='/')) {
      if (i < bufsize)
        buf[i++] = '.';
      if (i < bufsize)
        buf[i++] = '.';
    }
    else if (c==':')
      c = '/';
    if (c=='/' && *path==0)
      break;
    if (i>=bufsize)
      return i;
    buf[i++] = c;
  }

  if (i<bufsize)
    buf[i++] = '\0';
  return i;
#endif
}
