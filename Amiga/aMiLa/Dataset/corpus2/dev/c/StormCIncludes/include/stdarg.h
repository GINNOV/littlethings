#ifndef _INCLUDE_STDARG_H
#define _INCLUDE_STDARG_H

/*
**  $VER: stdarg.h 2.1 (27.06.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifdef __STORM__

typedef unsigned int va_list;

#define va_start(vl,lastarg) (vl) = (unsigned int)(&lastarg) + ((sizeof(lastarg) + 1) & 0xfffffffe);
#define va_arg(vl,type) (*((type *) ((vl += ((sizeof(type) <= sizeof(int)) ? sizeof(int) : (sizeof(type) + 1) & -2)) - sizeof(type))))
#define va_end(vl) __never_inline

#else

#include <machine/stdarg.h>

#endif

#endif
