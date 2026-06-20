/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003
 *
 * $Id: convfile.c,v 1.5 2021/07/28 14:40:30 phx Exp $
 */

#include <stdbool.h>
#include <stdlib.h>
#include <sys/syslimits.h>
#include "conv.h"


char *__convert_path(const char *path)
{
  static char buf[PATH_MAX];
  int i=0;
  char c;
  bool abs = false;

  if (path == NULL)
    return NULL;

  if (*path == '/') {
    abs = true;
    path++;
  }

  while (c = *path++) {
    if (abs && (c=='/' || c==':')) {
      c = ':';
      abs = false;
    }
    else if (i == 0 || buf[i-1]=='/' || buf[i-1]==':') {
      if (c=='.') {
        /*
          take advantage of empty segments to handle paths ending with . or ..
        */
        if (*path=='.' && (*(path+1)=='/' || *(path+1)==0)) {
          c = '/';
          path++;
        }
        else if (*path=='/' || *path==0)
          continue;
      }
      else if (c=='/')
        continue;  /* strip empty path segments */
    }

    if (i >= PATH_MAX-1)
      break;
    buf[i++] = c;
  }

  if (abs && (i < PATH_MAX-1))
    buf[i++] = ':';
  buf[i] = '\0';
  return buf;
}
