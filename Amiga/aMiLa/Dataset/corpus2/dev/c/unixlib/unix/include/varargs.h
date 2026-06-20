#ifndef _VARARGS_H
#define	_VARARGS_H 1

#include <stdarg.h>

#define	va_dcl	int va_alist;

#undef	va_start
#define	va_start(ap) (ap = (char *)(&va_alist))

#endif
