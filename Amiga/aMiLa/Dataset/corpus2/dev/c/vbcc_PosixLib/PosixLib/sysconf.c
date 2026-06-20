/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: sysconf.c,v 1.1 2021/07/28 14:40:31 phx Exp $
 */

#pragma amiga-align
#include <exec/execbase.h>
#include <proto/exec.h>
#pragma default-align
#include <unistd.h>
#include <limits.h>
#include <errno.h>


long sysconf(int name)
{
  switch (name) {
    case _SC_GETPW_R_SIZE_MAX:
      return LOGIN_NAME_MAX+PATH_MAX;
    case _SC_OPEN_MAX:
      return OPEN_MAX;
    default:
      errno = EINVAL;
      return -1;
  }
}
