#ifndef _UNIX_STDLIB_H
#define _UNIX_STDLIB_H
#include "include:stdlib.h"
#ifndef _ANSI_SOURCE
int setenv(const char *, const char *, int);
#ifndef _POSIX_SOURCE
extern	char *optarg;			/* getopt(3) external variables */
extern	int optind;
extern	int opterr;
int	getopt (int, char * const *, const char *);
void unsetenv(const char *);
#endif
#endif
#endif
