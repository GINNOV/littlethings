
/*
 *  LIB/MISC.H
 *
 *  miscellanious prototypes for internal c.lib functions
 */

#ifndef _LIB_MISC_H
#define _LIB_MISC_H
#ifndef _STDARG_H
#include <stdarg.h>
#endif
#ifndef _STDIO_H
#include <stdio.h>
#endif

void __closeall(void);
void _finitdesc(FILE *, int, int);
int _parseargs1(char *, int);
void _parseargs2(char *, char **, int);
long _SearchResident(char *);
long _SearchPath(char *);
__stkargs long _ExecSeg(long, char *, long, void *);
int exec_dcc(char *, char *);
int _pfmt(char *, va_list, int (*)(char *, int, int, void *), void *);
int _pfmtone(char, va_list *, int (*)(char *, int, int, void *), void *, short, short, short, int);
int _sfmt(unsigned char *, va_list, int (*)(void *), void (*)(int, void *), void *, int *);
int _sfmtone(char *, short *, void *, int (*)(void *), void *, short, short, short);
int __fclose(FILE *);
int _filbuf(FILE *);

__stkargs _slow_bcopy(void *, void *, long);
__stkargs _slow_bzero(void *, long);
__stkargs _slow_bset(void *, long, int);

#ifndef _EXTRA_WILDCARD_C
void _SetWildStack(long);
void *_ParseWild(const char *, short);
int _CompWild(const char *, void *, void *);
void _FreeWild(void *);
#endif


#endif
