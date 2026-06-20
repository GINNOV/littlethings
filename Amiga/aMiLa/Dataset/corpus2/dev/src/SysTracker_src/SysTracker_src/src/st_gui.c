/***************************************************************************/
/* st_gui.c - GUI (MUI) control module.                                    */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

/* Note: Different GUI systems might be supported in the future so
         I'm encapsulating all MUI specifics into this module. */

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

#include <mui/nlist_mcc.h>
#include <mui/nlistview_mcc.h>

/***************************************************************************/
/* Data and defines */
/***************************************************************************/

struct Library *MUIMasterBase = NULL;

Object *SysTrkApp = NULL;
Object *Objs[OID_AMOUNT];
Object *MenuStrip = NULL;
struct FileRequester *SaveReq = NULL;

static UBYTE *TrkModeEntries[] = 
{
  "Libraries", "Devices", "Fonts", "Locks", "Opened files", NULL
};

struct NewMenu MainMenuData[] =
{
  nmTitle("Project")

  nmItem("About...",
   "a", 0, OID_MAIN_MENU_PROJECT_ABOUT)

  nmItem("About MUI...",
    "m", 0, OID_MAIN_MENU_PROJECT_ABOUT_MUI)

  nmBar

  nmItem("Settings MUI...",
    "e", 0, OID_MAIN_MENU_PROJECT_SETTINGS_MUI) 

  nmBar

  nmItem("Hide",
    "h", 0, OID_MAIN_MENU_PROJECT_HIDE)

  nmItem("Quit",
    "q", 0, OID_MAIN_MENU_PROJECT_QUIT)


  nmTitle("Control")

  nmItem("Reset SysTracker",
    "r", 0, OID_MAIN_MENU_CONTROL_RESET)

  nmItem("Clear dead applications",
    "c", 0, OID_MAIN_MENU_CONTROL_CLEARDEADAPPS)

  nmItem("Clear unused resources",
    "u", 0, OID_MAIN_MENU_CONTROL_CLEARUNUSEDRES)

  nmBar 

  nmItem("Track unused resources",
    NULL, (CHECKIT|MENUTOGGLE), OID_MAIN_MENU_CONTROL_TRACKUNUSEDRES)

  nmItem("Show unused resources",
    NULL, (CHECKIT|MENUTOGGLE), OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES)

  nmEnd
};

/***************************************************************************/

GPROTO BOOL GUI_InitMUI( void )
{
  /*********************************************************************
   *
   * GUI_InitMUI()
   *
   * Setup the GUI basics. This includes opening muimaster.library and
   * creating the file requesters, etc.
   *
   *********************************************************************
   *
   */

  if (!(MUIMasterBase = OpenLibrary(MUIMASTER_NAME, MUIMASTER_VLATEST)))
  {
    ULONG Fmt[] = { (ULONG) MUIMASTER_NAME, MUIMASTER_VLATEST };

    M_PrgError(STR_Get(SID_I_NEED_LIB), &Fmt);    
    return FALSE;
  }

  SaveReq = MUI_AllocAslRequestTags(ASL_FileRequest,
              ASLFR_TitleText,      STR_Get(SID_SAVE_AS_ASCII),
              ASLFR_PositiveText,   STR_Get(SID_SAVE),
              ASLFR_NegativeText,   STR_Get(SID_QUIT),
              ASLFR_InitialTopEdge, 0,
              ASLFR_InitialHeight,  512,
              ASLFR_InitialFile,    "SysTracker_output.txt",
              ASLFR_InitialDrawer,  "Ram:",             
              ASLFR_Flags1,         (FRF_DOSAVEMODE),
              ASLFR_Flags2,         (FRF_REJECTICONS),
              TAG_DONE);

  if (!SaveReq) return FALSE;

  return TRUE;
}

GPROTO void GUI_EndMUI( void )
{
  /*********************************************************************
   *
   * GUI_EndMUI()
   *
   * Free the resources allocated by GUI_InitMUI().
   *
   *********************************************************************
   *
   */

  if (SaveReq)
  {
    MUI_FreeAslRequest(SaveReq); SaveReq = NULL;
  }

  if (MUIMasterBase)
  {
    CloseLibrary(MUIMasterBase); MUIMasterBase = NULL;
  }
}

struct Process *GUIProcess = NULL;

GPROTO BOOL GUI_Construct( void )
{
  /*********************************************************************
   *
   * GUI_Construct()
   *
   * Construct the entire GUI.
   *
   * Note: This routine should return FALSE if SysTracker is already
   *       running. It should also signal the other SysTracker to bring
   *       it's GUI to front. At the moment, MUI handles this for us.
   *
   *
   *********************************************************************
   *
   */

  extern struct Hook ARTL_AppListMakeHook;
  extern struct Hook ARTL_AppListKillHook;
  extern struct Hook ARTL_AppListShowHook;
  extern struct Hook ARTL_AppListSortHook;
  extern struct Hook ARTL_TrackerListMakeHook;
  extern struct Hook ARTL_TrackerListKillHook;
  extern struct Hook ARTL_TrackerListShowHook;
  extern struct Hook ARTL_TrackerListSortHook;

  GUIProcess = (struct Process *) FindTask(NULL);

  /* Application */

  SysTrkApp = (APTR) ApplicationObject,
    MUIA_Application_Title,       "SysTracker",
    MUIA_Application_Version,     "$VER: " VERS " (" DATE ")",
    MUIA_Application_Copyright,   "Copyright © " YEAR " Andrew Bell",
    MUIA_Application_Author,      "Andrew Bell",
    MUIA_Application_Description, STR_Get(SID_SYSTEM_RESOURCE_TRACKER),
    MUIA_Application_Base,        "SYSTRACKER",
    MUIA_Application_SingleTask,  TRUE,
    SubWindow, Objs[OID_MAIN_WINDOW] = (APTR) WindowObject,
      MUIA_Window_ScreenTitle, VERS,
      MUIA_Window_Title,       VERS " Copyright © " YEAR " Andrew Bell.",
      MUIA_Window_Menustrip,   MenuStrip = MUI_MakeObject(MUIO_MenustripNM, MainMenuData, 0),
      MUIA_Window_ID,          MAKE_ID('M','A','I','N'),
      MUIA_Window_Width,       MUIV_Window_Width_Visible(80),
      MUIA_Window_Height,      MUIV_Window_Height_Visible(80),
      WindowContents, VGroup,
        Child, HGroup,
          Child, Objs[OID_MAIN_APPLISTVIEW] = NListviewObject,
            MUIA_ShortHelp,            STR_Get(SID_SHORTHELP_APPLIST),
            MUIA_NListview_NList,       Objs[OID_MAIN_APPLIST] = NListObject,
              MUIA_ObjectID,            MAKE_ID('A','P','P','L'),
              MUIA_NList_Input,         TRUE,
              MUIA_NList_MultiSelect,   MUIV_NList_MultiSelect_None,
              MUIA_NList_Format,        "MIW=50 BAR,MIW=20 BAR,MIW=20",
              MUIA_NList_Active,        MUIV_NList_Active_Top,
              MUIA_NList_Title,         TRUE,
              MUIA_NList_AutoVisible,   TRUE,
              MUIA_NList_ConstructHook, &ARTL_AppListMakeHook,
              MUIA_NList_DestructHook,  &ARTL_AppListKillHook,
              MUIA_NList_DisplayHook,   &ARTL_AppListShowHook,
              MUIA_NList_CompareHook,   &ARTL_AppListSortHook,
            End,  
          End,  /* Listview object */
          Child, BalanceObject, End,
          Child, VGroup,
            Child, Objs[OID_MAIN_TRACKERLISTVIEW] = NListviewObject,
              MUIA_ShortHelp,            STR_Get(SID_SHORTHELP_TRACKERLIST),
              MUIA_NListview_NList,      Objs[OID_MAIN_TRACKERLIST] = NListObject,
                MUIA_NList_MultiSelect,  MUIV_NList_MultiSelect_None,
                MUIA_NList_Input,        TRUE,
                MUIA_ObjectID,            MAKE_ID('T','R','K','L'),
                MUIA_NList_Format,        "BAR,BAR,",
                MUIA_NList_Active,        MUIV_NList_Active_Top,
                MUIA_NList_Title,         TRUE,
                MUIA_NList_AutoVisible,   TRUE,
                MUIA_NList_ConstructHook, &ARTL_TrackerListMakeHook,
                MUIA_NList_DestructHook,  &ARTL_TrackerListKillHook,
                MUIA_NList_DisplayHook,   &ARTL_TrackerListShowHook,
                MUIA_NList_CompareHook,   &ARTL_TrackerListSortHook,
              End,  
            End,  /* NListview object */
            Child, HGroup,
              Child, KeyLabel(STR_Get(SID_TRACK_MODE), 'm'),
              Child, Objs[OID_MAIN_TRKMODE] = CycleObject,
                MUIA_Cycle_Entries, TrkModeEntries,
                MUIA_Cycle_Active,  0,
                MUIA_ShortHelp,     STR_Get(SID_SHORTHELP_TRACK_MODE),
                MUIA_ControlChar,   'v',
              End,
            End,
          End,
        End,
        Child, HGroup,
          Child, Objs[OID_MAIN_SAVE]     = MyKeyButton(STR_Get(SID_SAVE),'s', STR_Get(SID_SHORTHELP_SAVE)),
          Child, Objs[OID_MAIN_UPDATE]   = MyKeyButton(STR_Get(SID_UPDATE),'u', STR_Get(SID_SHORTHELP_UPDATE)),
          Child, Objs[OID_MAIN_QUIT]     = MyKeyButton(STR_Get(SID_QUIT), 'q', STR_Get(SID_SHORTHELP_QUIT)),
        End,
      End,  /* MAIN WindowContents */
    End,  /* MAIN WindowObject */

    SubWindow, Objs[OID_APPUSING_WINDOW] = (APTR) WindowObject,
      MUIA_Window_Title,       STR_Get(SID_APPS_USING_THIS_RES),
      MUIA_Window_ID,          MAKE_ID('A','P','U','S'),
      MUIA_Window_Width,       MUIV_Window_Width_Visible(80),
      MUIA_Window_Height,      MUIV_Window_Height_Visible(80),
      WindowContents, VGroup,
        Child, Objs[OID_APPUSING_RESNAME] = TextObject,     
          MUIA_ShortHelp,     STR_Get(SID_SHORTHELP_APPUSING_RESNAME),
          MUIA_Text_PreParse, "\33c",
          TextFrame,
          MUIA_Background,    MUII_TextBack,
        End,
        Child, Objs[OID_APPUSING_LISTVIEW] = NListviewObject,
          MUIA_ShortHelp,             STR_Get(SID_SHORTHELP_APPUSING_LIST),
          MUIA_NListview_NList,       Objs[OID_APPUSING_LIST] = NListObject,
            MUIA_ObjectID,            MAKE_ID('A','P','U','L'),
            MUIA_NList_MultiSelect,   MUIV_NList_MultiSelect_None,
            MUIA_NList_Input,         FALSE,
            MUIA_NList_Title,         FALSE,
            MUIA_NList_AutoVisible,   TRUE,
            MUIA_NList_ConstructHook, MUIV_NList_ConstructHook_String,
            MUIA_NList_DestructHook,  MUIV_NList_DestructHook_String,
          End,  
        End,  /* NListview object */
        Child, Objs[OID_APPUSING_EXIT]     = MyKeyButton(STR_Get(SID_EXIT),'e', STR_Get(SID_SHORTHELP_EXIT)),
      End,      
    End,  /* APUS WindowObject */
  End;  /* ApplicationObject */

  if (SysTrkApp)
  {
    DoMethod(SysTrkApp,
      MUIM_Notify, MUIA_Application_DoubleStart, MUIV_EveryTime,
      SysTrkApp, 2, MUIM_Application_ReturnID, OID_APP_DOUBLESTART );

    /* Main window */

    DoMethod(Objs[OID_MAIN_WINDOW], MUIM_Notify,
      MUIA_Window_CloseRequest, TRUE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_QUIT);
    DoMethod(Objs[OID_MAIN_QUIT], MUIM_Notify,
      MUIA_Pressed, FALSE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_QUIT);
    DoMethod(Objs[OID_MAIN_SAVE], MUIM_Notify,
      MUIA_Pressed, FALSE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_SAVE);
    DoMethod(Objs[OID_MAIN_UPDATE], MUIM_Notify,
      MUIA_Pressed, FALSE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_UPDATE);
    DoMethod(Objs[OID_MAIN_TRKMODE], MUIM_Notify,
      MUIA_Cycle_Active, MUIV_EveryTime, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_TRKMODE);
    DoMethod(Objs[OID_MAIN_TRACKERLISTVIEW], MUIM_Notify,
      MUIA_NList_DoubleClick, MUIV_EveryTime, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_TRACKERLISTVIEW_DOUBLECLICK);
    DoMethod(Objs[OID_MAIN_TRACKERLISTVIEW], MUIM_Notify,
      MUIA_NList_Active, MUIV_EveryTime, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_TRACKERLISTVIEW_SINGLECLICK);
    DoMethod(Objs[OID_MAIN_APPLISTVIEW], MUIM_Notify,
      MUIA_NList_Active, MUIV_EveryTime, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_MAIN_APPLISTVIEW_SINGLECLICK);

    /* Setup menus */

    DoMethod(MenuStrip, MUIM_SetUData,
      OID_MAIN_MENU_CONTROL_TRACKUNUSEDRES,
        MUIA_Menuitem_Checked, cfg_TrackUnusedResources);
    DoMethod(MenuStrip, MUIM_SetUData,
      OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES,
        MUIA_Menuitem_Checked, cfg_ShowUnusedResources);

    if (cfg_TrackUnusedResources)
      GUI_Set_Menuitem_Enabled(OID_MAIN_WINDOW,
        OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES, TRUE);
    else
      GUI_Set_Menuitem_Enabled(OID_MAIN_WINDOW,
        OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES, FALSE);

    /* App resource window */

    DoMethod(Objs[OID_APPUSING_WINDOW], MUIM_Notify,
      MUIA_Window_CloseRequest, TRUE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_APPUSING_EXIT);
    DoMethod(Objs[OID_APPUSING_EXIT], MUIM_Notify,
      MUIA_Pressed, FALSE, SysTrkApp, 2,
      MUIM_Application_ReturnID, OID_APPUSING_EXIT);

    return TRUE;
  }
  else
  {   
    M_PrgError(STR_Get(SID_NO_APP_OBJECT), NULL);
    return FALSE;
  }
  return TRUE;
}

GPROTO void GUI_Destruct( void )
{
  /*********************************************************************
   *
   * GUI_Destruct()
   *
   * Free the entire GUI.
   *
   *********************************************************************
   *
   */

  if (SysTrkApp)
  {
    MUI_DisposeObject(SysTrkApp); SysTrkApp = NULL;
  }
}

GPROTO void GUI_EventHandler( void )
{
  /*********************************************************************
   *
   * GUI_EventHandler()
   *
   * Main event processing loop. This routine is really the core of the
   * program. Primarily it handles MUI events and handles the IPC for
   * the ARTL handler process.
   *
   *********************************************************************
   *
   */

  ULONG SelState = 0;
  register BOOL Running = TRUE;

  while (Running) /* Main program loop */
  {
    /* And exec said: Let there be signals! :) */
    
    ULONG Sigs = 0, SigEvent = 0;
  
    switch(DoMethod(SysTrkApp, MUIM_Application_NewInput, &Sigs))
    {
      case OID_APP_DOUBLESTART:
        set(SysTrkApp, MUIA_Application_Iconified, FALSE);
        GUI_Popup("Information",
          "SysTracker is already running!", NULL, "OK");
        set(Objs[OID_MAIN_WINDOW], MUIA_Window_Activate, TRUE);
        break;
      
      /**********      MAIN WINDOW       **********/

      case MUIV_Application_ReturnID_Quit:
      case OID_MAIN_QUIT:
        Running = FALSE; break;
      case OID_MAIN_TRKMODE:
        ACT_Main_TrackMode(); break;
      case OID_MAIN_SAVE:
        ACT_Main_Save(); break;
      case OID_MAIN_UPDATE:
        ACT_Main_Update(); break;
      case OID_MAIN_TRACKERLISTVIEW_DOUBLECLICK:
        ACT_Main_TrackerListview_DoubleClick(); break;
      case OID_MAIN_TRACKERLISTVIEW_SINGLECLICK:
        ACT_Main_TrackerListview_SingleClick(); break;
      case OID_MAIN_APPLISTVIEW_SINGLECLICK:
        ACT_Main_AppListview_SingleClick(); break;

      /**********   MAIN WINDOW MENUS    **********/

      case OID_MAIN_MENU_PROJECT_ABOUT:
        ACT_Main_Menu_Project_About(); break;
      case OID_MAIN_MENU_PROJECT_ABOUT_MUI:
        ACT_Main_Menu_Project_About_MUI(); break;
      case OID_MAIN_MENU_PROJECT_SETTINGS_MUI:
        ACT_Main_Menu_Project_Settings_MUI(); break;
      case OID_MAIN_MENU_PROJECT_HIDE:
        ACT_Main_Menu_Project_Hide(); break;
      case OID_MAIN_MENU_PROJECT_QUIT:
        Running = FALSE; break;
      case OID_MAIN_MENU_CONTROL_RESET:
        ACT_Main_Menu_Control_Reset(); break;
      case OID_MAIN_MENU_CONTROL_CLEARDEADAPPS:
        ACT_Main_Menu_Control_ClearDeadApps(); break; 
      case OID_MAIN_MENU_CONTROL_CLEARUNUSEDRES:
        ACT_Main_Menu_Control_ClearUnusedRes(); break;

      case OID_MAIN_MENU_CONTROL_TRACKUNUSEDRES:
      {
        ULONG Checked = FALSE;
        DoMethod(MenuStrip, MUIM_GetUData,
          OID_MAIN_MENU_CONTROL_TRACKUNUSEDRES,
          MUIA_Menuitem_Checked, &Checked);
        ACT_Main_Menu_Control_TrackUnusedResources((BOOL)Checked);
        break;
      }
      
      case OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES:
      {
        ULONG Checked = FALSE;
        DoMethod(MenuStrip, MUIM_GetUData,
          OID_MAIN_MENU_CONTROL_SHOWUNUSEDRES,
          MUIA_Menuitem_Checked, &Checked);
        ACT_Main_Menu_Control_ShowUnusedResources((BOOL)Checked);
        break;
      }
      default: break;

      /**********   APP RESOURCE WINDOW   **********/

      case OID_APPUSING_EXIT:
        set(Objs[OID_APPUSING_WINDOW], MUIA_Window_Open, FALSE );
        break;
    }

    if (Sigs && Running)
    {
      SigEvent = Wait(Sigs | SIGBREAKF_CTRL_C);
      if (SigEvent & SIGBREAKF_CTRL_C) Running = FALSE;
      if (ACT_SigEvent(SigEvent)) Running = FALSE;
    }
  } /* while() */

  set(Objs[ OID_MAIN_WINDOW ], MUIA_Window_Open, FALSE);
  set(Objs[ OID_APPUSING_WINDOW ], MUIA_Window_Open, FALSE);
}

/* Simple abstaction layer */

GPROTO ULONG GUI_Popup( UBYTE *Title, UBYTE *Body, void *BodyFmt,
  UBYTE *Gads )
{
  /*********************************************************************
   *
   * GUI_Popup()
   *
   * Display a requester, with custom text & title. Will default to
   * intuition.library for it's requester if MUIMasterBase has not yet
   * been initialized.
   *
   *********************************************************************
   *
   */

  if (SysBase->LibNode.lib_Version < 36) return 0;

  /* Note: We can only use MUI functions on the context of the
           creating task, in this case the main SysTracker process. */

  if (MUIMasterBase &&
      (GUIProcess == (struct Process *) FindTask(NULL)))
  {
    return MUI_RequestA(SysTrkApp, Objs[OID_MAIN_WINDOW], 0,
      Title, Gads, Body, BodyFmt);
  }
  else if (IntuitionBase)
  {
    /* This code executed when MUIMasterBase is not valid */

    struct EasyStruct EZ =
    {
      sizeof(struct EasyStruct),
      0, NULL, NULL, NULL
    };

    EZ.es_Title        = Title;
    EZ.es_TextFormat   = Body;
    EZ.es_GadgetFormat = Gads;

    /* Note: If window is NULL, then req will default to WB */

    return EasyRequestArgs(NULL, &EZ, NULL, BodyFmt);
  }
  else if (IntuitionBase = OpenLibrary("intuition.library", 36L))
  {
    /* This code executed when MUIMasterBase and IntuitionBase
       aren't valid */
    
    ULONG r;    
    struct EasyStruct EZ =
    {
      sizeof(struct EasyStruct),
      0UL, NULL, NULL, NULL
    };

    EZ.es_Title        = Title;
    EZ.es_TextFormat   = Body;
    EZ.es_GadgetFormat = Gads;
    r = EasyRequestArgs(NULL, &EZ, NULL, BodyFmt);
    CloseLibrary((struct Library *) IntuitionBase);
    IntuitionBase = NULL;
    return r;
  }
  else return 0; /* Pre-OS 36 don't see any requesters. */
}

GPROTO ULONG GUI_Get_Cycle_Active( ULONG CycleID )
{
  ULONG CycVal = 0;
  
  get(Objs[CycleID], MUIA_Cycle_Active, &CycVal);

  return CycVal;
}

GPROTO APTR GUI_Get_List_Entry( ULONG ListID, ULONG Index )
{
  APTR ListEntry = NULL;
  
  DoMethod(Objs[ListID], MUIM_NList_GetEntry, Index, &ListEntry);

  return ListEntry;
}

GPROTO APTR GUI_Get_List_Active( ULONG ListID )
{
  APTR ListActive = 0;

  DoMethod(Objs[ListID],
    MUIM_NList_GetEntry, MUIV_NList_GetEntry_Active, &ListActive);

  return ListActive;
}

GPROTO void GUI_Act_List_Clear( ULONG ListID )
{
  DoMethod(Objs[ListID], MUIM_NList_Clear);
}


GPROTO struct Screen *GUI_Get_ScreenPtr( void )
{
  struct Screen *Scr = NULL;
  
  get(Objs[OID_MAIN_WINDOW], MUIA_Window_Screen, &Scr);
  
  return Scr;
}

GPROTO void GUI_Set_List_Active( ULONG ListID, ULONG Index )
{
  set(Objs[ListID], MUIA_NList_Active, Index);  
}

GPROTO void GUI_Set_Text_Contents( ULONG TextID, UBYTE *Str )
{
  set(Objs[TextID], MUIA_Text_Contents, Str);
}

GPROTO void GUI_Set_List_Quiet( ULONG ListID, BOOL State )
{
  set(Objs[ListID], MUIA_NList_Quiet, State);
}

GPROTO void GUI_Act_Window_Open( ULONG WndID, BOOL State )
{
  set(Objs[WndID], MUIA_Window_Open, State);
}

GPROTO void GUI_Act_AboutGUISystem( void )
{
  if (!Objs[OID_MAIN_MENU_PROJECT_ABOUT_MUI])
  {
    Objs[OID_MAIN_MENU_PROJECT_ABOUT_MUI] =
      (Object *) AboutmuiObject,
        MUIA_Window_RefWindow, Objs[OID_MAIN_WINDOW],
        MUIA_Aboutmui_Application, SysTrkApp,
      End;
  }

  if (Objs[OID_MAIN_MENU_PROJECT_ABOUT_MUI])
    set(Objs[OID_MAIN_MENU_PROJECT_ABOUT_MUI], MUIA_Window_Open, TRUE);
}

GPROTO void GUI_Act_ConfigureGUISystem( void )
{
  DoMethod(SysTrkApp, MUIM_Application_OpenConfigWindow, 0L); 
}

GPROTO void GUI_Set_App_Iconified( BOOL State )
{
  set(SysTrkApp, MUIA_Application_Iconified, State);
}


GPROTO BOOL GUI_OpenSaveReq( UBYTE *PathBuf, ULONG PathBufLen )
{
  struct Screen *Scr = GUI_Get_ScreenPtr();

  if (MUI_AslRequestTags(SaveReq,
        ASLFR_Screen, Scr,
        TAG_DONE))
  {
    strcpy(PathBuf, SaveReq->fr_Drawer);

    if (AddPart(PathBuf, SaveReq->fr_File, PathBufLen))
      return TRUE;
  }
  return FALSE;
}


GPROTO void GUI_Act_List_InsertABC( ULONG ListID, APTR ListEntry )
{
  DoMethod(Objs[ListID], MUIM_NList_InsertSingle,
    ListEntry, MUIV_NList_Insert_Sorted);
}

GPROTO void GUI_Set_Menuitem_Enabled( ULONG WinID, ULONG MenuItemID,
  BOOL NewState )
{
  if (WinID == OID_MAIN_WINDOW)
    DoMethod(MenuStrip, MUIM_SetUData, MenuItemID,
      MUIA_Menuitem_Enabled, NewState);
}


