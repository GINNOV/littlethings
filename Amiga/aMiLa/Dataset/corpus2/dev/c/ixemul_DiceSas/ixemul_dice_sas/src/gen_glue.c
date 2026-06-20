/*
 *  This file is part of ixemul-dice-sas for the Amiga
 *  Copyright (C) 1994
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <sys/syscall.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct syscall
{
  char *name;
  int vec;
}
syscalls[] =
{
#define SYSTEM_CALL(func,vec) #func, vec,
#include <sys/syscall.def>
#undef SYSTEM_CALL
};
int nsyscall = sizeof (syscalls) / sizeof (syscalls[0]);

main ()
{
  FILE *fp1;
#ifdef BASE_RELATIVE
  FILE *fp2;
#endif
  struct syscall *sc;
  int i, v;

  for (i = 0, sc = syscalls; i < nsyscall; i++, sc++)
  {
    char *name1;
#ifdef BASE_RELATIVE
    char *name2;
#endif

    name1 = malloc (strlen (sc->name) + 3);
#ifdef BASE_RELATIVE
    name2 = malloc (strlen (sc->name) + 4);
#endif

    v = -(sc->vec + 4) * 6;

    sprintf (name1, "%s.s", sc->name);
#ifdef BASE_RELATIVE
    sprintf (name2, "%s.bs", sc->name);
#endif

    fp1 = fopen (name1, "w");
#ifdef BASE_RELATIVE
    fp2 = fopen (name2, "w");
#endif

#ifdef BASE_RELATIVE
    if (!fp1 || !fp2)
#else
    if (!fp1)
#endif
    {
      perror (sc->name);
      exit (20);
    }

    if (v > -128)
    {
      fprintf (fp1, "\tsection text,code\n\txref _ixemulbase\n\txdef _%s\n_%s:\tmove.l _ixemulbase,a0\n\tlea %d(a0),a0\n\tjmp (a0)\n\tend\n", sc->name, sc->name, v);
#ifdef BASE_RELATIVE
      fprintf (fp2, "\tsection text,code\n\txref _ixemulbase\n\txdef _%s\n_%s:\tmove.l _ixemulbase(a4),a0\n\tlea %d(a0),a0\n\tjmp (a0)\n\tend\n", sc->name, sc->name, v);
#endif
    }
    else
    {
      fprintf (fp1, "\tsection text,code\n\txref _ixemulbase\n\txdef _%s\n_%s:\tmove.l _ixemulbase,a0\n\tadd.w #%d,a0\n\tjmp (a0)\n\tend\n", sc->name, sc->name, v);
#ifdef BASE_RELATIVE
      if (sc->vec == SYS_ix_geta4)
	fprintf (fp2, "\tsection text,code\n\txref _ixemulbase\n\txdef _%s\n_%s:\tmove.l _ixemulbase,a0\n\tadd.w #%d,a0\n\tjmp (a0)\n\tend\n", sc->name, sc->name, v);
      else
	fprintf (fp2, "\tsection text,code\n\txref _ixemulbase\n\txdef _%s\n_%s:\tmove.l _ixemulbase(a4),a0\n\tadd.w #%d,a0\n\tjmp (a0)\n\tend\n", sc->name, sc->name, v);
#endif
    }

    fclose (fp1);
#ifdef BASE_RELATIVE
    fclose (fp2);
#endif
    free (name1);
#ifdef BASE_RELATIVE
    free (name2);
#endif
  }
}
