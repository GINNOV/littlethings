
/*
 * [!BGN - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 *******************************************************************
 *
 * Program   : SysTracker (Experimental resource tracking system)
 * Version   : 0.1
 * File      : Work:Source/!WIP/SysTracker/st_main.c
 * Author    : Andrew Bell
 * Copyright : Copyright © 1999-2000 Andrew Bell. All rights reserved.
 * Created   : Wednesday 03-Nov-99 18:00:00
 * Modified  : Monday 14-Feb-00 00:10:00
 * Comment   : 
 *
 * (Generated with StampSource 1.5 by Andrew Bell)
 *
 *******************************************************************
 *
 * [!END - MACHINE GENERATED - DO NOT EDIT THIS HEADER]
 *
 */

/* Created: Wed/03/Nov/1999 */

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/
/* Data and defines */
/***************************************************************************/

struct Process *SysTrackerProcess = NULL;

const UBYTE *VersTag = VERSTAG;

/* Usually command names and sometimes tasks/process names can have
   paths prefixed onto them, the next BOOL tells SysTracker to strip
   them else leave them alone. */

BOOL cfg_RemovePaths = TRUE;

/* This is a special BOOL that determines if SysTracker should do
   things that would be considered illegal by the system. For example,
   accessing the exec lists in ExecBase. Setting this to FALSE makes
   SysTracker more accurate in some areas. */

BOOL cfg_BeSystemLegal = FALSE;

/* Set this to TRUE if the lister should update automatically, so the
   user doesn't have to click the "Update" button.

   Note: There seems to be a bug that causes every entry in the list
         to be cloned when the user flushes dead apps, when the
         following is set to TRUE. */

BOOL cfg_AutoUpdate = FALSE; /* !!This has since been removed!! */

/* Use this BOOL to turn debugging on and off. */

BOOL cfg_DebugMode = FALSE;

/* This tells the ARTL handler to keep track of resources that have
   been freed. Setting this to TRUE is useful sometimes because it
   allows the user to see all of the resources that have been accessed
   by an application, instead of the currently allocated resources.
   
   Setting this to TRUE eats up more memory and slows down SysTracker. It
   also tends to make the "Update" button unresponsive since the ARTL
   Handler is semaphore locking the ARTL list more frequently. */

BOOL cfg_TrackUnusedResources = FALSE;

/* If this is TRUE, SysTracker will show unused resources as well as
   used resources. This flag only makes sense when the
   cfg_TrackUnusedResources flags is also TRUE. */

BOOL cfg_ShowUnusedResources  = TRUE;

/***************************************************************************/

LPROTO LONG wbmain( void )
{
  /*********************************************************************
   *
   * wbmain()
   *
   * Workbench entry point.
   *
   *********************************************************************
   *
   */

  return main();
}

LPROTO int main( void )
{
  /*********************************************************************
   *
   * main()
   *
   * Need I say more? :-)
   *
   *********************************************************************
   *
   */

  static int retcode = RETURN_FAIL; /* Keep static! */

  #define SYSTRACKER_PRIORITY 1

  SetTaskPri(FindTask(NULL), SYSTRACKER_PRIORITY);

  if (MEM_Init())
  {   
    if (R_GetTasksStackSize() >= STACKSIZE)
    {
      if (M_InitPrg())
      {
        M_DoPrg(); retcode = RETURN_OK;
      }
      M_EndPrg();
    }
    else
    {
      /* OK, the environment that launched us hasn't provided us with
         enough stack space, so we'll swap in a new stack. We need at
         least 32KB of stack space. */

      static UBYTE *StackVec = NULL;

      /* Note: We *MUST* keep this off the stack, because most (if
         not all) compilers store automatic/local variables on the
         stack. So if the StackSwapStruct ends up on the stack, we
         will have a little predicament. :) */

      static struct StackSwapStruct SSS;

      /* It's important that we use MEMF_PUBLIC for the stack memory! */

      if (StackVec = AllocVec(STACKSIZE, MEMF_PUBLIC | MEMF_CLEAR))
      {
        /* If StackSwap() fails altogether on your compiler you need
           to remove this code and call it from some custom assembly
           startup code. btw, you can't call StackSwap() with stubs
           since the first and second StackSwap() calls need to be
           called on the same stack level (i.e. in parallel). */

        SSS.stk_Lower = StackVec;
        SSS.stk_Upper = (ULONG) (StackVec + STACKSIZE);
        SSS.stk_Pointer = (APTR) SSS.stk_Upper;
        StackSwap(&SSS);

        if (M_InitPrg())
        {
          M_DoPrg(); retcode = RETURN_OK;
        }
        M_EndPrg();

        StackSwap(&SSS);
        FreeVec(StackVec);
      }
      else M_PrgError(STR_Get(SID_CANT_GET_STACK_MEM), NULL);
    }
    MEM_Free();   
  }
  else M_PrgError(STR_Get(SID_CANT_GET_MEMORY_RESOURCES), NULL);

  Delay(20); /* Very small delay, just to make sure the child process
                has time to RTS back into DOS after it signalled us.
                This reduces any possible chance of us ripping our
                seglist from under the child process. */

  return retcode;
}

GPROTO void DEBUG( void )
{
 /* I use this for manual breakpoints */
}

LPROTO BOOL M_InitPrg( void )
{
  /*********************************************************************
   *
   * M_InitPrg()
   *
   * Initialize the program. 
   *
   *********************************************************************
   *
   */

  SysTrackerProcess = (struct Process *) FindTask(NULL);

  if (!(SysBase->AttnFlags & AFF_68020))
  {
    M_PrgError(STR_Get(SID_OLD_CPU), NULL);
    return FALSE;
  }

  if (SysBase->LibNode.lib_Version < 39)
  {
    M_PrgError(STR_Get(SID_OLD_OS), NULL);
    return FALSE;
  }

  if (!LIBS_Init()) return FALSE;
  if (!GUI_Construct()) return FALSE;

  return TRUE;
}

LPROTO void M_EndPrg( void )
{
  /*********************************************************************
   *
   * M_EndPrg()
   *
   * Free the resources allocated by M_EndPrg().
   *
   *********************************************************************
   *
   */

  GUI_Destruct();
  LIBS_Free();
}

LPROTO void M_DoPrg( void )
{
  /*********************************************************************
   *
   * M_DoPrg()
   *
   * The main program.
   *
   *********************************************************************
   *
   */

  if (ARTL_Init()) /* Launch the ARTL handler process */
  {
    for (;;)
    {
      GUI_Act_Window_Open(OID_MAIN_WINDOW, TRUE);   
      GUI_EventHandler(); 
      if (ARTL_Free()) break;
    }
  }
  else
  {
    ARTL_Free();
    M_PrgError(STR_Get(SID_CANT_INVOKE_HANDLER), NULL);
  }
}

GPROTO void M_PrgError( UBYTE *ErrStr, APTR ErrFmt )
{
  /*********************************************************************
   *
   * M_PrgError()
   *
   * Show an error requester.
   *
   *********************************************************************
   *
   */

  GUI_Popup(STR_Get(SID_ERROR), ErrStr, ErrFmt, STR_Get(SID_OK));
}




