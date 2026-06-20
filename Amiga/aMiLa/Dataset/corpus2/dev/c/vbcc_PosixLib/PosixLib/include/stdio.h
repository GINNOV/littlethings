/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2006
 *
 * $Id: stdio.h,v 1.3 2020/10/06 09:24:09 phx Exp $
 */

#ifndef _STDIO_H_
#define _STDIO_H_

#include_next <stdio.h>
#include <sys/types.h>


/* Prototypes */
int fileno(FILE *);
FILE *fdopen(int,const char *);
off_t ftello(FILE *);
int fseeko(FILE *,off_t,int);

#if !defined(_ANSI_SOURCE) && !defined(_POSIX_C_SOURCE)
int asprintf(char **, const char *, ...);
char *fgetln(FILE *, size_t *);
int pclose(FILE *);
FILE *popen(const char *,const char *);
int vasprintf(char **, const char *, va_list);
#endif

#endif /* _STDIO_H_ */
