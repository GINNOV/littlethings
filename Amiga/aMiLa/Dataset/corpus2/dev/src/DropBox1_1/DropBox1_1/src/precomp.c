/** DoRev Header ** Do not edit! **
*
* Name             :  precomp.c
* Copyright        :  Copyright 1993. All Rights Reserved
* Creation date    :  11-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 11-Jun-93    1  Steve Anichini       None.
* 11-Jun-93    0  - Unknown -          None.
*
*** DoRev End **/

#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/iffparse.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <exec/libraries.h>
#include <libraries/asl.h>
#include <libraries/commodities.h>
#include <string.h>

#include <proto/icon.h>
#include <proto/exec.h>
#include <proto/wb.h>
#include <proto/commodities.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/gadtools.h>
#include <proto/dos.h>
#include <proto/iffparse.h>
#include <proto/asl.h>


