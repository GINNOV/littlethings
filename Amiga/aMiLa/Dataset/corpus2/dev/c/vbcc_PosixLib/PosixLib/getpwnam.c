/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2005
 *
 * $Id: getpwnam.c,v 1.2 2021/07/28 14:40:30 phx Exp $
 */

#include <string.h>
#include <pwd.h>
#include <unistd.h>


struct passwd *getpwnam(const char *name)
{
  if (!strcmp(name,getlogin()))
    return getpwuid(0);

  return NULL;
}
