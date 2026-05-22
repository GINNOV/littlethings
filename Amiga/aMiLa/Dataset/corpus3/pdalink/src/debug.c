/*
 * PdaLink -- Connect Palm with Amiga
 *
 * Copyright (C) 1998-2010 Richard "Shred" Körber
 *   http://pdalink.shredzone.org
 *
 * This library is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Debug functions.
 *
 * @author Harry "Piru" Sintonen
 */
 
#include "debug.h"

#ifdef DEBUG

#include <exec/types.h>
#include <proto/exec.h>

#ifndef __MORPHOS__
#include <stdarg.h>
#endif /* __MORPHOS__ */


#ifdef __MORPHOS__

void dprintf(const char *, ...);

#else /* __MORPHOS__ */

void dprintf(const char *format, ...)
{
  struct ExecBase *SysBase;
  static const UWORD dputch[5] = {0xCD4B, 0x4EAE, 0xFDFC, 0xCD4B, 0x4E75};
  va_list args;

  SysBase = *((struct ExecBase **) (4L));
  va_start(args, format);

  RawDoFmt((STRPTR) format, (APTR) args,
           (void (*)()) dputch, (APTR) SysBase);

  va_end(args);
}

#endif /* __MORPHOS__ */


void dumpmem(void *mem, unsigned long int len)
{
  unsigned char *p;

  if (!mem || !len) { return; }

  p = (unsigned char *) mem;

  dprintf("\n");

  do
  {
    unsigned char b, c, *p, str[17];

    for (b = 0; b < 16; b++)
    {
      c = *p++;
      str[b] = ((c >= ' ') && (c <= 'z')) ? c : '.';
      str[b + 1] = 0;
      dprintf("%02lx ", c);
      if (--len == 0) break;
    }

    while (++b < 16)
    {
      dprintf("   ");
    }

    dprintf("  %s\n", str);
  } while (len);

  dprintf("\n\n");
}

#endif /* DEBUG */
