/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: getlogin_r.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <dos/var.h>
#include <proto/dos.h>
#pragma default-align
#include <string.h>
#include <errno.h>

int getlogin_r(char *name,size_t namesize)
{
  int i;
  LONG len;

  len = GetVar("USER",name,namesize,0);
  if (len <= 0)
    len = GetVar("LOGUSER",name,namesize,0);
  if (len <= 0)
    len = GetVar("USERNAME",name,namesize,0);

  if (len <= 0) {
    if (namesize > strlen("anonymous")) {
      strcpy(name,"anonymous");
      return 0;
    }
    errno = ERANGE;
    return -1;
  }

  len = IoErr();  /* Get the real length of the variable */
  if (len >= namesize) {
    errno = ERANGE;
    return -1;
  }

  for (i=len-1; i>=0; i--) {
    if (name[i]==' ' || name[i]=='\t' ||
        name[i]=='\r' || name[i]=='\n')
      name[i] = '\0';
    else
      break;
  }
  return 0;
}
