/*
 * Amiga GLUT graphics library toolkit
 * Version:  2.0
 * Copyright (C) 1998 Jarno van der Linden
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * glutauto.c
 *
 * Version 2.0  16 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 */


#include <exec/types.h>
#include <constructor.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <string.h>

#include "gl/glut.h"

extern struct WBStartup *_WBenchMsg;
extern char __stdiowin[];

struct Library *glutBase;
static void *libbase;

extern struct Library *mesamainBase;
extern struct Library *mesadriverBase;

void glutautoopenfail(char *lib, int ver)
{
   struct DOSBase *DOSBase;
   long fh;
   char buf[50];

   DOSBase = (struct DOSBase *)OpenLibrary("dos.library",0);
   if (_WBenchMsg == NULL)
      fh = Output();
   else
      fh = Open(__stdiowin, MODE_NEWFILE);

   if (fh)
   {
       RawDoFmt("Can't open version %ld of ",
                &ver, (void (*))"\x16\xC0\x4E\x75", buf);

       Write(fh, buf, strlen(buf));
       Write(fh, lib, strlen(lib));
       Write(fh, "\n", 1);

       if (_WBenchMsg)
       {
           Delay(200);
           Close(fh);
       }
   }


   CloseLibrary((struct Library *)DOSBase);
   ((struct Process *)FindTask(NULL))->pr_Result2 =
                      ERROR_INVALID_RESIDENT_LIBRARY;

}

CBMLIB_CONSTRUCTOR(openglut)
{
   glutBase = libbase =
       (void *)OpenLibrary("glut.library", 2);
   if (glutBase == NULL)
   {
     glutautoopenfail("glut.library", 2);
     return 1;
   }

   glutAssociateGL(mesamainBase,mesadriverBase);

   return 0;
}

CBMLIB_DESTRUCTOR(closeglut)
{
   if (libbase)
   {
      CloseLibrary((struct Library *)libbase);
      libbase = glutBase = NULL;
   }
}
