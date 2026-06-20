
/*
 * AmigaMesaRTL graphics library
 * Version:  2.0
 * Copyright (C) 1998  Jarno van der Linden
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
 * mesaauto.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Added __stack to set enough stack
 *
 * Version 2.0  06 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Opens v2.0 libraries
 * - Driver got through mesaGetAttr()
 *
 * Version 2.0  10 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Opens v3.0 libraries
 *
 */


#include <exec/types.h>
#include <constructor.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <string.h>

#include "gl/mesamain.h"
#include "gl/mesadriver.h"

extern struct WBStartup *_WBenchMsg;
extern char __stdiowin[];

struct Library *mesamainBase;
struct Library *mesadriverBase;
static void *mainlibbase;

long __stack = 65536;

void mesaautoopenfail(char *lib, int ver)
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

CBMLIB_CONSTRUCTOR(openmesa)
{
   mesamainBase = mainlibbase =
       (void *)OpenLibrary("mesamain.library", 3);
   if (mesamainBase == NULL)
   {
     mesaautoopenfail("mesamain.library", 3);
     return 1;
   }

   mesaGetAttr(MESA_DriverBase,&mesadriverBase);
   if (mesadriverBase == NULL)
   {
     mesaautoopenfail("mesamain.library", 3);
     return 1;
   }

   return 0;
}

CBMLIB_DESTRUCTOR(closemesa)
{
   if (mainlibbase)
   {
      CloseLibrary((struct Library *)mainlibbase);
      mainlibbase = mesamainBase = NULL;
      mesadriverBase = NULL;
   }
}
