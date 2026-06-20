
/*
 * Portable Object Compiler (c) 1997 by Stes & Lerman.
 * All Rights Reserved.
 *
 * Header file for compatibility.
 * Enabled by -ppi option of objc.
 */

#ifndef _ARRAYH_
#define _ARRAYH_

typedef unsigned char *ADDR; /* used in ICpak201 */

#ifndef USE_STDARG
#define USE_STDARG
#endif

/* these should maybe go into objcrt.h */

#if defined(USE_STDARG)
# include <stdarg.h>
# define VA_START(ap,larg) va_start(ap,larg)
#else
# include <varargs.h>
# define VA_START(ap,larg) va_start(ap)
#endif /* USE_STDARG */

# define _VA_CHAR       char
# define _VA_SHORT      short
# define _VA_SHORT_PTR  short*
# define _VA_CHAR_PTR   char*
# define _VA_INT        int
# define _VA_INT_PTR    int*
# define _VA_LONG       long
# define _VA_LONG_PTR   long*
# define _VA_ID         id
# define _VA_ID_PTR     id*
# define _VA_DOUBLE     double

#include "objpak.h"

#endif /* _ARRAYH_ */

