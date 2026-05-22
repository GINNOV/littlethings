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
 * Library initialization, C part.
 *
 * @author Richard "Shred" Körber
 */

#include "pdalink_glob.h"

struct DOSBase       *DOSBase;
struct Library       *UtilityBase;
struct Library       *SysBase;
struct Library       *RexxSysBase;
struct Library       *PdalinkBase;

struct Global         global;

/**
 * Initializes the global structure.
 *
 * @return success
 */
static int InitGlobal(void)
{
  for(;;)
  {
    if(!(global.slptrash = AllocMem(1024,MEMF_PUBLIC))) break;

    NewList(&global.rexxHandles);
    InitSemaphore(&global.rexxHandleSemaphore);
    global.rexxHandleOK = TRUE;

    return 1;                   // Okay
  }
  return 0;                     // Failure
}

/**
 * Frees the global structure.
 */
static void ExitGlobal(void)
{
  struct RexxHandle *thisNode, *nextNode;

  if(global.slptrash) FreeMem(global.slptrash,1024);

  if(global.rexxHandleOK)
  {
    global.rexxHandleOK = FALSE;
    ObtainSemaphore(&global.rexxHandleSemaphore);
    for                                                     // Clean up the handle list
    (
      thisNode = (struct RexxHandle *)global.rexxHandles.lh_Head;
      nextNode = (struct RexxHandle *)thisNode->rh_node.ln_Succ;
      thisNode = nextNode
    )
    {
      Remove((struct Node *)thisNode),
      FreeVec(thisNode);
    }
  }

  return;
}

/**
 * Finishes the library.
 */
__saveds __asm void LibExit(void)
{
  ExitGlobal();
  if(DOSBase)       CloseLibrary((struct Library *)DOSBase);
  if(UtilityBase)   CloseLibrary(                  UtilityBase);
  if(RexxSysBase)   CloseLibrary(                  RexxSysBase);
}

/**
 * Initializes the library.
 *
 * @param exec      Reference to exec
 * @param base      Library base
 * @return LibInit structure
 */
__saveds __asm struct Library *LibInit
(
  register __a0 struct Library *exec,
  register __a1 struct Library *base
)
{
  SysBase      = exec;
  PdalinkBase = base;

  for(;;)
  {
    if(!(DOSBase       = (struct DOSBase *)      OpenLibrary("dos.library"        ,36L))) break;
    if(!(UtilityBase   =                         OpenLibrary("utility.library"    ,36L))) break;
    if(!(RexxSysBase   =                         OpenLibrary("rexxsyslib.library" ,36L))) break;

    if(!(InitGlobal()))   break;

    return(base);         // Everything worked fine
  }
  LibExit();
  return(0);
}

