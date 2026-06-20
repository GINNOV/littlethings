
/*
 *  VARARGS.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef VARARGS_H
#define VARARGS_H
#ifndef STDARG_H
#include <stdarg.h>
#define va_dcl long va_alist;
#define va_start(pvar)  (pvar = (void *)(&va_alist))
#endif
#endif

