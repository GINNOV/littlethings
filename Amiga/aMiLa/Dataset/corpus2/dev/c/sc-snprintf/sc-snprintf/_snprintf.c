/*
**      $VER: _snprintf.c 1.0 (28.12.2007)
**
**      snprintf() for SAS/C (generic)
**
**      (C) Copyright 2007 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifdef AMIGA

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include <proto/exec.h>

#ifdef __SASC
#ifdef _M68000

#include "_snprintf.h"
#undef snprintf

int _snp_disable = FALSE;

int snprintf (char *s, size_t n, const char *format, ...)
{
 if(_snp_disable) return snprintf_unsafe(s, n, format, (((ULONG *)&format)+1));

#ifdef SNPRINTF_UNSAFE
 return snprintf_unsafe(s, n, format, (((ULONG *)&format)+1));
#else
#ifdef SNPRINTF_NOIEEE
 return snprintf_noieee(s, n, format, (((ULONG *)&format)+1));
#else
#ifdef SNPRINTF_IEEE
 return snprintf_ieee(s, n, format, (((ULONG *)&format)+1));
#endif
#endif
#endif
}

#endif
#endif

#endif
