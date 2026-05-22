/*
**      $VER: _snprintf_ieee.c 1.0 (28.12.2007)
**
**      snprintf() for SAS/C (IEEE)
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

int snprintf_ieee (char *s, size_t n, const char *format, ...)
{
 FILE *in, *out;
 UBYTE tname[22];

 if(_snp_disable) return snprintf_unsafe(s, n, format, (((ULONG *)&format)+1));

 sprintf(tname, "T:snprintf_%0lx", &s[0]);
               //0123456789012345678901

 out = fopen(tname, "wb");
 if(out)
  {
   size_t nx;

   nx = fprintf(out, format, (((ULONG *)&format)+1));

   fclose(out);

   in = fopen(tname, "rb");
   if(in)
    {
     n = fread(s, 1, min(n,nx), in);
     fclose(in);
    }

   unlink(tname);

  }else
  {
   ULONG d[2];

   d[0] = (ULONG) n;
   d[1] = (ULONG) s;

   RawDoFmt((APTR) format, (APTR) (((ULONG *)&format)+1), (APTR) &PutChProc, (APTR) &d[0]);

   n -= d[0];
  }

 return((int) n);
}

#endif
#endif

#endif
