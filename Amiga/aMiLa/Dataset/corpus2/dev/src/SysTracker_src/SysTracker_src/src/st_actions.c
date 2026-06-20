/***************************************************************************/
/* st_actions.c - Actions for events (i.e. when a UI widget is pressed).   */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/


GPROTO BOOL ACT_SigEvent( ULONG SigEvent )
{
  /*********************************************************************
   *
   * ACT_SigEvent()
   *
   * If TRUE is returned then SysTracker will quit.
   *
   *********************************************************************
   *
   */

  BOOL Result = FALSE;

  if (ARTL_CheckProcSignals(SigEvent))
    Result = FALSE;

  return FALSE;
}

GPROTO void ACT_Main_TrackMode( void )
{
  /*********************************************************************
   *
   * ACT_Main_TrackMode()
   *
   *********************************************************************
   *
   */

  register struct AppNode *SelectedAN;

  ARTL_Set_TrackMode(GUI_Get_Cycle_Active(OID_MAIN_TRKMODE));
  SelectedAN = GUI_Get_List_Active(OID_MAIN_APPLIST);

  if (SelectedAN)
    ARTL_UpdateTL((struct List *) &SelectedAN->an_TrackerList);
  else
    GUI_Act_List_Clear(OID_MAIN_TRACKERLIST);

}

GPROTO void ACT_Main_Save( void )
{
  /*********************************************************************
   *
   * ACT_Main_Save()
   *
   *********************************************************************
   *
   */

  UBYTE PathBuf[256+2]; ULONG Response; BOOL SaveAll;
  
  Response = GUI_Popup("Request",

    "Do you want to save a list of all the resources allocated by\n"
    "each application or just the currently allocated resources?",

    NULL, "All|Current|Cancel");

  if (Response == 0) return; /* Cancel */
  else if (Response == 1) SaveAll = TRUE;
  else SaveAll = FALSE;
  
  if (GUI_OpenSaveReq((UBYTE *)&PathBuf, 256))
    ARTL_SaveALAsASCII(ARTL_GetAppList(), PathBuf, SaveAll);
}

GPROTO void ACT_Main_Update( void )
{
  /*********************************************************************
   *
   * ACT_Main_Update()
   *
   *********************************************************************
   *
   */

  register struct AppNode *SelectedAN = NULL;       
  register struct Task *SelectedTaskPtr = NULL;

  /* Store the selected entry */

  if (SelectedAN = GUI_Get_List_Active(OID_MAIN_APPLIST))
    SelectedTaskPtr = SelectedAN->an_TaskPtr;

  ARTL_UpdateAL(ARTL_GetAppList());

  /* Reselect the previously selected entry */

  if (SelectedAN && SelectedTaskPtr)
  {
    register LONG Index = ARTL_GetANListIndex_ViaTaskPtr(SelectedTaskPtr);

    if (Index != -1) GUI_Set_List_Active(OID_MAIN_APPLIST, Index);
  }
}

GPROTO void ACT_Main_TrackerListview_DoubleClick( void )
{
  /*********************************************************************
   *
   * ACT_Main_TrackerListview_DoubleClick()
   *
   *********************************************************************
   *
   */

  register struct TrackerNode *SelectedTN;

  if (SelectedTN = GUI_Get_List_Active(OID_MAIN_TRACKERLIST))
  {
    register UBYTE *ResName = STR_Get(SID_UNKNOWN_BRACKET);

    GUI_Act_List_Clear(OID_APPUSING_LISTVIEW);

    switch (SelectedTN->tn_ID)
    {
      case PMSGID_OPENLIBRARY:  ResName = SelectedTN->tn_LibName;  break;
      case PMSGID_OPENDEVICE:   ResName = SelectedTN->tn_DevName;  break;
      case PMSGID_OPENFONT:     ResName = SelectedTN->tn_FontName; break;
      case PMSGID_OPENFROMLOCK: ResName = SelectedTN->tn_FHName;   break;
      case PMSGID_OPEN:         ResName = SelectedTN->tn_FHName;   break;
      case PMSGID_LOCK:         ResName = SelectedTN->tn_LockName; break;
    }

    GUI_Set_Text_Contents(OID_APPUSING_RESNAME, ResName);
    GUI_Set_List_Quiet(OID_APPUSING_LISTVIEW, TRUE);

    /* Scan the entire AppList for apps using this resource. */

    ARTL_FindAppsUsingRes(SelectedTN, ARTL_GetAppList());

    GUI_Set_List_Quiet(OID_APPUSING_LISTVIEW, FALSE);
    GUI_Act_Window_Open(OID_APPUSING_WINDOW, TRUE);
  }
}

GPROTO void ACT_Main_TrackerListview_SingleClick( void )
{
  /*********************************************************************
   *
   * ACT_Main_TrackerListview_SingleClick()
   *
   *********************************************************************
   *
   */
}

GPROTO void ACT_Main_AppListview_SingleClick( void )
{
  /*********************************************************************
   *
   * ACT_Main_AppListview_SingleClick()
   *
   *********************************************************************
   *
   */

  register struct AppNode *SelectedAN;

  SelectedAN = GUI_Get_List_Active(OID_MAIN_APPLIST);

  if (SelectedAN != NULL)
  {
    GUI_Set_Text_Contents(OID_MAIN_OPENCNT, "");
    ARTL_UpdateTL((struct List *) &SelectedAN->an_TrackerList);       
  }
  else
  {
    GUI_Set_Text_Contents(OID_MAIN_OPENCNT, "");
    GUI_Act_List_Clear(OID_MAIN_TRACKERLIST);
  }
}

GPROTO void ACT_Main_Menu_Project_About( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Project_About()
   *
   *********************************************************************
   *
   */

  ULONG PMsgCnt = ARTL_GetPMsgCnt();

  GUI_Popup("About...",
    VERS " (" DATE "),\n"
    "Copyright © " YEAR " Andrew Bell. All rights reserved.\n"
    "\n"
    "Please understand that this software is still very experimental and\n"
    "has the potential to crash your system at any time.\n"
    "\n"
    "email: " EMAILADDY "\n"
    "www: " WEBADDY "\n"
    "\n"
    "Feal free to contact me about this software. Visit my website\n"
    "and make sure that you're using the latest version.\n"
    "\n"
    "(PMsg count is %lu)" , &PMsgCnt, "Continue");  
}

GPROTO void ACT_Main_Menu_Project_About_MUI( void )
{ 
  /*********************************************************************
   *
   * ACT_Main_Menu_Project_About_MUI()
   *
   *********************************************************************
   *
   */

  GUI_Act_AboutGUISystem()
}

GPROTO void ACT_Main_Menu_Project_Settings_MUI( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Project_Settings_MUI()
   *
   *********************************************************************
   *
   */

  GUI_Act_ConfigureGUISystem()
}

GPROTO void ACT_Main_Menu_Project_Hide( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Project_Hide()
   *
   *********************************************************************
   *
   */

  GUI_Set_App_Iconified(TRUE);
}

GPROTO void ACT_Main_Menu_Control_Reset( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Control_Reset()
   *
   *********************************************************************
   *
   */

  GUI_Act_List_Clear(OID_MAIN_TRACKERLIST);
  ARTL_FlushAL(ARTL_GetAppList());
  ARTL_UpdateAL(ARTL_GetAppList());
}

GPROTO void ACT_Main_Menu_Control_ClearDeadApps( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Control_ClearDeadApps()
   *
   *********************************************************************
   *
   */

  register struct AppNode *SelectedAN = NULL;       
  register struct Task *SelectedTaskPtr = NULL;

  if (SelectedAN = GUI_Get_List_Active(OID_MAIN_APPLIST))
    SelectedTaskPtr = SelectedAN->an_TaskPtr;

  ARTL_ClearDeadANs(ARTL_GetAppList());

  /* Reselect the previously selected entry */

  if (SelectedAN && SelectedTaskPtr)
  {
    register LONG Index = ARTL_GetANListIndex_ViaTaskPtr(SelectedTaskPtr);

    if (Index != -1)
      GUI_Set_List_Active(OID_MAIN_APPLIST, Index);
  }
}

GPROTO void ACT_Main_Menu_Control_TrackUnusedResources( BOOL Checked )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Control_TrackUnusedResources()
   *
   *********************************************************************
   *
   */

  if (cfg_TrackUnusedResources = Checked)
  {
    GUI_Set_Menuitem_Enabled(OID_MAIN_WINDOW,
      OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES, TRUE);

    ACT_Main_Update();
  }
  else
  {
    GUI_Set_Menuitem_Enabled(OID_MAIN_WINDOW,
        OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES, FALSE);

    ACT_Main_Menu_Control_ClearUnusedRes();
  }
}

GPROTO void ACT_Main_Menu_Control_ShowUnusedResources( BOOL Checked )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Control_ShowUnusedResources()
   *
   *********************************************************************
   *
   */

  cfg_ShowUnusedResources = Checked;  
  ACT_Main_Update();  
}


GPROTO void ACT_Main_Menu_Control_ClearUnusedRes( void )
{
  /*********************************************************************
   *
   * ACT_Main_Menu_Control_ClearUnusedRes()
   *
   *********************************************************************
   *
   */

  register struct AppNode *SelectedAN = NULL;       
  register struct Task *SelectedTaskPtr = NULL;

  SelectedAN = GUI_Get_List_Active(OID_MAIN_APPLIST);

  if (SelectedAN)
    SelectedTaskPtr = SelectedAN->an_TaskPtr;

  ARTL_ClearUnusedANs(ARTL_GetAppList());

  /* Reselect the previously selected entry */

  if (SelectedAN && SelectedTaskPtr)
  {
    register LONG Index = ARTL_GetANListIndex_ViaTaskPtr(SelectedTaskPtr);

    if (Index != -1)
      GUI_Set_List_Active(OID_MAIN_APPLIST, Index);
  }
}



  /*********************************************************************
   *
   * 
   *
   *********************************************************************
   *
   */


