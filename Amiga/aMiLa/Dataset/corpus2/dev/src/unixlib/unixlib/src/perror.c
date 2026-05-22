#include "amiga.h"
#include <errno.h>
#include <string.h>
#include <unistd.h>

int perror(char *s)
{
  char *err;
  char amiga_err[81];

  if (s && *s) 
    {
      write(2, s, strlen(s));
      write(2, ": ", 2);
    }
  if (errno > 0 && errno <= sys_nerr) err = sys_errlist[errno];
  else if (errno == -1) 
    {
      if (Fault(_OSERR, NULL, amiga_err, 81)) err = amiga_err;
      else err = "42";		/* Shouldn't appear ... */
    }
  else err = "Unknown error code";

  write(2, err, strlen(err));
  write(2, "\n", 1);

  return errno;
}
