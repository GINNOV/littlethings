#ifndef _UNIX_STDIO_H
#define _UNIX_STDIO_H
#include "include:stdio.h"
extern int pclose(FILE *);
extern FILE *popen(const char *, const char *);
extern char *tempnam(const char *, const char *);
#endif
