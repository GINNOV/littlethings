
/*
 *  STDDEF.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef STDDEF_H
#define STDDEF_H

#ifndef NULL
#define NULL	((void *)0L)
#endif
#ifndef offsetof
#define offsetof(sname,fname)   ((long)&((sname *)0)->fname)
#endif
typedef int ptrdiff_t;
typedef int size_t;
typedef char wchar_t;

#endif

