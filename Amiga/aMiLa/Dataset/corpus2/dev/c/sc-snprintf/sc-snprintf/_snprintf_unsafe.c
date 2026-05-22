/*
**      $VER: _snprintf_unsafe.c 1.0 (28.12.2007)
**
**      snprintf() for SAS/C (unsafe stub)
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

int snprintf_unsafe (char *s, size_t n, const char *format, ...)
{
 sprintf(s, format, (((ULONG *)&format)+1));

 return((int) strlen(s));
}

#endif
#endif

#endif
