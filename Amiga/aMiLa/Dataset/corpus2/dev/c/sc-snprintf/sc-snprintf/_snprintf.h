/*
**      $VER: _snprintf.h 1.0 (28.12.2007)
**
**      snprintf() for SAS/C
**
**      (C) Copyright 2007 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifndef _SNPRINTF_H
#define _SNPRINTF_H 1

#ifdef AMIGA

#include <stdio.h>
#include <stdarg.h>

#ifdef __SASC
#ifdef _M68000

extern int snprintf (char *s, size_t n, const char *format, ...);

extern int snprintf_unsafe (char *s, size_t n, const char *format, ...);
extern int snprintf_ieee (char *s, size_t n, const char *format, ...);
extern int snprintf_noieee (char *s, size_t n, const char *format, ...);

extern int _snp_disable; // if set to TRUE, sprintf() is used in any case
                         // i.e. fallback to snprintf_unsafe()

#ifndef snprintf

#ifdef SNPRINTF_UNSAFE
#define snprintf snprintf_unsafe
#else
#ifdef SNPRINTF_NOIEEE
#define snprintf sprintf_noieee
#else
#ifdef SNPRINTF_IEEE
#define snprintf sprintf_ieee
#else
"ERROR" // please select one SNPRINTF_ option
#endif
#endif
#endif

#endif /* snprintf */

#endif /* _M68000 */

#endif /* _SASC */

#endif /* AMIGA */

#endif /* _SNPRINTF_H */
