/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2005
 *
 * $Id: getlogin.c,v 1.2 2021/07/28 14:40:30 phx Exp $
 */

#pragma default-align
#include <errno.h>
#include <sys/syslimits.h>
#include <unistd.h>


char *getlogin(void)
{
  static char username[LOGIN_NAME_MAX];
  return getlogin_r(username,sizeof(username)) == 0 ? username : NULL;
}


int setlogin(const char *name)
{
  /* should we allow to set username? */
  errno = EPERM;
  return -1;
}
