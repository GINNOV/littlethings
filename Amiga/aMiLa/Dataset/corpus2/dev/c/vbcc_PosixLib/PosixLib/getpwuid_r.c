/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: getpwuid_r.c,v 1.1 2021/07/28 14:40:30 phx Exp $
 */

#pragma amiga-align
#include <dos/dos.h>
#include <dos/var.h>
#include <proto/dos.h>
#pragma default-align
#include <string.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>
#include <errno.h>
#include "conv.h"


int getpwuid_r(uid_t uid,struct passwd *pwd,char *buffer,
  size_t bufsize, struct passwd **result)
{
  size_t len;
  char *home;

  *result = NULL;

  /* we only emulate a single user, with uid 0 */
  if (uid != 0)
    return 0;

  memset(pwd,0,sizeof(*pwd));

  pwd->pw_name = buffer;
  if (getlogin_r(buffer,bufsize) != 0) {
    errno = ERANGE;
    return -1;
  }
  len = strlen(buffer)+1;
  buffer = &buffer[len];
  bufsize -= len;

  pwd->pw_passwd = "*";
  pwd->pw_gid = pwd->pw_uid = uid;

  if (bufsize <= 0) {
    errno = ERANGE;
    return -1;
  }

  if (home = getenv("HOME")) {
    len = __path_from_ados(home,buffer,bufsize);
    free(home);
  }
  else
    len = __path_from_ados("SYS:",buffer,bufsize);
  if (len==bufsize && buffer[len-1]!=0) {
    errno = ERANGE;
    return -1;
  }
  pwd->pw_dir = buffer;

  pwd->pw_shell = "CLI";  /* @@@ */

  *result = pwd;
  return 0;
}
