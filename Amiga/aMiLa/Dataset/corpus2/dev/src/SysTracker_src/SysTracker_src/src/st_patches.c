/***************************************************************************/
/* st_patches - Patch control module.                                      */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/
/* Patch variables */
/***************************************************************************/

APTR OriginalOpenLibrary = NULL;
APTR OriginalCloseLibrary = NULL;
APTR OriginalOpenDevice = NULL;
APTR OriginalCloseDevice = NULL;
APTR OriginalOpenFont = NULL;
APTR OriginalCloseFont = NULL;
APTR OriginalOpen = NULL;
APTR OriginalClose = NULL;
APTR OriginalLock = NULL;
APTR OriginalUnLock = NULL;
APTR OriginalOpenFromLock = NULL;

/* Use the PATCH_AllocVec() routine (in the st_patches module) to safely
   allocate memory on this pool. Use PATCH_FreeVec() to free it. */

APTR PatchPool;
struct SignalSemaphore PatchPoolKey;
BOOL PatchesInstalled = FALSE;

struct PatchData
{
  struct Library **pd_BasePtr;
  LONG             pd_LVO;
  APTR             pd_PatchCode;
  APTR            *pd_OrigFunc;
  APTR             pd_AlienFunc;
  UBYTE           *pd_LVOName;
};

struct PatchData PD[] = 
{
  /************** OpenLibrary()/CloseLibrary() *************************/

  { (struct Library **) &SysBase,
    (LONG) &LVOOpenLibrary,
    &PATCH_NewOpenLibrary,
    &OriginalOpenLibrary,
    NULL,
    "exec.library/OpenLibrary()" },

  { (struct Library **) &SysBase,
    (LONG) &LVOCloseLibrary,
    &PATCH_NewCloseLibrary,
    &OriginalCloseLibrary,
    NULL,
    "exec.library/CloseLibrary()" },

  /************** OpenDevice()/CloseDevice() ***************************/

  { (struct Library **) &SysBase,
    (LONG) &LVOOpenDevice,
    &PATCH_NewOpenDevice,
    &OriginalOpenDevice,
    NULL,
    "exec.library/OpenDevice()" },

  { (struct Library **) &SysBase,
    (LONG) &LVOCloseDevice,
    &PATCH_NewCloseDevice,
    &OriginalCloseDevice,
    NULL,
    "exec.library/CloseDevice()" },

  /************** OpenFont()/CloseFont() *******************************/

  { (struct Library **) &GfxBase,
    (LONG) &LVOOpenFont,
    &PATCH_NewOpenFont,
    &OriginalOpenFont,
    NULL,
    "graphics.library/OpenFont()" },
    
  { (struct Library **) &GfxBase,
    (LONG) &LVOCloseFont,
    &PATCH_NewCloseFont,
    &OriginalCloseFont,
    NULL,
    "graphics.library/CloseFont()" },

  /************** Open()/Close() ***************************************/

  { (struct Library **) &DOSBase,
    (LONG) &LVOOpen,
    &PATCH_NewOpen,
    &OriginalOpen,
    NULL,
    "dos.library/Open()" },

  { (struct Library **) &DOSBase,
    (LONG) &LVOClose,
    &PATCH_NewClose,
    &OriginalClose,
    NULL,
    "dos.library/Close()" },

  /************** Lock()/UnLock() **************************************/

  { (struct Library **) &DOSBase,
    (LONG) &LVOLock,
    &PATCH_NewLock,
    &OriginalLock,
    NULL,
    "dos.library/Lock()" },

  { (struct Library **) &DOSBase,
    (LONG) &LVOUnLock,
    &PATCH_NewUnLock,
    &OriginalUnLock,
    NULL,
    "dos.library/UnLock()" },

  /************** OpenFromLock() ***************************************/

  { (struct Library **) &DOSBase,
    (LONG) &LVOOpenFromLock,
    &PATCH_NewOpenFromLock,
    &OriginalOpenFromLock,
    NULL,
    "dos.library/OpenFromLock()" },

  /*********************************************************************/

  { NULL,
    0,
    NULL,
    NULL,
    NULL,
    "" }
};

/***************************************************************************/
/* Note: These PATCH_#? routines are called on the context of the
         ARTL-Handler thread. We need to keep them thread safe incase we
         decide to call any of the code from the main SysTracker thread.

   Idea: Look for SegTracker, if it's available use it to determine where
         the alien LVOs are pointing to. */

GPROTO BOOL PATCH_Init( void )
{
  /*********************************************************************
   *
   * PATCH_Init()
   *
   * Install the patches onto the system and allocate any related
   * resources such as the PatchPool. The semaphore for this pool is
   * also initialized.
   *
   *********************************************************************
   *
   */

  register struct PatchData *PDPtr = PD;

  PatchesInstalled = FALSE;
  
  /* Setup a semaphore protected multiple task memory pool. This pool
     is used by the installed patches for PatchMsgs, etc. */
  
  memset(&PatchPoolKey, 0, sizeof(struct SignalSemaphore));
  InitSemaphore((struct SignalSemaphore *) &PatchPoolKey);

  PatchPool = (APTR) CreatePool(MEMF_CLEAR | MEMF_PUBLIC,
                                  POOL_PUDDLESIZE, POOL_THRESHSIZE);

  if (!PatchPool) return FALSE;

  Forbid();
  while (PDPtr->pd_BasePtr)
  {
    *PDPtr->pd_OrigFunc = SetFunction(*PDPtr->pd_BasePtr,
                                       PDPtr->pd_LVO,
                                       PDPtr->pd_PatchCode);                                       

    PDPtr++;
  }
  PatchesInstalled = TRUE;
  Permit();

  return TRUE;
}

GPROTO BOOL PATCH_Free( void )
{
  /*********************************************************************
   *
   * PATCH_Free()
   *
   * Attempt to remove the resources and patches installed by
   * PATCH_Init(). This routine will return TRUE on success or FALSE on
   * failure. This routine will also free any resources allocated by
   * PATCH_Init().
   *
   *********************************************************************
   *
   */

  if (PatchesInstalled)
  {
    register UBYTE *StrVec = NULL;
    Forbid();
    if (PATCH_CheckUnpatch())
    {
      /* All patches can now be removed. */

      register struct PatchData *PDPtr = PD;
      while (PDPtr->pd_BasePtr)
      {
        SetFunction(*PDPtr->pd_BasePtr,
                     PDPtr->pd_LVO,
                    *PDPtr->pd_OrigFunc);
        PDPtr++;
      }
      PatchesInstalled = FALSE;
      Permit();
      return TRUE; /* Patches were successfully removed. */
    }
    else
    {
      Permit();

      if (StrVec = MEM_AllocVec(1024L))  /* Grab some memory for the string */
      {
        register UBYTE *LVOInfoStr = STR_Get(SID_LVO_POINTS_TO);
        UBYTE LVOInfoBuf[64];
        register struct PatchData *PDPtr = PD;

        /* Construct the failure string. */

        strcpy(StrVec, STR_Get(SID_CANT_REMOVE_PATCHES));
        while (PDPtr->pd_BasePtr)
        {
          strcat(StrVec, PDPtr->pd_LVOName);
          strcat(StrVec, " ");

          if (PDPtr->pd_AlienFunc == NULL)
          {
            strcat(StrVec, STR_Get(SID_LVO_OK));
          }
          else
          {
            sprintf(LVOInfoBuf, LVOInfoStr,
              PDPtr->pd_AlienFunc, PDPtr->pd_PatchCode);
            strcat(StrVec, LVOInfoBuf);
          }

          PDPtr++;
        }
        if (StrVec[strlen(StrVec) - 2] == ',')
          StrVec[strlen(StrVec) - 2] = ' ';
        strcat(StrVec, STR_Get(SID_PLEASE_REMOVE_HACKS));
        GUI_Popup(STR_Get(SID_ERROR_REMOVING_PATCHES),
                  StrVec, NULL, STR_Get(SID_OK_I_WILL));

        MEM_FreeVec(StrVec);  
      }
      return FALSE; /* One or more of the LVOs have changed since
                       PATCH_Init() was called. */
    }
  }

  if (PatchPool)
  {
    DeletePool(PatchPool); PatchPool = NULL;
  }
  return TRUE; /* Routine was successful. */
}

GPROTO BOOL PATCH_CheckUnpatch( void )
{
  /*********************************************************************
   *
   * PATCH_CheckUnpatch()
   *
   * Determine if it's OK to remove our patches, if not, identify those
   * LVOs that have since been patched after PATCH_Init() was called.
   *
   * This routine will return FALSE if SysTracker's patches cannot be
   * removed. This code should really be called under a Forbid().
   *
   *********************************************************************
   *
   */

  register BOOL Success = TRUE;
  register struct PatchData *PDPtr = PD;

  Forbid();
  while (PDPtr->pd_BasePtr)
  {
    PDPtr->pd_AlienFunc = PATCH_CheckLVO(*PDPtr->pd_BasePtr,
                                          PDPtr->pd_LVO,
                                          PDPtr->pd_OrigFunc,
                                          PDPtr->pd_PatchCode);
    if (PDPtr->pd_AlienFunc != NULL)
      Success = FALSE;

    PDPtr++;
  }
  Permit();
  return Success;
}

LPROTO APTR PATCH_CheckLVO( struct Library *LibBase, LONG LVO,
  APTR OrigFunc, APTR ShouldBeFunc )
{
  /*********************************************************************
   *
   * PATCH_CheckLVO()
   *
   * Check an individual LVO to see if it points to the provided
   * function pointer. This routine will return NULL if the patch is
   * OK, else a pointer to the alien function.
   *
   * Parameters
   * ----------
   *
   * LibBase      - LibBase of the library that the LVO belongs to.
   * LVO          - LVO in question.
   * OrigFunc     - The function that you replaced. i.e. the pointer
   *                returned by SetFunction() when you first installed
   *                your patch.
   * ShouldBeFunc - What the LVO should point to. i.e. the function
   *                pointer you passed to SetFunction()'s newFunction
   *                paramter, when you first installed your patch.
   *
   *********************************************************************
   *
   */

  register APTR AlienFunc = NULL;
  register APTR CurrentFunc = NULL;

  Forbid();
  CurrentFunc = SetFunction(LibBase, LVO, OrigFunc);
  if (CurrentFunc != ShouldBeFunc)
  {
    AlienFunc = CurrentFunc;
  }
  SetFunction(LibBase, LVO, CurrentFunc);
  Permit();
  return AlienFunc;
}






