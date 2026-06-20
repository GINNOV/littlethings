/***************************************************************************/
/* st_artl.c - The Application Resource Tracker List (ARTL).               */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/
/* Data and defines */
/***************************************************************************/

ULONG ARTL_TrackMode = TRACKMODE_LIBRARIES; /* Default */
struct AppList *ARTL = NULL;

/* SysTracker <-> ATRL-Handler IPC */

BYTE ARTLInitSig_Running         = -1; /* Child process is running OK. */
ULONG ARTLInitSigMask_Running    = 0;
BYTE ARTLInitSig_NotRunning      = -1; /* Child process failed to start.  */
ULONG ARTLInitSigMask_NotRunning = 0;

struct Process *ARTLProcess = NULL;
struct MsgPort *ARTLProcessPort = NULL;

struct ARTLProcessMsg /* aka APM */
{
  struct Message apm_Msg;
  LONG           apm_CmdID;
};

enum /* The command set is fairly basic atm. */
{
  APM_CMDID_NOP = 0,
  APM_CMDID_QUIT
};

/***************************************************************************/

GPROTO BOOL ARTL_Init( void )
{
  /*********************************************************************
   *
   * ARTL_Init()
   *
   * This routine is called by the main SysTracker process. It is
   * responsible for allocating all IPC related resources and invoking
   * the ARTL handler (child) process. It will return TRUE for success
   * else FALSE for failure.
   *
   *********************************************************************
   *
   */

  ARTLInitSig_Running = AllocSignal(-1);
  if (ARTLInitSig_Running == -1) return FALSE;
  ARTLInitSig_NotRunning = AllocSignal(-1);
  if (ARTLInitSig_NotRunning == -1) return FALSE;

  /* Create the signal masks */

  ARTLInitSigMask_Running     = (1 << ARTLInitSig_Running);
  ARTLInitSigMask_NotRunning  = (1 << ARTLInitSig_NotRunning);

  /* Some defines that will be moved to a header file later. */
  
  #define ARTL_PROCESS_NAME      "SysTracker's ARTL Handler"
  #define ARTL_PROCESS_PRIORITY  -1
  #define ARTL_PROCESS_STACKSIZE (1024 * 16)

  if (ARTLProcess = CreateNewProcTags(
                      NP_StackSize, ARTL_PROCESS_STACKSIZE,
                      NP_Name,      ARTL_PROCESS_NAME,
                      NP_Priority,  ARTL_PROCESS_PRIORITY,
                      NP_Entry,     &ARTL_HandlerProcess,
                      TAG_DONE))
  {
    register ULONG SigsGot = 0;

    SigsGot = Wait(SIGBREAKF_CTRL_C |
                   ARTLInitSigMask_Running |
                   ARTLInitSigMask_NotRunning);

    if (SigsGot & ARTLInitSigMask_Running)    
    {
      /* OK, The process says it's running, if this is the
         case then initialization was successful. Continue on
         as normal. ARTLProcessPort will be valid. */
    }
    else if ((SigsGot & ARTLInitSigMask_NotRunning) ||
             (SigsGot & SIGBREAKF_CTRL_C))
    {
      /* The process says it's going to quit, if this is the
         case then initialization was not successful. */

      ARTLProcess = NULL;
      return FALSE;
    }
  }
  else return FALSE;

  return TRUE;
}

GPROTO BOOL ARTL_Free( void )
{
  /*********************************************************************
   *
   * ARTL_Free()
   *
   * This routine will attempt to quit the ARTL process and free all
   * allocated IPC related resources. It returns TRUE on success else
   * FALSE on failure. Typically FALSE is returned when the ARTL
   * handler process can't remove it's patches from the system.
   *
   *********************************************************************
   *
   */

  if (ARTLProcess && ARTLProcessPort)
  {
    register ULONG SigsGot = 0;

    if (!ARTL_SendSimpleAPMCmd(APM_CMDID_QUIT))
      return FALSE;

    SigsGot = Wait(SIGBREAKF_CTRL_C |
                   ARTLInitSigMask_Running |
                   ARTLInitSigMask_NotRunning);

    if (SigsGot & ARTLInitSigMask_Running)
    {
      /* The process can't quit, probably because it can't remove
         the patches. If this is the case then return FALSE, this will
         make SysTracker go back into it's main loop. */

      return FALSE;
    }
    else if ((SigsGot & ARTLInitSigMask_NotRunning) ||
             (SigsGot & SIGBREAKF_CTRL_C))
    {
      ARTLProcess = NULL;
    }
  }

  /* Free the signals */

  if (ARTLInitSig_Running != -1)
  {
    FreeSignal(ARTLInitSig_Running); ARTLInitSig_Running = -1;
  }

  if (ARTLInitSig_NotRunning != -1)
  {
    FreeSignal(ARTLInitSig_NotRunning); ARTLInitSig_NotRunning = -1;
  }
}

GPROTO BOOL ARTL_SendSimpleAPMCmd( LONG CmdID )
{
  /*********************************************************************
   *
   * ARTL_SendSimpleAPMCmd()
   *
   * Send a simple command to the ARTL-Handler that requires no
   * parameters. 
   *
   *********************************************************************
   *
   */

  struct ARTLProcessMsg APM;
  memset(&APM, 0, sizeof(struct ARTLProcessMsg));
  APM.apm_CmdID = CmdID;
  return ARTL_SendAPM(&APM)
}

GPROTO BOOL ARTL_SendAPM( struct ARTLProcessMsg *APM )
{
  /*********************************************************************
   *
   * ARTL_SendAPM()
   *
   * Send an ARTLProcessMsg to the ARTL-Handler process. This routine
   * does all the dirty work like setting up the message header.
   *
   *********************************************************************
   *
   */

  struct MsgPort *TmpReplyPort = NULL;  
  if (!APM || !ARTLProcessPort) return FALSE;

  if (TmpReplyPort = CreateMsgPort())
  {
    APM->apm_Msg.mn_Node.ln_Type = NT_MESSAGE;
    APM->apm_Msg.mn_Length       = sizeof(struct ARTLProcessMsg);
    APM->apm_Msg.mn_ReplyPort    = TmpReplyPort;
    PutMsg(ARTLProcessPort, (struct Message *)APM);
    Wait(1UL << TmpReplyPort->mp_SigBit);
    DeleteMsgPort(TmpReplyPort);
    return TRUE;
  }
  return FALSE;
}

GPROTO struct AppList *ARTL_GetAppList( void )
{
  return ARTL;
}

GPROTO void ARTL_Set_TrackMode( ULONG NewTrackMode )
{
  ARTL_TrackMode = NewTrackMode;
}

GPROTO ULONG ARTL_Get_TrackMode( void )
{
  return ARTL_TrackMode;
}

GPROTO BOOL ARTL_CheckProcSignals( ULONG SigsGot )
{
  /*********************************************************************
   *
   * ARTL_CheckProcSignals()
   *
   * This routine is called by the main SysTracker task when it receives
   * some signals. This routine handles all of the ARTL process related
   * signals. TRUE will be returned if SysTracker must quit.
   *
   *********************************************************************
   *
   */
      
  if (SigsGot & ARTLInitSigMask_NotRunning)
  {
    /* If we get this signal we must assume that something
       has went wrong. */

    ARTLProcess = NULL; /* So ARTL_Free() knows the process is dead. */
    return TRUE;
  } 
  return FALSE;
}

/* ARTL handler process variables
   ------------------------------
   The ARTL AppList pointer belongs to the ARTL handler process,
   and can *only* be access after the main SysTracker has received
   the ARTLInitSig_Running signal. */

struct MsgPort *PatchPort = NULL;
ULONG PMsgCnt = 0;
BPTR DebugFH = 0;

GPROTO ULONG ARTL_GetPMsgCnt( void )
{
  return PMsgCnt;
}

LPROTO LONG ARTL_HandlerProcess( void )
{
  /*********************************************************************
   *
   * ARTL_HandlerProc_Entry()
   *
   * This entire sub routine is an independent process that is launched
   * by the main SysTracker process. This process is responsible for
   * handling the PatchMsgs that arrive at the PatchPort, updating the
   * main AppList tree per message. Because a constant stream of
   * PatchMsgs may be arriving at the port, we use an independent
   * process to handle the messages. This frees up the main SysTracker
   * process, so it can handle the user's input, etc.
   *
   *********************************************************************
   *
   */

  /* Note: SysTracker is always compiled under a large code model, so
           doesn't require A4 to be setup. */

  BOOL Success = FALSE; /* Assume failure */

  if (ATRL_InitHandlerDebug())
  {
    if ((PatchPort = CreateMsgPort()) &&
        (ARTLProcessPort = CreateMsgPort()))
    {
      ULONG PatchPort_SigMask = 1UL << PatchPort->mp_SigBit;
      ULONG ARTLProcessPort_SigMask = 1UL << ARTLProcessPort->mp_SigBit;
      register struct PatchMsg *PMsg = NULL;
      register struct ARTLProcessMsg *APM = NULL;

      if (ARTL = ARTL_AllocAL())
      {
        if (PATCH_Init())
        {
          Success = TRUE;
          Signal((struct Task *)SysTrackerProcess, ARTLInitSigMask_Running);

          for (;;)
          {
            BOOL Running = TRUE;
            ULONG SigEvent = 0;

            while (Running)
            {
              SigEvent = Wait(PatchPort_SigMask | ARTLProcessPort_SigMask);

              if (SigEvent & PatchPort_SigMask)
              {
                while (PMsg =
                   (struct PatchMsg *) GetMsg((struct MsgPort *) PatchPort))
                {                 
                  PMsgCnt += 1;
                  if (cfg_DebugMode) ARTL_PMsgDebug(PMsg);

                  switch(PMsg->pmsg_ID)
                  {
                    case PMSGID_OPENLIBRARY:
                      ARTL_PushLibAN( ARTL, PMsg ); break;
                    case PMSGID_CLOSELIBRARY:
                      ARTL_PullLibAN( ARTL, PMsg ); break;
                    case PMSGID_OPENDEVICE:
                      ARTL_PushDevAN( ARTL, PMsg ); break;
                    case PMSGID_CLOSEDEVICE:
                      ARTL_PullDevAN( ARTL, PMsg ); break;
                    case PMSGID_OPENFONT:
                      ARTL_PushFontAN( ARTL, PMsg ); break;
                    case PMSGID_CLOSEFONT:
                      ARTL_PullFontAN( ARTL, PMsg ); break;
                    case PMSGID_LOCK:
                      ARTL_PushLockAN( ARTL, PMsg ); break;
                    case PMSGID_UNLOCK:
                      ARTL_PullLockAN( ARTL, PMsg ); break;
                    case PMSGID_OPEN:
                      ARTL_PushFileHandleAN( ARTL, PMsg ); break;
                    case PMSGID_CLOSE:
                      ARTL_PullFileHandleAN( ARTL, PMsg ); break;
                    case PMSGID_OPENFROMLOCK:
                      ARTL_PushFileHandleAN( ARTL, PMsg ); break;
                    default: break;
                  }

                  PATCH_DeletePatchMsg(PMsg);
                } /* while () */
                /* REMOVED: if (cfg_AutoUpdate) ACT_Main_Update();*/
              }

              if (SigEvent & ARTLProcessPort_SigMask)
              {
                /* The main ARTL process is communicating with us. */               

                while (APM = (struct ARTLProcessMsg *) GetMsg(ARTLProcessPort))
                {
                  switch(APM->apm_CmdID)
                  {
                    default:
                    case APM_CMDID_NOP: break;
                    case APM_CMDID_QUIT: Running = FALSE; break;
                  }
                  ReplyMsg((struct Message *)APM);
                }
              }
            } /* while () */

            if (PATCH_Free()) break;
            else Signal((struct Task *)SysTrackerProcess,
                  ARTLInitSigMask_Running);

          } /* for (;;) */                
        }
        ARTL_FreeAL(ARTL); ARTL = NULL;
      }

      /* Free any pending messages on the PatchPort */  
      while (PMsg = (struct PatchMsg *) GetMsg( (struct MsgPort *) PatchPort))
        PATCH_DeletePatchMsg(PMsg);
    }

    if (PatchPort)
      DeletePort(PatchPort); PatchPort = NULL;

    if (ARTLProcessPort)
      DeletePort(ARTLProcessPort); ARTLProcessPort = NULL;
  }
  ATRL_EndHandlerDebug();
  ARTLProcess = NULL;

  Signal((struct Task *) SysTrackerProcess, ARTLInitSigMask_NotRunning);
  return RETURN_OK;
}

LPROTO BOOL ATRL_InitHandlerDebug( void )
{
  /*********************************************************************
   *
   * ATRL_InitHandlerDebug()
   *
   * Allocate the handler debugging resources.
   *
   *********************************************************************
   *
   */

  #define DEBUG_DEST "CON:0/11/640/60/ARTL_Handler_Debug_window/CLOSE"
  /*#define DEBUG_DEST "Ram:SysTracker_debug.log"*/

  if (!cfg_DebugMode) return TRUE;
  if (!(DebugFH = Open(DEBUG_DEST , MODE_NEWFILE))) return FALSE;

  return TRUE;
}

LPROTO void ATRL_EndHandlerDebug( void )
{
  /*********************************************************************
   *
   * ATRL_EndHandlerDebug()
   *
   * Free the handler debugging resources.
   *
   *********************************************************************
   *
   */
  
  if (!cfg_DebugMode) return;
  if (DebugFH)
  {
    Close(DebugFH); DebugFH = 0;
  }
}

LPROTO void ARTL_PMsgDebug( struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PMsgDebug()
   *
   * Print some debug information about a PatchMsg structure.
   *
   *********************************************************************
   *
   */

  register UBYTE *LVOName = NULL;
  register UBYTE *AppName = NULL;
  struct AppNode *AN = NULL;
  struct TrackerNode *TN =  NULL;

  if (!PMsg) return;

  AppName =
     (PMsg->pmsg_CmdName ? PMsg->pmsg_CmdName : PMsg->pmsg_TaskName);

  if (!AppName || strlen(AppName) == 0) AppName = "(Unnamed task)";

  ARTL_LockAL(ARTL);

  AN = ARTL_FindAN_ViaTaskPtr(ARTL, PMsg->pmsg_TaskPtr);

  switch(PMsg->pmsg_ID)
  {
    case PMSGID_OPENLIBRARY:
      FPrintf(DebugFH, "%-010.010s OpenLibrary(\"%s\", %ld)\n",
        AppName, PMsg->pmsg_LibName, PMsg->pmsg_LibVer);
      break;

    case PMSGID_OPENDEVICE:
      FPrintf(DebugFH,
        "%-010.010s OpenDevice(\"%s\", %ld, 0x%08lx, 0x%08lx)\n",
        AppName, PMsg->pmsg_DevName,
        PMsg->pmsg_DevUnitNum, PMsg->pmsg_DevIOReq, PMsg->pmsg_DevFlags);
      break;

    case PMSGID_CLOSELIBRARY:
      if (AN)
      {
        TN = ARTL_FindLibTN_ViaLibBase(
          (struct List *) &AN->an_TrackerList, PMsg->pmsg_LibBase);
      }
      FPrintf(DebugFH,
        "%-010.010s CloseLibrary($%08lx) [%s] AN=$%08lx TN=$%08lx\n",
        AppName, PMsg->pmsg_LibBase, PMsg->pmsg_LibName, AN, TN);
      break;

    case PMSGID_CLOSEDEVICE:
      if (AN)
      {
        TN = ARTL_FindDevTN_ViaIOReq(
          (struct List *) &AN->an_TrackerList, PMsg->pmsg_DevIOReq);
      }
      FPrintf(DebugFH,
        "%-010.010s CloseDevice($%08lx) [%s] AN=$%08lx TN=$%08lx\n",
        AppName, PMsg->pmsg_DevIOReq,
        (TN ? TN->tn_DevName : "???"), AN, TN);
      break;

    case PMSGID_OPENFONT:
      FPrintf(DebugFH,
        "%-010.010s OpenFont($%08lx) [%s/%ld]\n",
        AppName, PMsg->pmsg_FontTextAttr,
        PMsg->pmsg_FontName, (LONG) PMsg->pmsg_FontYSize);
      break;

    case PMSGID_CLOSEFONT:
      if (AN)
      {
        TN = ARTL_FindFontTN_ViaTextFont(
          (struct List *) &AN->an_TrackerList, PMsg->pmsg_FontTextFont);
      }
      FPrintf(DebugFH,
        "%-010.010s CloseFont($%08lx) [%s] AN=$%08lx TN=$%08lx\n",
        AppName, PMsg->pmsg_FontTextFont,
        (TN ? TN->tn_FontName : "???"), AN, TN);
      break;

    case PMSGID_OPEN:
      FPrintf(DebugFH,
        "%-010.010s Open(%.256s,%ld) [FH=$%08lx]\n",
        AppName, PMsg->pmsg_FHName, PMsg->pmsg_FHMode, PMsg->pmsg_FH);
      break;

    case PMSGID_CLOSE:
      FPrintf(DebugFH,
        "%-010.010s Close($%08lx)\n",
        AppName, PMsg->pmsg_FH);
      break;

    case PMSGID_OPENFROMLOCK:
      FPrintf(DebugFH,
        "%-010.010s OpenFromLock($%08lx) [FH=$%08lx]\n",
        AppName, PMsg->pmsg_Lock, PMsg->pmsg_Lock);
      break;

    case PMSGID_LOCK:
      FPrintf(DebugFH,
        "%-010.010s Lock(%.256s,%ld) [LOCK=$%08lx]\n",
        AppName, PMsg->pmsg_LockName,
        PMsg->pmsg_LockMode, PMsg->pmsg_Lock);
      break;

    case PMSGID_UNLOCK:
      FPrintf(DebugFH,
        "%-010.010s UnLock($%08lx)\n",
        AppName, PMsg->pmsg_Lock);
      break;

    default:
      LVOName = "???";
      break;
  }
  ARTL_UnlockAL(ARTL);
}

LPROTO struct AppNode *ARTL_PushLibAN( struct AppList *AL,
  struct PatchMsg *PMsg )
{ 
  /*********************************************************************
   *
   * ARTL_PushLibAN()
   *
   * Append a library AppNode onto the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  if (!PMsg->pmsg_LibBase) return NULL;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {       
    /* OK, we're already tracking this App. We must now determine
       if the library it's attempting to open is already on the
       AppNode's TrackerNode list. If so, update the open count of
       the existing TrackerNode else allocate a fresh TrackerNode. */

    if (TN = ARTL_FindLibTN_ViaLibName(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_LibName))
      TN->tn_OpenCnt += 1;
    else if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList, ADDMODE_APPEND);
    
    /* Correct/update the task/process names. This comes in handy
       if the application changes it's task/process name on the fly. */

    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName);    
  } 
  else if (AN = ARTL_CreateAN_ViaPMsg(PMsg))
  {
    /* At this point we've determined that the App is not being tracked,
       because no AppNode exists for it. So we create one, using the
       information found in the PatchMsg. Then link it onto the AppList. */
    
      ARTL_AddANToAL(AN, AL);
  }
  ARTL_UnlockAL(AL);
  return AN;
}

LPROTO void ARTL_PullLibAN( struct AppList *AL, struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PullLibAN()
   *
   * Remove a library AppNode from the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    /* Now that we've found the AppNode associated with this call
       to CloseLibrary(), we must scan the TrackerNode list for
       the library that it's attempting to close. Once we find it,
       we subtract it's open count, when this becomes zero, we can
       unlink and delete it. If the TrackerNode list becomes empty,
       then we can unlink and delete the AppNode also. */

    register struct TrackerNode *TN;

    if (PMsg->pmsg_LibBase)
      TN = ARTL_FindLibTN_ViaLibBase(
            (struct List *) &AN->an_TrackerList, PMsg->pmsg_LibBase);
    else /* Find it by name */
      TN = ARTL_FindLibTN_ViaLibName(
            (struct List *) &AN->an_TrackerList, PMsg->pmsg_LibName);

    if (TN)
    {     
      TN->tn_OpenCnt -= 1;
      
      if (TN->tn_OpenCnt <= 0)
      {
        /* When the TrackerNode's open count becomes zero, we can mark
           it as unused. But only if cfg_TrackResNotInUse is TRUE else
           we delete the TrackerNode altogether. */

        if (cfg_TrackUnusedResources)
        {
          TN->tn_InUse = FALSE;

          if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
          {
            /* If this AppNode has freed all of it's resources then
               remove the AppNode. */

            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
        else /* Kill off the TrackerNode */
        {
          ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);

          if (ARTL_CountTL(&AN->an_TrackerList, PMSGID_ALL) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }       
      }
    }
  }
  ARTL_UnlockAL(AL);
}

LPROTO struct AppNode *ARTL_PushDevAN( struct AppList *AL,
  struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PushDevAN()
   *
   * Append a device AppNode onto the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  if (!PMsg->pmsg_DevIOReq) return NULL;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {           
    if (TN = ARTL_FindDevTN_ViaIOReq(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_DevIOReq))
      TN->tn_OpenCnt += 1;
    else if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList, ADDMODE_APPEND);

    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName);    
  } 
  else if (AN = ARTL_CreateAN_ViaPMsg(PMsg))
    ARTL_AddANToAL(AN, AL);
  
  ARTL_UnlockAL(AL);

  return AN;
}

LPROTO void ARTL_PullDevAN( struct AppList *AL, struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PullDevAN()
   *
   * Remove a library AppNode from the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    if (TN = ARTL_FindDevTN_ViaIOReq(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_DevIOReq))
    {     
      TN->tn_OpenCnt -= 1;
      
      if (TN->tn_OpenCnt <= 0)
      {
        if (cfg_TrackUnusedResources)
        {
          TN->tn_InUse = FALSE;

          if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
        else /* Kill off the TrackerNode */
        {
          ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);

          if (ARTL_CountTL(&AN->an_TrackerList, PMSGID_ALL) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }       
      }
    }
  }
  ARTL_UnlockAL(AL);
}

LPROTO struct AppNode *ARTL_PushFontAN( struct AppList *AL,
  struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PushFontAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  if (!PMsg->pmsg_FontTextFont) return NULL;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {       
    register struct TrackerNode *TN;

    if (TN = ARTL_FindFontTN_ViaTextFont(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_FontTextFont))
      TN->tn_OpenCnt += 1;
    else if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList, ADDMODE_APPEND);

    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName);    
  } 
  else if (AN = ARTL_CreateAN_ViaPMsg(PMsg))
    ARTL_AddANToAL(AN, AL);

  ARTL_UnlockAL(AL);
  return AN;
}

LPROTO void ARTL_PullFontAN( struct AppList *AL, struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PullFontAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  /* We're not interested in OpenFont()/OpenDiskFont() failures. */

  if (!PMsg->pmsg_FontTextFont) return;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    if (TN = ARTL_FindFontTN_ViaTextFont(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_FontTextFont))
    {     
      TN->tn_OpenCnt -= 1;      

      if (TN->tn_OpenCnt <= 0)
      {
        if (cfg_TrackUnusedResources)
        {
          TN->tn_InUse = FALSE;

          if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
        else /* Kill off the TrackerNode */
        {
          ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);

          if (ARTL_CountTL(&AN->an_TrackerList, PMSGID_ALL) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }       
      }
    }
  } 
  ARTL_UnlockAL(AL);
}

LPROTO struct AppNode *ARTL_PushLockAN( struct AppList *AL,
  struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PushLockAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  if (!PMsg->pmsg_Lock) return NULL;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    /*if (TN = ARTL_FindLockTN_ViaLock((struct List *) &AN->an_TrackerList,
              PMsg->pmsg_Lock))
      TN->tn_OpenCnt += 1;
    else*/
    
    if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList, ADDMODE_APPEND);

    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName);
  } 
  else if (AN = ARTL_CreateAN_ViaPMsg(PMsg))
    ARTL_AddANToAL(AN, AL);

  ARTL_UnlockAL(AL);
  return AN;
}

LPROTO void ARTL_PullLockAN( struct AppList *AL, struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PullLockAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    if (TN = ARTL_FindLockTN_ViaLock(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_Lock))
    {     
      /*TN->tn_OpenCnt -= 1;  
      if (TN->tn_OpenCnt <= 0)*/

      {
        if (cfg_TrackUnusedResources)
        {
          TN->tn_InUse = FALSE;

          if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
        else /* Kill off the TrackerNode */
        {
          ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);

          if (ARTL_CountTL(&AN->an_TrackerList, PMSGID_ALL) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }       
      }
    }
  }
  ARTL_UnlockAL(AL);
}

LPROTO struct AppNode *ARTL_PushFileHandleAN( struct AppList *AL,
 struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PushFileHandleAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  if (!PMsg->pmsg_FH) return NULL;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {           
    if (PMsg->pmsg_ID == PMSGID_OPENFROMLOCK)
    {
      /* Since OpenFromLock() will reqlinquish the lock, we need to
         locate the TrackerNode that repesents that lock and kill
         it. We also determine what pmsg_FHMode is here too. */
      
      if (TN = ARTL_FindLockTN_ViaLock(
            (struct List *) &AN->an_TrackerList, PMsg->pmsg_Lock))
      {
        if (TN->tn_LockMode == SHARED_LOCK)
          PMsg->pmsg_FHMode = MODE_OLDFILE;
        else if (TN->tn_LockMode == EXCLUSIVE_LOCK)
          PMsg->pmsg_FHMode = MODE_NEWFILE;

        if (TN->tn_CurDirName && !PMsg->pmsg_CurDirName)
        {
          if (!(PMsg->pmsg_CurDirName =
                   PATCH_StrToVec(PMsg->pmsg_CurDirName)))
          {
            /* Note: Quick & dirty exit */ ARTL_UnlockAL(AL); return NULL;
          }
        }     
        ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);
      }
    }

    /*if (TN = ARTL_FindFileHandleTN_ViaFH(
      (struct List *) &AN->an_TrackerList, PMsg->pmsg_FH))
      TN->tn_OpenCnt += 1;
    else*/ if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList, ADDMODE_APPEND);

    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName);    
  } 
  else if (AN = ARTL_CreateAN_ViaPMsg(PMsg))
    ARTL_AddANToAL(AN, AL);

  ARTL_UnlockAL(AL);

  return AN;
}

LPROTO void ARTL_PullFileHandleAN( struct AppList *AL,
  struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_PullFileHandleAN()
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register struct TrackerNode *TN;

  ARTL_LockAL(AL);

  if (AN = ARTL_FindAN_ViaTaskPtr(AL, PMsg->pmsg_TaskPtr))
  {
    if (TN = ARTL_FindFileHandleTN_ViaFH(
              (struct List *) &AN->an_TrackerList, PMsg->pmsg_FH))
    {     
      /*TN->tn_OpenCnt -= 1;
      
      if (TN->tn_OpenCnt <= 0)*/
      {
        if (cfg_TrackUnusedResources)
        {
          TN->tn_InUse = FALSE;

          if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
        else /* Kill off the TrackerNode */
        {
          ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);

          if (ARTL_CountTL(&AN->an_TrackerList, PMSGID_ALL) == 0)
          {
            ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
          }
        }
      }
    }
  } 
  ARTL_UnlockAL(AL);
}

/**** AppNode **************************************************************/

LPROTO struct AppList *ARTL_AllocAL( void )
{
  /*********************************************************************
   *
   * ARTL_AllocAL()
   *
   * Allocate an initialize an AppList structure.
   *
   *********************************************************************
   *
   */

  register struct AppList *AL;
  
  if (AL = MEM_AllocVec(AppList_SIZE))
  {
    NewList((struct List *) &AL->al_List);    
    InitSemaphore((struct SignalSemaphore *) &AL->al_Key);
  } 
  return AL;
}

LPROTO void ARTL_FreeAL( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_FreeAL()
   *
   * Free an AppList structure and it's associated allocations. Only
   * pass pointers created with ARTL_AllocAL().
   *
   *********************************************************************
   *
   */

  if (AL)
  { 
    ARTL_FlushAL(AL); MEM_FreeVec(AL);
  }
}

LPROTO void ARTL_LockAL( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_LockAL()
   *
   * Gain exclusive access to an AppList structure and it's AppNodes /
   * TrackerNodes.
   *
   *********************************************************************
   *
   */

  if (!AL) return;

  ObtainSemaphore((struct SignalSemaphore *) &AL->al_Key);
}

LPROTO void ARTL_UnlockAL( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_UnlockAL()
   *
   * Release the exclusive access obtained via ARTL_LockAL(), so other
   * tasks can access the AppList.
   *
   *********************************************************************
   *
   */

  if (!AL) return;

  ReleaseSemaphore((struct SignalSemaphore *) &AL->al_Key);
}

LPROTO void ARTL_FlushAL( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_FlushAL()
   *
   * Free all AppNodes in an AppList, but keep the AppList itself
   * intact and valid.
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN, *TmpAN;

  if (!AL) return;

  ARTL_LockAL(AL);
  
  for (AN = (struct AppNode *) AL->al_List.lh_Head;
       AN->an_Node.ln_Succ;)
  {
    TmpAN = (struct AppNode *) AN->an_Node.ln_Succ;
    ARTL_FreeAN(AN); AN = TmpAN;
  }

  NewList((struct List *) &AL->al_List);  

  ARTL_UnlockAL(AL);
}

LPROTO struct AppNode *ARTL_CreateAN_ViaPMsg( struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_CreateAN_ViaPMsg()
   *
   * Create a fresh AppNode using a PatchMsg.
   * 
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  if (AN = ARTL_AllocAN())
  {
    AN->an_TaskPtr = PMsg->pmsg_TaskPtr;
    AN->an_TaskType = PMsg->pmsg_TaskType;
    AN->an_LaunchType = PMsg->pmsg_LaunchType;
    AN->an_SegList = PMsg->pmsg_SegList;
    ARTL_SetANTaskName(AN, PMsg->pmsg_TaskName);
    ARTL_SetANCmdName(AN, PMsg->pmsg_CmdName); /* Note: OK to fail */

    if (AN->an_TaskName) /* Check the result of ARTL_SetTNTaskName() */
    {
      register struct TrackerNode *TN;

      if (TN = ARTL_CreateTN_ViaPMsg(PMsg))
      {
        ARTL_AddTNToTL(TN, (struct List *) &AN->an_TrackerList,
          ADDMODE_APPEND);
      }
      else
      {
        ARTL_FreeAN(AN); AN = NULL;
      }
    }
    else
    {
      ARTL_FreeAN(AN); AN = NULL;
    }
  }
  return AN;
}

LPROTO BOOL ARTL_AddANToAL( struct AppNode *InsAN, struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_AddANToAL()
   *
   * Append an AppNode to an AppList.
   *
   *********************************************************************
   *
   */

  if (!InsAN || !AL) return FALSE;
  ARTL_LockAL(AL);
  AddTail((struct List *) &AL->al_List, (struct Node *) InsAN);
  ARTL_UnlockAL(AL);
  return TRUE;
}

LPROTO struct AppNode *ARTL_AllocAN( void )
{
  /*********************************************************************
   *
   * ARTL_AllocAN()
   *
   * Allocate an initialize an AppNode.
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  if (AN = MEM_AllocVec(AppNode_SIZE))
  {
    AN->an_Status = AN_STATUS_ALIVE;
    NewList((struct List *) &AN->an_TrackerList);
    DateStamp((struct DateStamp *) &AN->an_TrackDate);
  }
  return AN;  
}

LPROTO void ARTL_FreeAN( struct AppNode *AN )
{
  /*********************************************************************
   *
   * ARTL_FreeAN()
   *
   * Free an AppNode and it's associated resources. Only pass pointers
   * created with ARTL_AllocAN() or ARTL_CloneAN().
   *
   *********************************************************************
   *
   */

  if (AN)
  {
    ARTL_FreeTL((struct List *) &AN->an_TrackerList);

    if (AN->an_CmdName) MEM_FreeVec(AN->an_CmdName);
    if (AN->an_TaskName) MEM_FreeVec(AN->an_TaskName);

    MEM_FreeVec(AN);
  }
}

LPROTO struct AppNode *ARTL_CloneAN( struct AppNode *AN )
{
  /*********************************************************************
   *
   * ARTL_CloneAN()
   *
   * Clone an AppNode structure and it's entire TrackerNode list.
   *
   *********************************************************************
   *
   */

  register struct AppNode *NewAN;
  
  if (NewAN = MEM_AllocVec(AppNode_SIZE))
  {
    NewAN->an_Status = AN->an_Status;
    NewAN->an_TaskPtr = AN->an_TaskPtr;
    ARTL_SetANTaskName(NewAN, AN->an_TaskName);
    ARTL_SetANCmdName(NewAN, AN->an_CmdName); /* Note: OK to fail */
    NewAN->an_TrackDate.ds_Minute = AN->an_TrackDate.ds_Minute;
    NewAN->an_TrackDate.ds_Days = AN->an_TrackDate.ds_Days;
    NewAN->an_TrackDate.ds_Tick = AN->an_TrackDate.ds_Tick;
    NewAN->an_TaskType = AN->an_TaskType;
    NewAN->an_LaunchType = AN->an_LaunchType;
    NewAN->an_SegList = AN->an_SegList;

    /* Note: AN->an_CmdName may be NULL for tasks. */

    if (NewAN->an_TaskName) /* Check result of ARTL_SetTNTaskName() */
    {
      /* Here we clone the entire TrackerList */

      register struct TrackerNode *TN;
      
      NewList((struct List *) &NewAN->an_TrackerList);

      for (TN = (struct TrackerNode *) AN->an_TrackerList.lh_Head;
           TN->tn_Node.ln_Succ ;
           TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
      {
        register struct TrackerNode *NewTN;

        if (NewTN = ARTL_CloneTN(TN))
        {
          ARTL_AddTNToTL(NewTN, (struct List *) &NewAN->an_TrackerList,
            ADDMODE_ALPHABETICALLY);
        }
        else
        {
          /* We've failed to construct the linked list. Abort the loop.
             ARTL_FreeAN() will clean up the mess for us. */

          ARTL_FreeAN(NewAN); NewAN = NULL; break;
        }
      } /* for(;;) */
    }
    else
    {     
      ARTL_FreeAN(NewAN); NewAN = NULL;
    }
  }
  return NewAN;
}

LPROTO struct AppNode *ARTL_FindAN_ViaTaskPtr( struct AppList *AL,
  struct Task *TaskPtrToFnd )
{   
  /*********************************************************************
   *
   * ARTL_FindAN_ViaTaskPtr()
   *
   * Find an AppNode in an AppList, using the TaskPtr field.
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  ARTL_LockAL(AL);
  for (AN = (struct AppNode *) AL->al_List.lh_Head;
       AN->an_Node.ln_Succ;
       AN = (struct AppNode *) AN->an_Node.ln_Succ)
  {
    if (TaskPtrToFnd == AN->an_TaskPtr)
    {
      ARTL_UnlockAL(AL); return AN;
    }
  }
  ARTL_UnlockAL(AL);

  return NULL;
}

LPROTO void ARTL_UnlinkAN( struct AppNode *AN )
{
  /*********************************************************************
   *
   * ARTL_UnlinkAN()
   *
   * Unlink an AppNode from an AppList. Usually this is called before
   * deallocation of the AppNode itself.
   * 
   *********************************************************************
   *
   */

  if ((AN->an_Node.ln_Succ == NULL) || (AN->an_Node.ln_Pred == NULL))
    return;
  Remove((struct Node *) AN);
  AN->an_Node.ln_Succ = NULL;
  AN->an_Node.ln_Pred = NULL;
}

LPROTO UWORD ARTL_UpdateANStatus( struct AppNode *AN )
{
  /*********************************************************************
   *
   * ARTL_UpdateANStatus()
   *
   * Update the status field (an_Status) of an AppNode structure. The
   * contents of an_Status is returned by this routine also.
   * 
   * Notes
   * -----
   *
   * This routine will give incorrect results if the task/process
   * modifies it's own name (i.e. Task->tc_Node.ln_Name) after
   * SysTracker created an AppNode for that task/process. This would
   * cause SysTracker to report the program as dead when in fact it's
   * really alive.
   *  
   * Notes on CLI & Shells
   * ---------------------
   *
   * Checking for the existances of a TaskPtr is fine for programs
   * launched from WB, but it doesn't really work for programs started
   * from CLI/Shell since they share the same TaskPtr as the CLI/Shell
   * process itself. I've added a work around that will check the
   * Process->pr_CLI->cli_Module to see if the command is still loaded.
   *
   *
   *********************************************************************
   *
   */

  register struct Process *ProcessPtr;

  Forbid();

  if (cfg_BeSystemLegal)
  {
    ProcessPtr = (struct Process *) FindTask(AN->an_TaskName);
  }
  else
  {
    if (R_IsTaskPtrValid(AN->an_TaskPtr))
    {
      ProcessPtr = (struct Process *) AN->an_TaskPtr;
    }
    else
    {
      ProcessPtr = NULL;
    }
  }

  if (ProcessPtr)
  {
    AN->an_Status = AN_STATUS_ALIVE;

    /* If it's CLI based, we must do a few more checks... */

    if (AN->an_LaunchType == LT_CLI)
    {   
      if (ProcessPtr &&
          (ProcessPtr->pr_Task.tc_Node.ln_Type == NT_PROCESS))
      {   
        register struct CommandLineInterface *CLI = NULL;

        AN->an_Status = AN_STATUS_ALIVE; /* Default */
        CLI = BADDR(ProcessPtr->pr_CLI);    
        if (AN->an_CmdName && CLI)
        {
          if (CLI->cli_Module)
          {
            /* Command is still loaded into CLI. */
        
            AN->an_Status = AN_STATUS_ALIVE;
          }
          else
          {
            /* Command has been unloaded from CLI (or it's detached
               itself from the CLI). */
        
            AN->an_Status = AN_STATUS_DEAD;
          }
        }
      }
    }
  }
  else
  {
    /* OK, we can't find the task. This means it's been removed
       or the task has changed it's tc_Node.ln_Name field. Either
       way, SysTracker considers it dead. */
    
    AN->an_Status = AN_STATUS_DEAD;
  }

  Permit();

  return AN->an_Status;
}

LPROTO UBYTE *ARTL_SetANTaskName( struct AppNode *AN, UBYTE *TaskName )
{
  /*********************************************************************
   *
   * ARTL_SetANTaskName()
   *
   * Set the AppNode->an_TaskName field of an AppNode structure.
   *
   *********************************************************************
   *
   */

  register UBYTE *FinalTaskName = NULL;

  if (!AN) return FALSE;
  
  if (AN->an_TaskName)
  {
    MEM_FreeVec(AN->an_TaskName); AN->an_TaskName = NULL;
  }

  if (!TaskName)
    FinalTaskName = MEM_StrToVec(STR_Get(SID_UNNAMED_BRACKET));
  else if (!TaskName[0])
    FinalTaskName = MEM_StrToVec(STR_Get(SID_EMPTY_NAME_BRACKET));
  else
    FinalTaskName = MEM_StrToVec(TaskName);
  
  AN->an_TaskName = FinalTaskName;
  return FinalTaskName;
}

LPROTO UBYTE *ARTL_SetANCmdName( struct AppNode *AN, UBYTE *CmdName )
{
  /*********************************************************************
   *
   * ARTL_SetANCmdName()
   * 
   * Set the AN->an_CmdName field of an AppNode structure.
   *
   *********************************************************************
   *
   */

  register UBYTE *FinalCmdName = NULL;

  if (!AN) return FALSE;
  
  if (AN->an_CmdName)
  {
    MEM_FreeVec(AN->an_CmdName); AN->an_CmdName = NULL;
  }

  /* If we can't get a decent process name, then leave the pointer
     NULL. This means the task name will be displayed/used instead. */
  
  if (!CmdName) FinalCmdName = NULL;
  else if (!CmdName[0]) FinalCmdName = NULL;
  else FinalCmdName = MEM_StrToVec(CmdName);
  
  AN->an_CmdName = FinalCmdName;

  return FinalCmdName;
}

LPROTO void ARTL_UpdateAL( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_UpdateAL()
   *
   * Refresh the Application GUI lister to reflect the current state
   * of the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  GUI_Act_List_Clear(OID_MAIN_APPLIST);
  GUI_Act_List_Clear(OID_MAIN_TRACKERLIST);

  GUI_Set_List_Quiet(OID_MAIN_APPLIST, TRUE);
  ARTL_LockAL(AL);

  for (AN = (struct AppNode *) AL->al_List.lh_Head;
       AN->an_Node.ln_Succ;
       AN = (struct AppNode *) AN->an_Node.ln_Succ)
  {
    ARTL_UpdateANStatus(AN);

    if (cfg_ShowUnusedResources)
      GUI_Act_List_InsertABC(OID_MAIN_APPLIST, AN);
    else
      GUI_Act_List_InsertABC(OID_MAIN_APPLIST, AN);
  }
  ARTL_UnlockAL(AL);
  GUI_Set_List_Quiet(OID_MAIN_APPLIST, FALSE);
}

LPROTO BOOL ARTL_SaveALAsASCII( struct AppList *AL, UBYTE *DestFile,
  BOOL SaveAll )
{
  /*********************************************************************
   *
   * ARTL_SaveALAsASCII()
   *
   * Create and save a readable ASCII file of the main AppList (ARTL).
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;
  register BPTR OutFH;
  
  OutFH = Open(DestFile, MODE_NEWFILE);

  /* Take advantage of SetVBuf() if we're running under DOS v40.

     Note: v39 of DOS doesn't have the SetVBuf() code enabled so
           there's no point in checking for v39 too. */

  if (OutFH && (DOSBase->dl_lib.lib_Version >= 40))
  {
    if (SetVBuf(OutFH, NULL, BUF_FULL, IO_BUFFER_SIZE) != 0)
    {
      Close(OutFH); OutFH = 0;
    }   
  }

  if (OutFH)
  {
    struct DateStamp DS;
    UBYTE DateStrBuf[130];
    DateStamp((struct DateStamp *) &DS);
    
    if (R_DateStampToStr((struct DateStamp *) &DS,
          (UBYTE *) &DateStrBuf ))
    {
      register UBYTE *LineBuf = MEM_AllocVec(TEMP_BUFFER_SIZE);

      if (LineBuf)
      {
        FPrintf(OutFH, STR_Get(SID_GENERATED_WITH), VERS, &DateStrBuf);

        ARTL_LockAL(AL);

        for (AN = (struct AppNode *) AL->al_List.lh_Head;
             AN->an_Node.ln_Succ;
             AN = (struct AppNode *) AN->an_Node.ln_Succ)
        {         
          if (AN->an_Status == AN_STATUS_ALIVE)
          {         
            /* Note: When an AppNode is cloned, the TrackerNodes
                     are sorted alphabetically. */

            struct AppNode *ANClone = ARTL_CloneAN(AN);

            if (ANClone)
            {
              register ULONG LineLen = 0;
              register UBYTE *LinePtr = NULL;

              sprintf(LineBuf, STR_Get(SID_IS_USING),
                AN->an_CmdName ? AN->an_CmdName : AN->an_TaskName);
              FPrintf(OutFH, LineBuf);
              LinePtr = LineBuf; LineLen = strlen(LineBuf) - 1;
              while (LineLen--) *LinePtr++ = '=';
              *LinePtr++ = '\n'; *LinePtr = 0;
              FPrintf(OutFH, LineBuf);

              /***********************************************************/

              ARTL_SaveAL_Libs(ANClone, OutFH, SaveAll);
              ARTL_SaveAL_Devs(ANClone, OutFH, SaveAll);
              ARTL_SaveAL_Fonts(ANClone, OutFH, SaveAll);
              ARTL_SaveAL_Locks(ANClone, OutFH, SaveAll);
              ARTL_SaveAL_FHs(ANClone, OutFH, SaveAll);

              /***********************************************************/

              FPrintf(OutFH, "\n");

              ARTL_FreeAN(ANClone); ANClone = NULL;
            }
          }
        } /* for(;;) */
        FPrintf(OutFH,
"*** SysTracker is Copyright © " YEAR " Andrew Bell. All rights reserved. ***\n"
"\n");

        ARTL_UnlockAL(AL);
        MEM_FreeVec(LineBuf);
      }
    }
    Close(OutFH);
  }
  return TRUE;
}

LPROTO BOOL ARTL_SaveAL_Libs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll )
{
  register struct TrackerNode *TN;
  register ULONG AmtSaved = 0;
  register LONG HeaderPOF;
  
  HeaderPOF = Seek(OutFH, 0, OFFSET_CURRENT);
  if (HeaderPOF == -1) return FALSE;
  
  FPrintf(OutFH, "\n"
                 "    Libraries\n"
                 "    =========\n");                 
  for (TN = (struct TrackerNode *) ANClone->an_TrackerList.lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (SaveAll || (!SaveAll && TN->tn_InUse))
    {
      if (TN->tn_ID == PMSGID_OPENLIBRARY)
      {
        FPrintf(OutFH, "    `%s'\n",
         (!TN->tn_LibName || !strlen(TN->tn_LibName)) ?
          "(unnamed library)" : TN->tn_LibName);
        AmtSaved++;
      }
    }
  }

  if (AmtSaved == 0)
    if (Seek(OutFH, HeaderPOF, OFFSET_BEGINNING) == -1)
      return FALSE;

  return TRUE;
}

LPROTO BOOL ARTL_SaveAL_Devs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll )
{
  register struct TrackerNode *TN;
  register ULONG AmtSaved = 0;
  register LONG HeaderPOF;
  
  HeaderPOF = Seek(OutFH, 0, OFFSET_CURRENT);
  if (HeaderPOF == -1) return FALSE;

  FPrintf(OutFH, "\n"
                 "    Devices\n"
                 "    =======\n");

  for (TN = (struct TrackerNode *) ANClone->an_TrackerList.lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (SaveAll || (!SaveAll && TN->tn_InUse))
    {
      if (TN->tn_ID == PMSGID_OPENDEVICE)
      {
        FPrintf(OutFH, "    `%s'\n",
          (!TN->tn_DevName || !strlen(TN->tn_DevName)) ?
          "(unnamed device)" : TN->tn_DevName);

        AmtSaved++;
      }
    }
  }

  if (AmtSaved == 0)
    if (Seek(OutFH, HeaderPOF, OFFSET_BEGINNING) == -1)
      return FALSE;

  return TRUE;
}

LPROTO BOOL ARTL_SaveAL_Fonts( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll )
{
  register struct TrackerNode *TN;
  register ULONG AmtSaved = 0;
  register LONG HeaderPOF;
  
  HeaderPOF = Seek(OutFH, 0, OFFSET_CURRENT);
  if (HeaderPOF == -1) return FALSE;

  FPrintf(OutFH, "\n"
                 "    Fonts\n"
                 "    =====\n");
  for (TN = (struct TrackerNode *) ANClone->an_TrackerList.lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (SaveAll || (!SaveAll && TN->tn_InUse))
    {
      if (TN->tn_ID == PMSGID_OPENFONT)
      {
        FPrintf(OutFH, "    `%s'\n",
           (!TN->tn_FontName || !strlen(TN->tn_FontName)) ?
              "(unnamed font)" : TN->tn_FontName);

        AmtSaved++;
      }
    }
  }

  if (AmtSaved == 0)
    if (Seek(OutFH, HeaderPOF, OFFSET_BEGINNING) == -1)
      return FALSE;

  return TRUE;
}

LPROTO BOOL ARTL_SaveAL_Locks( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll )
{
  register struct TrackerNode *TN;
  register ULONG AmtSaved = 0;
  register LONG HeaderPOF;
  
  HeaderPOF = Seek(OutFH, 0, OFFSET_CURRENT);
  if (HeaderPOF == -1) return FALSE;

  FPrintf(OutFH, "\n"
                 "    Locks\n"
                 "    =====\n");

  for (TN = (struct TrackerNode *) ANClone->an_TrackerList.lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (TN->tn_ID == PMSGID_LOCK)
    {
      if (SaveAll || (!SaveAll && TN->tn_InUse))
      {
        FPrintf(OutFH, "    `%s'\n",
          (!TN->tn_LockName || !strlen(TN->tn_LockName)) ?
           "(unnamed lock)" : TN->tn_LockName);

        AmtSaved++;
      }
    }
  }

  if (AmtSaved == 0)
    if (Seek(OutFH, HeaderPOF, OFFSET_BEGINNING) == -1)
      return FALSE;

  return TRUE;
}

LPROTO BOOL ARTL_SaveAL_FHs( struct AppNode *ANClone, BPTR OutFH,
  BOOL SaveAll )
{
  register struct TrackerNode *TN;
  register ULONG AmtSaved = 0;
  register LONG HeaderPOF;
  
  HeaderPOF = Seek(OutFH, 0, OFFSET_CURRENT);
  if (HeaderPOF == -1) return FALSE;

  FPrintf(OutFH, "\n"
                 "    Files accessed\n"
                 "    ==============\n");

  for (TN = (struct TrackerNode *) ANClone->an_TrackerList.lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (SaveAll || (!SaveAll && TN->tn_InUse))
    {
      if ((TN->tn_ID == PMSGID_OPEN) ||
          (TN->tn_ID == PMSGID_OPENFROMLOCK))
      {
        FPrintf(OutFH, "    `%s'\n",
          (!TN->tn_FHName || !strlen(TN->tn_FHName)) ?
          "(unnamed file)" : TN->tn_FHName);

        AmtSaved++;
      }
    }
  }

  if (AmtSaved == 0)
    if (Seek(OutFH, HeaderPOF, OFFSET_BEGINNING) == -1)
      return FALSE;

  return TRUE;
}

LPROTO LONG ARTL_GetANListIndex_ViaTaskPtr( struct Task *TaskPtr )
{
  /*********************************************************************
   *
   * ARTL_GetANListIndex_ViaTaskPtr()
   * 
   * Find an AppNode in the main GUI lister via a TaskPtr. Remember
   * that the GUI list uses cloned AppNodes!
   *
   *********************************************************************
   *
   */

  register LONG Index = 0;

  for (Index = 0 ;; Index++)
  {
    struct AppNode *AN = GUI_Get_List_Entry(OID_MAIN_APPLIST, Index);
    if (!AN) break;
    if (TaskPtr == AN->an_TaskPtr) return Index;
  }
  return -1;
}

GPROTO LONG ARTL_ClearDeadANs( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_ClearDeadANs()
   * 
   * Delete those AppNodes in an AppList that no longer have a task
   * associated with it.
   *
   *********************************************************************
   *
   */

  register LONG DeadANCnt = 0;
  register struct AppNode *AN, *NextAN;

  ARTL_LockAL(AL);

  for (AN = (struct AppNode *) AL->al_List.lh_Head;
       AN->an_Node.ln_Succ;)
  {
    NextAN = (struct AppNode *) AN->an_Node.ln_Succ;

    if (ARTL_UpdateANStatus(AN) == AN_STATUS_DEAD)
    {
      ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
      DeadANCnt++;
    }
    
    AN = NextAN;
  }
  ARTL_UnlockAL(AL);
  ARTL_UpdateAL(AL);
  
  return DeadANCnt;
}

GPROTO ULONG ARTL_ClearUnusedANs( struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_ClearUnusedANs()
   *
   * Clear all AppNodes that don't have any allocated resources.
   *
   *********************************************************************
   *
   */

  register LONG FreedANCnt = 0;
  register struct AppNode *AN, *NextAN;

  ARTL_LockAL(AL);

  for (AN = (struct AppNode *) AL->al_List.lh_Head;
       AN->an_Node.ln_Succ;)
  {
    NextAN = (struct AppNode *) AN->an_Node.ln_Succ;

    ARTL_ClearUnusedTNs(&AN->an_TrackerList);

    if (ARTL_CountTNsInUse(&AN->an_TrackerList) == 0)
    {
      ARTL_UnlinkAN(AN); ARTL_FreeAN(AN);
      FreedANCnt++;
    }   
    AN = NextAN;
  }
  ARTL_UnlockAL(AL);
  ARTL_UpdateAL(AL);
  
  return FreedANCnt;
}

/**** TrackerNode **********************************************************/

LPROTO struct TrackerNode *ARTL_CreateTN_ViaPMsg( struct PatchMsg *PMsg )
{
  /*********************************************************************
   *
   * ARTL_CreateTN_ViaPMsg()
   *
   * Create a TrackerNode using a PatchMsg.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  register BOOL Success = FALSE;

  if (TN = ARTL_AllocTN())
  {
    UBYTE TmpBuf[256];

    TN->tn_OpenCnt = 1; /* The creation of this TN implies that something
                           has opened it. */
    TN->tn_InUse = TRUE; /* It also implies that something is using it. */

    switch(PMsg->pmsg_ID)
    {
      case PMSGID_OPENLIBRARY:
        TN->tn_ID = PMSGID_OPENLIBRARY;
        TN->tn_LibName = MEM_StrToVec(PMsg->pmsg_LibName);
        TN->tn_LibVer = PMsg->pmsg_LibVer;
        TN->tn_LibBase = PMsg->pmsg_LibBase;
        if (TN->tn_LibName) Success = TRUE;
        break;

      case PMSGID_OPENDEVICE:
        TN->tn_ID = PMSGID_OPENDEVICE;
        TN->tn_DevName = MEM_StrToVec(PMsg->pmsg_DevName);
        TN->tn_DevUnitNum = PMsg->pmsg_DevUnitNum;
        TN->tn_DevIOReq = PMsg->pmsg_DevIOReq;
        TN->tn_DevFlags = PMsg->pmsg_DevFlags;
        if (TN->tn_DevName) Success = TRUE;
        break;

      case PMSGID_OPENFONT:
        TN->tn_ID = PMSGID_OPENFONT;
        TN->tn_FontTextAttr = PMsg->pmsg_FontTextAttr;
        TN->tn_FontTextFont = PMsg->pmsg_FontTextFont;
        sprintf((UBYTE *)&TmpBuf, "%s/%lu",
          PMsg->pmsg_FontName, (ULONG) PMsg->pmsg_FontYSize);
        TN->tn_FontName = MEM_StrToVec((UBYTE *)&TmpBuf);
        TN->tn_FontYSize = PMsg->pmsg_FontYSize;
        TN->tn_FontStyle = PMsg->pmsg_FontStyle;
        TN->tn_FontFlags = PMsg->pmsg_FontFlags;
        if (TN->tn_FontName) Success = TRUE;
        break;

      case PMSGID_LOCK:
        TN->tn_ID = PMSGID_LOCK;
        TN->tn_Lock = PMsg->pmsg_Lock;
        TN->tn_LockMode = PMsg->pmsg_LockMode;
        TN->tn_LockName = MEM_StrToVec(PMsg->pmsg_LockName);
        if (TN->tn_LockName) Success = TRUE;
        break;

      case PMSGID_OPEN:
        TN->tn_ID = PMSGID_OPEN;
        TN->tn_FH = PMsg->pmsg_FH;
        TN->tn_FHMode = PMsg->pmsg_FHMode;
        TN->tn_FHName = MEM_StrToVec(PMsg->pmsg_FHName);
        if (TN->tn_FHName) Success = TRUE;
        break;

      case PMSGID_OPENFROMLOCK:
        TN->tn_ID = PMSGID_OPENFROMLOCK;
        TN->tn_Lock = PMsg->pmsg_Lock;
        TN->tn_FH = PMsg->pmsg_FH;
        TN->tn_FHName = MEM_StrToVec(PMsg->pmsg_FHName);
        if (TN->tn_FHName) Success = TRUE;
        break;

      default: break;
    }

    if (!Success)
    {     
      ARTL_FreeTN(TN); TN = NULL;
    }
    else
    {
      /* If this is a file related TrackerNode, build the full path. */
      
      if (!ATRL_BuildTNPath(TN))
      {
        ARTL_FreeTN(TN); TN = NULL;
      }
    }
  }
  return TN;
}

LPROTO BOOL ARTL_AddTNToTL(
  struct TrackerNode *InsTN, struct List *TL, ULONG AddMode )
{
  /*********************************************************************
   *
   * ARTL_AddTNToTL()
   *
   * Add a TrackerNode to a TrackerList.
   *
   *********************************************************************
   *
   */

  if (!InsTN || !TL) return FALSE;

  if (AddMode == ADDMODE_ALPHABETICALLY)
  {
    register struct TrackerNode *TN;

    for (TN = (struct TrackerNode *) TL->lh_Head;
         TN->tn_Node.ln_Succ;
         TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
    {
      register LONG r;
      
      if ((TN->tn_ID == PMSGID_OPENLIBRARY) &&
          (InsTN->tn_ID == PMSGID_OPENLIBRARY))
        r = Stricmp(TN->tn_LibName, InsTN->tn_LibName);
      else if ((TN->tn_ID == PMSGID_OPENDEVICE) &&
              (InsTN->tn_ID == PMSGID_OPENDEVICE))
        r = Stricmp(TN->tn_DevName, InsTN->tn_DevName);
      else if ((TN->tn_ID == PMSGID_OPENFONT) &&
              (InsTN->tn_ID == PMSGID_OPENFONT))
        r = Stricmp(TN->tn_FontName, InsTN->tn_FontName);
      else r = -1;

      if (r >= 0)
      {
        Insert((struct List *) &TL,
               (struct Node *) InsTN,
               (struct Node *) TN->tn_Node.ln_Pred);

        return TRUE;
      }
    }
    AddTail(TL, (struct Node *) InsTN); 
  }
  else
    AddTail(TL, (struct Node *) InsTN);

  return TRUE;
}

LPROTO struct TrackerNode *ARTL_AllocTN( void )
{
  /*********************************************************************
   *
   * ARTL_AllocTN()
   *
   * Allocate and initialize a TrackerNode structure.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;

  if (TN = MEM_AllocVec(TrackerNode_SIZE))
  {
    DateStamp((struct DateStamp *) &TN->tn_TrackDate);
  } 
  return TN;
}

LPROTO void ARTL_FreeTN( struct TrackerNode *TN )
{
  /*********************************************************************
   *
   * ARTL_FreeTN()
   *
   * Free a TrackerNode structure and it's associated resources. Only
   * pass pointers from ARTL_AllocTN() or ARTL_CloneTN().
   *
   *********************************************************************
   *
   */

  if (TN)
  {
    if (TN->tn_LibName) MEM_FreeVec(TN->tn_LibName);
    if (TN->tn_DevName) MEM_FreeVec(TN->tn_DevName);
    if (TN->tn_FontName) MEM_FreeVec(TN->tn_FontName);
    if (TN->tn_FHName) MEM_FreeVec(TN->tn_FHName);
    if (TN->tn_LockName) MEM_FreeVec(TN->tn_LockName);
    if (TN->tn_CurDirName) MEM_FreeVec(TN->tn_CurDirName);
    MEM_FreeVec(TN);
  }
}

LPROTO struct TrackerNode *ARTL_CloneTN( struct TrackerNode *TN )
{
  /*********************************************************************
   *
   * ARTL_CloneTN()
   *
   * Clone a TrackerNode and it's associated resources.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *NewTN;
  register BOOL Success = FALSE; /* Assume an error will happen */

  if (NewTN = MEM_AllocVec(TrackerNode_SIZE))
  {
    NewTN->tn_ID = TN->tn_ID;
    NewTN->tn_OpenCnt = TN->tn_OpenCnt;
    NewTN->tn_InUse = TN->tn_InUse;
    NewTN->tn_TrackDate.ds_Minute = TN->tn_TrackDate.ds_Minute;
    NewTN->tn_TrackDate.ds_Days = TN->tn_TrackDate.ds_Days;
    NewTN->tn_TrackDate.ds_Tick = TN->tn_TrackDate.ds_Tick;

    switch(NewTN->tn_ID)
    {
      case PMSGID_OPENLIBRARY:
        NewTN->tn_LibName = MEM_StrToVec(TN->tn_LibName);
        NewTN->tn_LibVer = TN->tn_LibVer;
        NewTN->tn_LibBase = TN->tn_LibBase;
        if (NewTN->tn_LibName) Success = TRUE;
        break;

      case PMSGID_OPENDEVICE:
        NewTN->tn_DevName = MEM_StrToVec(TN->tn_DevName); 
        NewTN->tn_DevUnitNum = TN->tn_DevUnitNum;
        NewTN->tn_DevIOReq = TN->tn_DevIOReq;
        NewTN->tn_DevFlags = TN->tn_DevFlags;
        if (NewTN->tn_DevName) Success = TRUE;
        break;

      case PMSGID_OPENFONT:
        NewTN->tn_ID = TN->tn_ID;
        NewTN->tn_FontTextAttr = TN->tn_FontTextAttr;
        NewTN->tn_FontTextFont = TN->tn_FontTextFont;
        NewTN->tn_FontName = MEM_StrToVec(TN->tn_FontName);
        NewTN->tn_FontYSize = TN->tn_FontYSize;
        NewTN->tn_FontStyle = TN->tn_FontStyle;
        NewTN->tn_FontFlags = TN->tn_FontFlags;
        if (NewTN->tn_FontName) Success = TRUE;
        break;

      case PMSGID_LOCK:
        NewTN->tn_ID = TN->tn_ID;
        NewTN->tn_Lock = TN->tn_Lock;
        NewTN->tn_LockMode = TN->tn_LockMode;
        NewTN->tn_LockName = MEM_StrToVec(TN->tn_LockName);
        if (TN->tn_CurDirName)
          if (!(NewTN->tn_CurDirName = MEM_StrToVec(TN->tn_CurDirName)))
            break;

        if (NewTN->tn_LockName) Success = TRUE;
        break;

      case PMSGID_OPEN:
        NewTN->tn_ID = TN->tn_ID;
        NewTN->tn_FH = TN->tn_FH;
        NewTN->tn_FHMode = TN->tn_FHMode;
        NewTN->tn_FHName = MEM_StrToVec(TN->tn_FHName);
        if (TN->tn_CurDirName)
          if (!(TN->tn_CurDirName = MEM_StrToVec(TN->tn_CurDirName)))
            break;

        if (NewTN->tn_FHName) Success = TRUE;
        break;

      case PMSGID_OPENFROMLOCK:
        NewTN->tn_ID = NewTN->tn_ID;
        NewTN->tn_Lock = TN->tn_Lock;
        NewTN->tn_FH = TN->tn_FH;
        NewTN->tn_FHName = MEM_StrToVec(TN->tn_FHName);
        if (TN->tn_CurDirName)
          if (!(TN->tn_CurDirName = MEM_StrToVec(TN->tn_CurDirName)))
            break;
        if (NewTN->tn_FHName) Success = TRUE;
        break;
    }
  } 
  if (!Success)
  {
    ARTL_FreeTN(NewTN); NewTN = NULL;
  }
  return NewTN;
}

LPROTO BOOL ATRL_BuildTNPath( struct TrackerNode *TN )
{
  /*********************************************************************
   *
   * ATRL_BuildTNPath()
   *
   * The routine makes sure that the Name field of a file related
   * TrackerNode is a full path. This is done by joining the
   * TN->tn_CurDirName and name fields.
   *
   * Normally this routine is called after a TrackerNode has been
   * freshly created.
   *
   *********************************************************************
   *
   */

  #define TMP_BUF_LEN 512

  UBYTE **NamePart = NULL;
  UBYTE TmpPath[TMP_BUF_LEN + 2];

  if (!TN) return FALSE;
  if (!TN->tn_CurDirName) return TRUE;
    
  switch(TN->tn_ID)
  {
    case PMSGID_OPEN:
      NamePart = (UBYTE **) &TN->tn_FHName;   break;
    case PMSGID_OPENFROMLOCK:
      NamePart = (UBYTE **) &TN->tn_FHName;   break;
    case PMSGID_LOCK:
      NamePart = (UBYTE **) &TN->tn_LockName; break;
    default:
      return TRUE;
  }
  
  if (!NamePart || !*NamePart) return FALSE;  
  strcpy((UBYTE *)&TmpPath, TN->tn_CurDirName);

  if (!AddPart((UBYTE *)&TmpPath, FilePart(*NamePart), TMP_BUF_LEN))
    return FALSE;

  MEM_FreeVec(*NamePart);
  *NamePart = MEM_StrToVec((UBYTE *)&TmpPath);

  if (*NamePart) return TRUE; else return FALSE;  
}

/* Note: The following ARTL_Find#? routines will always ignore
         TrackerNodes that are not in use. This is to avoid the
         chance that a clash will happen if two resources ever
         share the same memory space (at different times). For
         example, if task "A" closes a filehandle then task "B"
         opens a new filehandle, it's possible that the new
         filehandle will share the same memory space as the old
         one, even though they are two separate file handles. */

LPROTO struct TrackerNode *ARTL_FindLibTN_ViaLibName( struct List *TL,
  UBYTE *LibName )
{
  /*********************************************************************
   *
   * ARTL_FindLibTN_ViaLibName()
   *
   * Find a TrackerNode in a TrackerList via a library name.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == PMSGID_OPENLIBRARY) &&
        (Stricmp(LibName, TN->tn_LibName) == 0) &&
         TN->tn_InUse)
    {
      return TN;
    }
  }
  return NULL;
}

LPROTO struct TrackerNode *ARTL_FindLibTN_ViaLibBase( struct List *TL,
  struct Library *LibBase )
{
  /*********************************************************************
   *
   * ARTL_FindLibTN_ViaLibBase()
   *
   * Find a TrackerNode in a TrackerList via a library base pointer.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == PMSGID_OPENLIBRARY) &&
        (LibBase == TN->tn_LibBase) &&
        TN->tn_InUse)
    {
      return TN;
    }
  }
  return NULL;
}

LPROTO struct TrackerNode *ARTL_FindDevTN_ViaIOReq( struct List *TL,
  struct IORequest *IOReq )
{
  /*********************************************************************
   *
   * ARTL_FindDevTN_ViaIOReq()
   *
   * Find a TrackerNode in a TrackerList via a device IORequest pointer.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == PMSGID_OPENDEVICE) &&
        (IOReq == TN->tn_DevIOReq) &&
        TN->tn_InUse)
    {
      return TN;
    }
  }
  return NULL;
}

LPROTO struct TrackerNode *ARTL_FindDevTN_ViaDevName( struct List *TL,
  UBYTE *DevName )
{
  /*********************************************************************
   *
   * FindDevTN_Devname()
   *
   * Find a TrackerNode in a TrackerList via Device name.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == PMSGID_OPENDEVICE) &&
        (Stricmp(DevName, TN->tn_DevName) == 0) &&
        TN->tn_InUse)
    {
      return TN;
    }
  }
  return NULL;
}

LPROTO struct TrackerNode *ARTL_FindFontTN_ViaTextFont( struct List *TL,
  struct TextFont *TF )
{
  /*********************************************************************
   *
   * ARTL_FindFontTN_ViaTextFont()
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (TN->tn_ID == PMSGID_OPENFONT)
    {
      if (TF == TN->tn_FontTextFont && TN->tn_InUse) return TN;
    }
  }
  return NULL;  
}

LPROTO struct TrackerNode *ARTL_FindLockTN_ViaLock( struct List *TL,
  BPTR Lk )
{
  /*********************************************************************
   *
   * ARTL_FindLockTN_ViaLock()
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (TN->tn_ID == PMSGID_LOCK)
    {
      if (Lk == TN->tn_Lock && TN->tn_InUse) return TN;
    }
  }
  return NULL;      
}

LPROTO struct TrackerNode *ARTL_FindFileHandleTN_ViaFH( struct List *TL,
  BPTR FH )
{
  /*********************************************************************
   *
   * ARTL_FindFileHandleTN_ViaFH()
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == PMSGID_OPEN) || (TN->tn_ID == PMSGID_OPENFROMLOCK))
    {
      if (FH == TN->tn_FH && TN->tn_InUse) return TN;
    }
  }
  return NULL;      
}

LPROTO void ARTL_UnlinkTN( struct TrackerNode *TN )
{
  /*********************************************************************
   *
   * ARTL_UnlinkTN()
   *
   * Unlink a TrackerNode from a TrackerList.
   *
   *********************************************************************
   *
   */

  if ((TN->tn_Node.ln_Succ == NULL) || (TN->tn_Node.ln_Pred == NULL))
    return;
  Remove((struct Node *)TN);
  TN->tn_Node.ln_Succ = NULL;
  TN->tn_Node.ln_Pred = NULL;
}

LPROTO void ARTL_FreeTL( struct List *TL )
{
  /*********************************************************************
   *
   * ARTL_FreeTL()
   *
   * Free an entire TrackerList.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN, *TmpTN;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ ;)
  {
    TmpTN = (struct TrackerNode *) TN->tn_Node.ln_Succ;
    ARTL_FreeTN(TN); TN = TmpTN;
  }
  NewList(TL);  
}

LPROTO void ARTL_UpdateTL( struct List *TL )
{
  /*********************************************************************
   *
   * ARTL_UpdateTL()
   *
   * Update the GUI tracker lister using a TrackerLister structure.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  register ULONG TrackMode = ARTL_Get_TrackMode();

  GUI_Act_List_Clear(OID_MAIN_TRACKERLIST);
  GUI_Set_List_Quiet(OID_MAIN_TRACKERLIST, TRUE);

  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  { 
    if (cfg_ShowUnusedResources == FALSE && TN->tn_InUse == FALSE)
      continue;

    if (TrackMode == TRACKMODE_LIBRARIES && TN->tn_ID == PMSGID_OPENLIBRARY)
      GUI_Act_List_InsertABC(OID_MAIN_TRACKERLIST, TN);
    else if (TrackMode == TRACKMODE_DEVICES && TN->tn_ID == PMSGID_OPENDEVICE)
      GUI_Act_List_InsertABC(OID_MAIN_TRACKERLIST, TN);
    else if (TrackMode == TRACKMODE_FONTS && (TN->tn_ID == PMSGID_OPENFONT))
      GUI_Act_List_InsertABC(OID_MAIN_TRACKERLIST, TN);
    else if ((TrackMode == TRACKMODE_FILEHANDLES) &&
              (TN->tn_ID == PMSGID_OPEN) || (TN->tn_ID == PMSGID_OPENFROMLOCK))
      GUI_Act_List_InsertABC(OID_MAIN_TRACKERLIST, TN);
    else if (TrackMode == TRACKMODE_LOCKS && TN->tn_ID == PMSGID_LOCK)
      GUI_Act_List_InsertABC(OID_MAIN_TRACKERLIST, TN);
  }
  GUI_Set_List_Quiet(OID_MAIN_TRACKERLIST, FALSE);
}

LPROTO ULONG ARTL_CountTL( struct List *TL, LONG ID )
{
  /*********************************************************************
   *
   * ARTL_CountTL()
   *
   * Count the amount of TrackerNodes in a TrackerList, using a
   * specific AppNode ID. Use PMSGID_ALL to count all nodes.
   *
   * Notes
   * -----
   *
   * You may pass PMSGID_ALL to the ID parameter.
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *TN;
  register ULONG Cnt = 0;
  
  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if ((TN->tn_ID == ID) || (ID == PMSGID_ALL)) Cnt++;
  }
  return Cnt;
}

LPROTO ULONG ARTL_CountTNsInUse( struct List *TL )
{
  /*********************************************************************
   *
   * ARTL_CountTNsInUse()
   *
   * Count the amount of TrackerNodes in a TrackerList that
   * currently have their TrackerNodes->tn_InUse flag set.
   *
   *********************************************************************
   *
   */

  register ULONG Cnt = 0;
  register struct TrackerNode *TN;

  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;
       TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
  {
    if (TN->tn_InUse) Cnt++;
  }
  return Cnt;
}

GPROTO ULONG ARTL_ClearUnusedTNs( struct List *TL )
{
  /*********************************************************************
   *
   * ARTL_ClearUnusedTNs()
   *
   *********************************************************************
   *
   */

  register ULONG FreedTNCnt = 0;
  register struct TrackerNode *TN, *NextTN;

  for (TN = (struct TrackerNode *) TL->lh_Head;
       TN->tn_Node.ln_Succ;)
  {
    NextTN = (struct TrackerNode *) TN->tn_Node.ln_Succ;
    
    if (!TN->tn_InUse)
    {
      ARTL_UnlinkTN(TN); ARTL_FreeTN(TN);
      FreedTNCnt++;
    }   
    TN = NextTN;
  }
  return FreedTNCnt;
}


/**** ATRL misc ************************************************************/

LPROTO void ARTL_FindAppsUsingRes( struct TrackerNode *TNToFnd,
  struct AppList *AL )
{
  /*********************************************************************
   *
   * ARTL_FindAppsUsingRes()
   *
   * This routine will try to locate all AppNodes using a particular
   * resource. This resource is represented by the TrackerNode
   * structure. The details of the resulting AppNodes are inserted into
   * the "APPUSING" lister.
   *
   *********************************************************************
   *
   */

  register struct AppNode *AN;

  ARTL_LockAL(AL);

  for (AN = (struct AppNode *) ARTL->al_List.lh_Head;
       AN->an_Node.ln_Succ;
       AN = (struct AppNode *) AN->an_Node.ln_Succ)
  {
    register struct TrackerNode *TN;

    for (TN = (struct TrackerNode *) AN->an_TrackerList.lh_Head;
         TN->tn_Node.ln_Succ;
         TN = (struct TrackerNode *) TN->tn_Node.ln_Succ)
    {
      if ((TNToFnd->tn_ID == TN->tn_ID) && TN->tn_InUse)
      {
        register LONG CmpResult = -1;

        switch(TN->tn_ID)
        {
          case PMSGID_OPENLIBRARY:
            CmpResult = Stricmp(TNToFnd->tn_LibName, TN->tn_LibName);
            break;
          case PMSGID_OPENDEVICE:
            CmpResult = Stricmp(TNToFnd->tn_DevName, TN->tn_DevName);
            break;
          case PMSGID_OPENFONT:
            CmpResult = Stricmp(TNToFnd->tn_FontName, TN->tn_FontName);
            break;

          case PMSGID_OPENFROMLOCK:
          case PMSGID_OPEN:
          {
            CmpResult = -1; /* Assume they're different */

            if (TNToFnd->tn_FHName && TN->tn_FHName)
            {
              register BPTR Lock1 = 0, Lock2 = 0;
                            
              if ((Lock1 = Lock(TNToFnd->tn_FHName, SHARED_LOCK)) &&
                  (Lock2 = Lock(TN->tn_FHName, SHARED_LOCK)))
              {
                if (SameLock(Lock1, Lock2) == LOCK_SAME) CmpResult = 0;
              }   
              if (Lock1) UnLock(Lock1);
              if (Lock2) UnLock(Lock2);             
            }
            break;
          }

          case PMSGID_LOCK:
          {
            CmpResult = -1; /* Assume they're different */

            if (TNToFnd->tn_LockName && TN->tn_LockName)
            {
              register BPTR Lock1 = 0, Lock2 = 0;
                            
              if ((Lock1 = Lock(TNToFnd->tn_FHName, SHARED_LOCK)) &&
                  (Lock2 = Lock(TN->tn_FHName, SHARED_LOCK)))
              {
                if (SameLock(Lock1, Lock2) == LOCK_SAME) CmpResult = 0;
              }
              if (Lock1) UnLock(Lock1);
              if (Lock2) UnLock(Lock2);             
            }
            break;
          }
        }
          
        if (CmpResult == 0)
        {
          register UBYTE *AppName = AN->an_CmdName;
          if (!AppName) AppName = AN->an_TaskName;
          GUI_Act_List_InsertABC(OID_APPUSING_LISTVIEW, FilePart(AppName));
        }
      }
    } /* for(;;) */
  } /* for(;;) */
  ARTL_UnlockAL(AL);
}

LPROTO ULONG ARTL_CountList( struct List *L )
{
  /*********************************************************************
   *
   * ARTL_CountList()
   *
   * A generic list node count function. Suitable for all exec style
   * linked lists.
   *
   *********************************************************************
   *
   */

  register struct Node *N;
  register ULONG Cnt = 0;

  for (N = L->lh_Head; N->ln_Succ; N = N->ln_Succ)
    Cnt++;
  return Cnt;
}

/***************************************************************************/
/* Hooks for the left lister (aka AppLister) */
/***************************************************************************/

GPROTO void ARTL_AppListKillFunc( register __a2 APTR Pool,
  register __a1 struct AppNode *AN )
{
  ARTL_FreeAN(AN);
}

GPROTO struct AppNode *ARTL_AppListMakeFunc( register __a2 APTR Pool,
  register __a1 struct AppNode *AN )
{
  return ARTL_CloneAN(AN); /* Clone the AppNode */
}

GPROTO LONG ARTL_AppListShowFunc( register __a2 UBYTE **ColumnArray,
  register __a1 struct AppNode *AN )
{ 
  if (AN)
  {
    ColumnArray[0] = AN->an_TaskName;

    if (AN->an_CmdName) ColumnArray[0] = AN->an_CmdName;

    if (ColumnArray[0][0] == 0)
      ColumnArray[0] = "(Internal Error: Hook got empty string)";
    else if (cfg_RemovePaths)
      ColumnArray[0] = FilePart(ColumnArray[0]);

    switch(AN->an_TaskType)
    {
      case NT_TASK:    ColumnArray[1] = STR_Get(SID_TASK);    break;
      case NT_PROCESS: ColumnArray[1] = STR_Get(SID_PROCESS); break;
      default:         ColumnArray[1] = STR_Get(SID_UNKNOWN); break;
    }

    switch(AN->an_Status)
    {
      default:
      case AN_STATUS_UNKNOWN: ColumnArray[2] = STR_Get(SID_UNKNOWN); break;
      case AN_STATUS_ALIVE:   ColumnArray[2] = STR_Get(SID_ALIVE);   break;
      case AN_STATUS_DEAD:    ColumnArray[2] = STR_Get(SID_DEAD);    break;
    }
  }
  else
  {
    ColumnArray[0] = STR_Get(SID_APPNAME);
    ColumnArray[1] = STR_Get(SID_TYPE);
    ColumnArray[2] = STR_Get(SID_STATUS);
  }
  return 0;
}

GPROTO LONG ARTL_AppListSortFunc( register __a1 struct AppNode *AN1,
  register __a2 struct AppNode *AN2 )
{
  return Stricmp(AN1->an_TaskName, AN2->an_TaskName);
}

struct Hook ARTL_AppListMakeHook =
  { { NULL, NULL }, (void *) ARTL_AppListMakeFunc, NULL, NULL };
struct Hook ARTL_AppListKillHook =
  { { NULL, NULL }, (void *) ARTL_AppListKillFunc, NULL, NULL };
struct Hook ARTL_AppListShowHook =
  { { NULL, NULL }, (void *) ARTL_AppListShowFunc, NULL, NULL };
struct Hook ARTL_AppListSortHook =
  { { NULL, NULL }, (void *) ARTL_AppListSortFunc, NULL, NULL };

/***************************************************************************/
/* Hooks for the right lister (aka TrackerLister) */
/***************************************************************************/

GPROTO void ARTL_TrackerListKillFunc( register __a2 APTR Pool,
  register __a1 struct TrackerNode *TN )
{
  ARTL_FreeTN(TN); /* Free the clone allocated by the make hook. */
}

GPROTO struct TrackerNode *ARTL_TrackerListMakeFunc(
  register __a2 APTR Pool,
  register __a1 struct TrackerNode *TN )
{
  /* We must clone the tracker node so the ARTL-Handler doesn't
     rip the memory from under MUI. */
  
  return ARTL_CloneTN(TN);
}

GPROTO LONG ARTL_TrackerListShowFunc( register __a2 UBYTE **ColumnArray,
  register __a1 struct TrackerNode *TN )
{
  if (TN)
  {
    sprintf((UBYTE *) &TN->tn_OpenCntTxt, "%ld", TN->tn_OpenCnt);
    ColumnArray[1] = (UBYTE *) &TN->tn_OpenCntTxt;

    switch(TN->tn_ID)
    {
      case PMSGID_OPENLIBRARY:
        ColumnArray[0] = TN->tn_LibName;
        break;
      case PMSGID_OPENDEVICE:
        sprintf((UBYTE *)&TN->tn_DevUnitNumTxt, "%ld", TN->tn_DevUnitNum);
        ColumnArray[0] = TN->tn_DevName;
        ColumnArray[1] = (UBYTE *) &TN->tn_DevUnitNumTxt;
        break;
      case PMSGID_OPENFONT:
        ColumnArray[0] = TN->tn_FontName;
        break;

      case PMSGID_OPENFROMLOCK:
      case PMSGID_OPEN:
      {
        if (!TN->tn_FHName || strlen(TN->tn_FHName) == 0)
          ColumnArray[0] = "(no name)";
        else
          ColumnArray[0] = TN->tn_FHName;

        switch(TN->tn_FHMode)
        {
          case MODE_OLDFILE:   ColumnArray[1] = "Read";       break;
          case MODE_NEWFILE:   ColumnArray[1] = "Write";      break;
          case MODE_READWRITE: ColumnArray[1] = "Read/Write"; break;
          default:             ColumnArray[1] = "Unknown";    break;
        }       
        break;
      }

      case PMSGID_LOCK:
      {
        if (!TN->tn_LockName || strlen(TN->tn_LockName) == 0)
          ColumnArray[0] = "(no name)";
        else
          ColumnArray[0] = TN->tn_LockName;

        switch(TN->tn_LockMode)
        {
          case SHARED_LOCK:    ColumnArray[1] = "Shared";    break;
          case EXCLUSIVE_LOCK: ColumnArray[1] = "Exclusive"; break;
          default:             ColumnArray[1] = "Unknown";   break;
        }       
        break;
      }

      default:
        ColumnArray[0] = "Internal Error: Unknown Trackernode ID!";
        break;
    }

    if (TN->tn_InUse) ColumnArray[2] = "Yes";
    else ColumnArray[2] = "No";
  }
  else  /* Print lister title */
  {       
    switch(ARTL_Get_TrackMode())
    {
      case TRACKMODE_LIBRARIES:
        ColumnArray[0] = STR_Get(SID_LISTTITLE_LIBRARIES);
        ColumnArray[1] = STR_Get(SID_LISTTITLE_OPENCOUNT);
        ColumnArray[2] = "\33bIn use?";
        break;
      case TRACKMODE_DEVICES:
        ColumnArray[0] = STR_Get(SID_LISTTITLE_DEVICES);
        ColumnArray[1] = "\33bUnit Num";
        ColumnArray[2] = "\33bIn use?";
        break;
      case TRACKMODE_FONTS:
        ColumnArray[0] = STR_Get(SID_LISTTITLE_FONTS);
        ColumnArray[1] = STR_Get(SID_LISTTITLE_OPENCOUNT);
        ColumnArray[2] = "\33bIn use?";
        break;
      case TRACKMODE_FILEHANDLES:
        ColumnArray[0] = "\33bFile handles";
        ColumnArray[1] = "\33bMode";
        ColumnArray[2] = "\33bIn use?";
        break;
      case TRACKMODE_LOCKS:
        ColumnArray[0] = "\33bLocks";
        ColumnArray[1] = "\33bMode";
        ColumnArray[2] = "\33bIn use?";
        break;
      default:
        ColumnArray[0] = "\33bInternal Error: Unknown TrackMode ID!!!";
        ColumnArray[1] = "";
        ColumnArray[2] = "";
        break;
    }

  }
  return 0;
}

GPROTO LONG ARTL_TrackerListSortFunc(
  register __a1 struct TrackerNode *TN1,
  register __a2 struct TrackerNode *TN2 )
{
  register LONG result;

  switch(TN1->tn_ID)
  {
    case PMSGID_OPENLIBRARY:
      result = Stricmp(TN1->tn_LibName, TN2->tn_LibName);
      break;
    case PMSGID_OPENDEVICE:
      result = Stricmp(TN1->tn_DevName, TN2->tn_DevName);
      break;
    case PMSGID_OPENFONT:
      result = Stricmp(TN1->tn_FontName, TN2->tn_FontName);
      break;
    default:
      result = 0;
      break;
  }
  return result; 
}

struct Hook ARTL_TrackerListMakeHook =
  { { NULL, NULL }, (void *) ARTL_TrackerListMakeFunc, NULL, NULL };
struct Hook ARTL_TrackerListKillHook =
  { { NULL, NULL }, (void *) ARTL_TrackerListKillFunc, NULL, NULL };
struct Hook ARTL_TrackerListShowHook =
  { { NULL, NULL }, (void *) ARTL_TrackerListShowFunc, NULL, NULL };
struct Hook ARTL_TrackerListSortHook =
  { { NULL, NULL }, (void *) ARTL_TrackerListSortFunc, NULL, NULL };

  /*********************************************************************
   *
   *
   *
   *********************************************************************
   *
   */


