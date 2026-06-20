
/*
 *  STDLIB.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef STDLIB_H
#define STDLIB_H

#ifndef STDDEF_H
#include <stddef.h>
#endif

typedef struct div_t {
    int     quot;
    int     rem;
} div_t;

typedef struct ldiv_t {
    long    quot;
    long    rem;
} ldiv_t;

#define EXIT_FAILURE	1
#define EXIT_SUCCESS	0
#define MB_CUR_MAX	1
#ifndef MB_LEN_MAX
#define MB_LEN_MAX	2	/*  also set in limits.h    */
#endif

/*
 *  note: RAND_MAX assumed to be 2^N-1, a suitable bitwise mask
 */

#define RAND_MAX	((1 << (8*sizeof(int)-1)) - 1)

extern void abort(void);

#ifndef abs
#define abs(val)    ((val) >= 0 ? (val) : -(val))
#endif

extern int atexit(void (*)(void));
#ifndef MATH_H
extern double atof(const char *);
extern double strtod(const char *, char **);
#endif
extern int atoi(const char *);
extern long atol(const char *);
extern void *bsearch(const void *, const void *, size_t, size_t, int (*)(const void *, const void *));
extern void *calloc(size_t, size_t);
extern div_t div(int, int);
extern void exit(int);
extern void free(void *);
extern char *getenv(const char *);
extern long labs(long);
extern ldiv_t ldiv(long, long);
extern void *malloc(size_t);
extern int mblen(const char *, size_t);
extern size_t mbstowcs(wchar_t *, const char *, size_t);
extern int mbtowc(wchar_t *, const char *, size_t);
extern void qsort(void *, size_t, size_t, int (*)(const void *, const void *));
extern int rand(void);
extern void srand(unsigned int);
extern void *realloc(void *, size_t);
extern long strtol(const char *,char **, int);
extern unsigned long strtoul(const char *, char **, int);
extern int system(const char *);
extern size_t wcstombs(wchar_t *, const char *, size_t);
extern int wctomb(char *, wchar_t);

/*
 *  non ANSI stdlib functions
 */

extern int getfnl(const char *, char *, size_t, int);
extern int mkdir(const char *);
extern int expand_args(int, const char **, int *, char ***);
extern int (*onbreak(int (*)()))(void);
extern __stkargs void _exit(int);
extern void chkabort(void);
extern void stack_abort(void);

#endif

