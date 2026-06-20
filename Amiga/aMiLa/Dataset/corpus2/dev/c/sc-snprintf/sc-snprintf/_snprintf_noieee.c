/*
**      $VER: _snprintf_noieee.c 1.0 (28.12.2007)
**
**      snprintf() for SAS/C (no IEEE)
**
**      (C) Copyright 2007 Andreas R. Kleinert
**      All Rights Reserved.
*/

#ifdef AMIGA

#include <stdio.h>
#include <stdarg.h>
#include <limits.h>

#include <proto/exec.h>

#ifdef __SASC
#ifdef _M68000

#include "_snprintf.h"

#define min(a, b) (a < b ? a : b)

static void __asm PutChProc( register __d0 UBYTE c, register __a3 ULONG *data)
{
 if(data[0]--) *((UBYTE *)data[1]++) = c;
}

int snprintf_noieee (char *s, size_t n, const char *format, ...)
{
 ULONG d[2];

 if(_snp_disable) return snprintf_unsafe(s, n, format, (((ULONG *)&format)+1));

 d[0] = (ULONG) n;
 d[1] = (ULONG) s;

 RawDoFmt((APTR) format, (APTR) (((ULONG *)&format)+1), (APTR) &PutChProc, (APTR) &d[0]);

 return( (int) (n - d[0]));
}

#endif
#endif

#endif
