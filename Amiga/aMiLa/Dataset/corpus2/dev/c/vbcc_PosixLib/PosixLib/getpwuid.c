/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: getpwuid.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#include <pwd.h>
#include <unistd.h>
#include <sys/syslimits.h>
#include <errno.h>


struct passwd *getpwuid(uid_t uid)
{
  static char buf[LOGIN_NAME_MAX+PATH_MAX];
  static struct passwd pwd;
  struct passwd *res;
  int rval;
  if ((rval=getpwuid_r(uid,&pwd,buf,sizeof(buf),&res))==0)
    return res;
  errno = rval;
  return NULL;
}
