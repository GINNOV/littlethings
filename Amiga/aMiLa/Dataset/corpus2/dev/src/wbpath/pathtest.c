;/*
sc resopt ign=73 opt nostkchk link lib wbpath.o icon csrc=pathtest.c
delete pathtest.lnk quiet
quit
*/
/*
** PathTest.c - clone the Workbench process's command path
** Copyright © 1994 by Ralph Babel, Falkenweg 3, D-65232 Taunusstein, FRG
** all rights reserved - alle Rechte vorbehalten
**
** 1994-03-25 created
*/

/*** included files ***/

#define __USE_SYSBASE

#include <exec/types.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <stdlib.h>
#include <stdio.h>
#include "wbpath.h"

/*** entry point ***/

int main(int argc, char *argv[])
 {
 int result;
 BPTR fh;
 BPTR path;

 result = EXIT_FAILURE;

 if(argc == 0) /* Workbench start-up */
  {
  if(DOSBase->dl_lib.lib_Version >= 37)
   {
   if(fh = Open("CON:160/25/320/150/PathTest/AUTO/WAIT", MODE_NEWFILE))
    {
    path = CloneWorkbenchPath((struct WBStartup *)argv);

    if(SystemTags("path", SYS_Output, fh, NP_Path, path, TAG_DONE) != -1)
     {
     result = EXIT_SUCCESS;
     }
    else
     {
     FreeWorkbenchPath(path);
     }

    Close(fh);
    }
   }
  else
   {
   printf("This program requires Kickstart 2.0+.\n");
   Delay(TICKS_PER_SECOND * 4);
   }
  }
 else
  printf("This program needs to be started from Workbench.\n");

 return result;
 }
