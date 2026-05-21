/* RCS Id: $Id: PrefsWindow.c 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Locked version: $Revision: 1.815 $
*/

#include "AmiFTP.h"
#include "gui.h"

struct Window *MainPrefsWindow;
Object *MainPrefsLayout;
Object *MainPrefsWin_Object;

struct Window *OpenMainPrefsWindow(void);
void CloseMainPrefsWindow(void);
void UpdateConfig(void);
void FreeClicktabList(struct List *list);
int BuildClicktabList(void);

static int SelectFont(char *FontName, UWORD *YSize);

enum {
    MPG_Tab=0, MPG_Page,
    MPG_AnonymousPW, MPG_ViewCommand, MPG_DefaultDLDir, MPG_DefaultDLDirGad,
    MPG_ProxyHost, MPG_ProxyPort, MPG_ProxyDefault, MPG_IgnoreCase,
    MPG_BufferSize,MPG_CacheSize,MPG_DeleteOnExit,MPG_DisplayBeep,
    MPG_ADTPattern, MPG_PreserveDir, MPG_ShowMOTD, MPG_GetReadme, 
    MPG_DefaultScreen, MPG_PublicScreen,
    MPG_DefaultFonts, MPG_InterfaceFont, MPG_InterfaceFontB, MPG_FilelistFont, 
    MPG_FilelistFontB, MPG_ShowButtons, MPG_ToolBar, MPG_Log, MPG_LogFile,
    MPG_OK, MPG_Cancel,
    NumGadgets_MPG};

struct Gadget *MPG_List[NumGadgets_MPG];

static char buf1[100],buf2[100],buf3[100],buf4[100],buf5[100],buf6[513];
static char pubscreen[256];

static struct DrawInfo *drinfo;
static struct List tablist;
static struct Gadget *pagelayout;
static BOOL MainInterfaceRestart=FALSE;
static ULONG LastPage=0;

static char intfontname[40];
static char listfontname[40];
static char intfont[40];
static char listfont[40];
static UWORD intsize;
static UWORD listsize;

struct cltabs {
    APTR String;
    ULONG Enabled;
};

struct cltabs clicktabs[]={
    {MPW_General, TRUE},
    {MPW_ADT, FALSE},
    {MPW_Display, FALSE},
    {MPW_Proxy, FALSE},
    {"Log", FALSE},
};

int OpenPrefsWindow(void)
{
    ULONG done=FALSE;
    ULONG signal,wait,mainwinsignal;

    MainInterfaceRestart=FALSE;

    if (!BuildClicktabList()) {
	FreeClicktabList(&tablist);
	return 0;
    }

    if (!OpenMainPrefsWindow()) {
	struct Node *node;
	while(node=RemHead(&tablist)) {
	    FreeClickTabNode(node);
	}
	return 0;
    }

    GetAttr(WINDOW_SigMask, MainPrefsWin_Object, &signal);
    GetAttr(WINDOW_SigMask, MainWin_Object, &mainwinsignal);
    LockWindow(MainWin_Object);

    while (!done) {
	wait=Wait(signal|mainwinsignal|AG_Signal);
	if (wait&AG_Signal)
	  HandleAmigaGuide();
	if (wait&signal) {
	    done=HandleMainPrefsIDCMP();
	}
	if (wait&mainwinsignal)
	  HandleMainWindowIDCMP(FALSE);
    }

    CloseMainPrefsWindow();
    UnlockWindow(MainWin_Object);

    if (MainInterfaceRestart) {
	CloseMainWindow();
	OpenFTPWindow(FALSE);
    }

    FreeClicktabList(&tablist);

    return 1;
}

ULONG HandleMainPrefsIDCMP(void)
{
    ULONG result,done=FALSE;
    UWORD code=NULL;

    while ((result=CA_HandleInput(MainPrefsWin_Object, &code))!=WMHI_LASTMSG) {
	switch (result & WMHI_CLASSMASK) {
	  case WMHI_CLOSEWINDOW:
	    done=TRUE;
	    break;
	  case WMHI_RAWKEY:
	    if (code==69)
	      done=TRUE;
	    else if (code==95)
	      SendAGMessage(AG_GLOBPREFS);
	    break;
	  case WMHI_GADGETUP:
	    switch (result & WMHI_GADGETMASK) {
	      case MPG_Tab: {
		  ULONG tabnum, pagenum;

		  GetAttrs(MPG_List[MPG_Tab], CLICKTAB_Current, &tabnum, TAG_DONE);
		  GetAttrs(MPG_List[MPG_Page], PAGE_Current, &pagenum, TAG_DONE);
		  if (tabnum!=pagenum) {
		      SetGadgetAttrs(MPG_List[MPG_Page], MainPrefsWindow, NULL,
				     PAGE_Current, tabnum, TAG_DONE);
		      RethinkLayout(pagelayout, MainPrefsWindow, NULL, TRUE);
		  }
		  break;
	      }
	      case MPG_FilelistFontB:
		if (SelectFont(&listfont[0], &listsize)) {
		    sprintf(listfontname, "%s/%d", listfont, listsize);
		    SetGadgetAttrs(MPG_List[MPG_FilelistFont], MainPrefsWindow, NULL,
				   GA_Text, listfontname,
				   TAG_DONE);
		    RefreshGList(MPG_List[MPG_FilelistFont], MainPrefsWindow, NULL,1);
		}
		break;
	      case MPG_InterfaceFontB:
		if (SelectFont(&intfont[0], &intsize)) {
		    sprintf(intfontname, "%s/%d", intfont, intsize);
		    SetGadgetAttrs(MPG_List[MPG_InterfaceFont], MainPrefsWindow, NULL,
				   GA_Text, intfontname,
				   TAG_DONE);
		    RefreshGList(MPG_List[MPG_InterfaceFont], MainPrefsWindow, NULL,1);
		}
		break;
	      case MPG_DefaultDLDirGad:
		{
		    char tbuf[255];

		    if (DLPath(MainPrefsWin_Object,
			       GetString(MPG_List[MPG_DefaultDLDir]), tbuf)) {
			if (SetGadgetAttrs(MPG_List[MPG_DefaultDLDir],
					   MainPrefsWindow, NULL,
					   STRINGA_TextVal, tbuf, TAG_END))
			  RefreshGList(MPG_List[MPG_DefaultDLDir],
				       MainPrefsWindow, NULL, 1);
		    }
		}
		break;
	      case MPG_DefaultScreen:
		{
		    ULONG attr;
		    GetAttr(GA_Selected, MPG_List[MPG_DefaultScreen], &attr);
		    SetGadgetAttrs(MPG_List[MPG_PublicScreen], MainPrefsWindow, NULL,
				       GA_Disabled, attr?TRUE:FALSE,
				       TAG_DONE);
			RefreshGList(MPG_List[MPG_PublicScreen], MainPrefsWindow, NULL, 1);
		}
		break;
	      case MPG_DefaultFonts:
		{
		    ULONG attr;
		    int i;

		    GetAttr(GA_Selected, MPG_List[MPG_DefaultFonts], &attr);
		    for (i=MPG_InterfaceFont; i<MPG_InterfaceFont+4; i++) {
			SetGadgetAttrs(MPG_List[i], MainPrefsWindow, NULL,
				       GA_Disabled, attr?TRUE:FALSE,
				       TAG_DONE);
			RefreshGList(MPG_List[i], MainPrefsWindow, NULL, 1);
		    }
		}
		break;
	      case MPG_OK: {
		  done=TRUE;
		  UpdateConfig();
		  break;
	      }
	      case MPG_Cancel: {
		  done=TRUE;
		  break;
	      }
	    }
	    break;
	}
    }
    return done;
}

struct Window *OpenMainPrefsWindow(void)
{
    struct LayoutLimits limits;
    
    if (!MainPrefs.mp_FontName) {
	strcpy(intfont, AmiFTPAttrF->ta_Name);
	intsize=AmiFTPAttrF->ta_YSize;
    }
    else {
	strcpy(intfont, MainPrefs.mp_FontName);
	intsize=MainPrefs.mp_FontSize;
    }

    if (!MainPrefs.mp_ListFontName) {
	strcpy(listfont, ListViewAttrF->ta_Name);
	listsize=ListViewAttrF->ta_YSize;
    }
    else {
	strcpy(listfont, MainPrefs.mp_ListFontName);
	listsize=MainPrefs.mp_ListFontSize;
    }

    sprintf(intfontname, "%s/%ld", intfont, intsize);
    sprintf(listfontname, "%s/%ld", listfont, listsize);

    if (MainPrefsWindow)
      return MainPrefsWindow;

    if (MainPrefs.mp_AnonymousPW)
      strcpy(buf1, MainPrefs.mp_AnonymousPW);
    else
      memset(buf1, 0, sizeof(buf1));

    if (MainPrefs.mp_ViewCommand)
      strcpy(buf2, MainPrefs.mp_ViewCommand);
    else
      memset(buf2, 0, sizeof(buf2));

    if (MainPrefs.mp_LocalDir)
      strcpy(buf3, MainPrefs.mp_LocalDir);
    else
      memset(buf3, 0, sizeof(buf3));

    if (MainPrefs.mp_ProxyServer)
      strcpy(buf4, MainPrefs.mp_ProxyServer);
    else
      memset(buf4, 0, sizeof(buf4));

    if (MainPrefs.mp_HideADTPattern)
      strcpy(buf6, MainPrefs.mp_HideADTPattern);
    else
      memset(buf6, 0, sizeof(buf6));

    if (MainPrefs.mp_PubScreen)
      strcpy(pubscreen, MainPrefs.mp_PubScreen);
    else 
      memset(pubscreen, 0, sizeof(pubscreen));

    MainPrefsLayout=LayoutObject,
                     GA_DrawInfo, DrawInfo,
                     GA_TextAttr, AmiFTPAttrF,
                     LAYOUT_DeferLayout, TRUE,
                     LAYOUT_SpaceOuter, FALSE,
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

                     StartMember, MPG_List[MPG_Tab]=ClickTabObject,
                          GA_ID, MPG_Tab,
                          GA_RelVerify, TRUE,
                          CLICKTAB_Labels, &tablist,
                          CLICKTAB_Current, LastPage,
                     EndMember,

                     LAYOUT_AddChild,pagelayout=LayoutObject, LAYOUT_SpaceOuter, TRUE,
                     LAYOUT_AddChild,MPG_List[MPG_Page]=PageObject,
                     PAGE_Add, LayoutObject, /* Start of page 0 General */
                     GA_TextAttr, AmiFTPAttrF,
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                     LAYOUT_HorizAlignment, LALIGN_RIGHT,
                     StartVGroup,
                     StartMember, MPG_List[MPG_AnonymousPW]=StringObject,
                       GA_ID, MPG_AnonymousPW,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)buf1,
                       STRINGA_MaxChars, 50,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_Password)),

                     StartMember, MPG_List[MPG_ViewCommand]=StringObject,
                       GA_ID, MPG_ViewCommand,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)buf2,
                       STRINGA_MaxChars, 50,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_ViewCommand)),

                     StartHGroup, Spacing(FALSE),

                       StartMember, MPG_List[MPG_DefaultDLDir]=StringObject,
                         GA_ID, MPG_DefaultDLDir,
                         GA_RelVerify, TRUE,
                         GA_TabCycle, TRUE,
                         STRINGA_Buffer, (ULONG)buf3,
                         STRINGA_MaxChars, 50,
                         StringEnd,

                       StartMember, MPG_List[MPG_DefaultDLDirGad]=ButtonObject,
                         GA_ID, MPG_DefaultDLDirGad,
                         GA_RelVerify, TRUE,
                         BUTTON_AutoButton, BAG_POPDRAWER,
                         ButtonEnd,
                         CHILD_WeightedWidth, 0,
                         CHILD_WeightedHeight, 0,
                       EndGroup,
                       Label(GetAmiFTPString(MPW_DefDownloadDir)),

                     StartMember, MPG_List[MPG_BufferSize]=IntegerObject,
                       GA_ID, MPG_BufferSize,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       INTEGER_Minimum, 512,
                       INTEGER_Number, (ULONG)MainPrefs.mp_BufferSize,
                       INTEGER_MaxChars, 8,
                       IntegerEnd,
//                       CHILD_NominalSize, TRUE,
//                       CHILD_WeightedWidth, 0,
                       Label(GetAmiFTPString(MPW_BufferSize)),

                     StartMember, MPG_List[MPG_CacheSize]=IntegerObject,
                       GA_ID, MPG_CacheSize,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       INTEGER_Number, (ULONG)MainPrefs.mp_CacheSize,
                       INTEGER_Minimum, 1,
                       INTEGER_Maximum, 10,
                       INTEGER_MaxChars, 6,
                       IntegerEnd,
//                       CHILD_NominalSize,TRUE,
//                       CHILD_WeightedWidth,0,
                       Label(GetAmiFTPString(MPW_DirCacheSize)),
                     EndGroup,
                     StartHGroup,
                     StartVGroup,
                     StartMember, MPG_List[MPG_DeleteOnExit]=CheckBoxObject,
                       GA_ID, MPG_DeleteOnExit,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_DeleteViewed),
                       GA_Selected, MainPrefs.mp_DeleteFiles,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                     EndGroup,

                     StartVGroup,
                     StartMember, MPG_List[MPG_IgnoreCase]=CheckBoxObject,
                       GA_ID, MPG_IgnoreCase,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_IgnoreCase),
                       GA_Selected, MainPrefs.mp_IgnoreCase,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
                     StartMember, MPG_List[MPG_DisplayBeep]=CheckBoxObject,
                       GA_ID, MPG_DisplayBeep,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_Beep),
                       GA_Selected, MainPrefs.mp_DisplayBeep,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                     EndGroup,EndGroup,CHILD_WeightedWidth, 0,
                   LayoutEnd, /* End of page 0 */

                   PAGE_Add, VGroupObject, TAligned, //LayoutObject, /* Start of page 1 ADT */
                     GA_TextAttr, AmiFTPAttrF,
                     StartVGroup, TAligned, 
                     StartMember, MPG_List[MPG_ADTPattern]=StringObject,
                       GA_ID, MPG_ADTPattern,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)buf6,
                       STRINGA_MaxChars, 511,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_HideDirectories)),

                     StartMember, MPG_List[MPG_PreserveDir]=CheckBoxObject,
                       GA_ID, MPG_PreserveDir,
                       GA_RelVerify, TRUE,
                       GA_Disabled, TRUE,
                       GA_Text, GetAmiFTPString(MPW_PreservePath),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,

                     StartMember, MPG_List[MPG_ShowMOTD]=CheckBoxObject,
                       GA_ID, MPG_ShowMOTD,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_ShowMOTD),
                       GA_Selected, MainPrefs.mp_ShowMOTD,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,

                     StartMember, MPG_List[MPG_GetReadme]=CheckBoxObject,
                       GA_ID, MPG_GetReadme,
                       GA_RelVerify, TRUE,
                       GA_Selected, MainPrefs.mp_GetReadme,
                       GA_Text, GetAmiFTPString(MPW_GetReadme),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
                   EndGroup, CHILD_WeightedHeight, 0,
                   LayoutEnd, /* End of page 1 */

                   PAGE_Add, VGroupObject, TAligned, /* Start of page 3 display */
                     GA_TextAttr, AmiFTPAttrF,
                     StartVGroup, TAligned, 

                     StartMember, MPG_List[MPG_DefaultScreen]=CheckBoxObject,
                       GA_ID, MPG_DefaultScreen,
                       GA_RelVerify, TRUE,
                       GA_Selected, MainPrefs.mp_OpenOnDefaultScreen,
                       GA_Text, GetAmiFTPString(MPW_DefaultScreen),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,

                     StartMember, MPG_List[MPG_PublicScreen]=StringObject,
                       GA_ID, MPG_PublicScreen,
                       GA_Disabled, MainPrefs.mp_OpenOnDefaultScreen?TRUE:FALSE,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)pubscreen,
                       STRINGA_MaxChars, 255,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_PublicScreen)),

                     StartMember, MPG_List[MPG_DefaultFonts]=CheckBoxObject,
                       GA_ID, MPG_DefaultFonts,
                       GA_RelVerify, TRUE,
                       GA_Selected, MainPrefs.mp_UseDefaultFonts,
                       GA_Text, GetAmiFTPString(MPW_SystemFonts),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,

                     StartHGroup, Spacing(FALSE),
                     StartMember, MPG_List[MPG_InterfaceFont]=ButtonObject,
                       GA_ID, MPG_InterfaceFont,
                       GA_RelVerify, TRUE,
                       GA_ReadOnly, TRUE,
                       GA_Disabled, MainPrefs.mp_UseDefaultFonts?TRUE:FALSE,
                       GA_Text, intfontname,
                       BUTTON_Justification, BCJ_LEFT,
                       ButtonEnd,

                     StartMember, MPG_List[MPG_InterfaceFontB]=ButtonObject,
                       GA_ID, MPG_InterfaceFontB,
                       GA_RelVerify, TRUE,
                       GA_Disabled, MainPrefs.mp_UseDefaultFonts?TRUE:FALSE,
                       BUTTON_AutoButton, BAG_POPFONT,
                       ButtonEnd,
                       CHILD_WeightedWidth, 0,
                       CHILD_WeightedHeight, 0,
                     EndGroup, CHILD_WeightedHeight, 0,
                     Label(GetAmiFTPString(MPW_InterfaceFont)),

                     StartHGroup, Spacing(FALSE),
                     StartMember, MPG_List[MPG_FilelistFont]=ButtonObject,
                       GA_ID, MPG_FilelistFont,
                       GA_RelVerify, TRUE,
                       GA_ReadOnly, TRUE,
                       GA_Disabled, MainPrefs.mp_UseDefaultFonts?TRUE:FALSE,
                       GA_Text, listfontname,
                       BUTTON_Justification, BCJ_LEFT,
                       ButtonEnd,

                     StartMember, MPG_List[MPG_FilelistFontB]=ButtonObject,
                       GA_ID, MPG_FilelistFontB,
                       GA_RelVerify, TRUE,
                       GA_Disabled, MainPrefs.mp_UseDefaultFonts?TRUE:FALSE,
                       BUTTON_AutoButton, BAG_POPFONT,
                       ButtonEnd,
                       CHILD_WeightedWidth, 0,
                       CHILD_WeightedHeight, 0,
                     EndGroup, CHILD_WeightedHeight, 0,
                     Label(GetAmiFTPString(MPW_FilelistFont)),

                     StartMember, MPG_List[MPG_ShowButtons]=CheckBoxObject,
                       GA_ID, MPG_ShowButtons,
                       GA_RelVerify, TRUE,
                       GA_Selected, MainPrefs.mp_ShowButtons,
                       GA_Text, GetAmiFTPString(MPW_ShowButtons),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,

                     StartMember, MPG_List[MPG_ToolBar]=CheckBoxObject,
                       GA_ID, MPG_ToolBar,
                       GA_RelVerify, TRUE,
                       GA_Selected, MainPrefs.mp_ShowToolBar,
                       GA_Text, GetAmiFTPString(MPW_ShowToolbar),
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
                   EndGroup, CHILD_WeightedHeight, 0,
                   LayoutEnd, /* End of page 3 */

                   PAGE_Add, VGroupObject, TAligned, /* Start of page 2 proxy */
                     GA_TextAttr, AmiFTPAttrF,
                     StartVGroup, TAligned, 
                     StartMember, MPG_List[MPG_ProxyHost]=StringObject,
                       GA_ID, MPG_ProxyHost,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)buf4,
                       STRINGA_MaxChars, 40,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_ProxyHost)),

                     StartMember, MPG_List[MPG_ProxyPort]=IntegerObject,
                       GA_ID, MPG_ProxyPort,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       INTEGER_Number, MainPrefs.mp_ProxyPort,
                       INTEGER_Arrows,FALSE,
                       INTEGER_MaxChars, 6,
                       IntegerEnd,
                       CHILD_NominalSize, TRUE,
                       CHILD_WeightedWidth, 0,
                       Label(GetAmiFTPString(MPW_ProxyPort)),
                     StartMember, MPG_List[MPG_ProxyDefault]=CheckBoxObject,
                       GA_ID, MPG_ProxyDefault,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_ProxyDefault),
                       GA_Selected, MainPrefs.mp_DefaultProxy,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
                   EndGroup, CHILD_WeightedHeight, 0,
                   LayoutEnd, /* End of page 2 */

                   PAGE_Current, LastPage, PageEnd, /* End of pageobject */
                   LayoutEnd, /* End of layout containing pageobject */

                   LAYOUT_AddImage, BevelObject,
                     BEVEL_Style, BVS_SBAR_VERT,
                   BevelEnd,

                   StartHGroup, EvenSized, LAYOUT_SpaceOuter, TRUE,

                     StartMember, MPG_List[MPG_OK]=ButtonObject, 
                       GA_Text, GetAmiFTPString(MPW_OK),
                       GA_ID, MPG_OK,
                       GA_RelVerify, TRUE,
                     ButtonEnd,
                     CHILD_NominalSize, TRUE,
                     CHILD_WeightedWidth, 0,

                     StartMember, MPG_List[MPG_Cancel]=ButtonObject,
                       GA_Text, GetAmiFTPString(MPW_Cancel),
                       GA_ID, MPG_Cancel,
                       GA_RelVerify, TRUE,
                     ButtonEnd,
                     CHILD_NominalSize, TRUE,
                     CHILD_WeightedWidth, 0,
                   EndGroup,
                   CHILD_WeightMinimum, TRUE,
                   LayoutEnd;

    if (!MainPrefsLayout)
      return NULL;

    SetAttrs(MPG_List[MPG_Page], PAGE_Current, LastPage, TAG_DONE);

    LayoutLimits((struct Gadget *)MainPrefsLayout, &limits, PropFont, Screen);
    limits.MinHeight+=Screen->WBorTop+Screen->WBorBottom;
    limits.MinWidth+=Screen->WBorLeft+Screen->WBorRight;

    MainPrefsWin_Object = WindowObject,
                          WA_Title, GetAmiFTPString(MPW_WinTitle),
                          WA_PubScreen, Screen,
                          WA_DepthGadget, TRUE,
                          WA_DragBar, TRUE,
                          WA_CloseGadget, TRUE,
                          WA_Activate, TRUE,
                          WA_SmartRefresh, TRUE,
                          WA_Top, MainWindow->TopEdge+(MainWindow->Height-limits.MinHeight)/2,
                          WA_Left, MainWindow->LeftEdge+(MainWindow->Width-limits.MinWidth)/2,
                          WA_IDCMP, IDCMP_RAWKEY,
                          WINDOW_ParentGroup, MainPrefsLayout,
                          WINDOW_InterpretUserData, WGUD_FUNC,
                        EndWindow;

    if (!MainPrefsWin_Object)
      return NULL;

    if (MainPrefsWindow=CA_OpenWindow(MainPrefsWin_Object)) {
	return MainPrefsWindow;
    }
    DisposeObject(MainPrefsLayout);
    MainPrefsLayout=NULL;

    return NULL;
}

void UpdateConfig(void)
{
    ULONG attr=0;

    GetAttr(GA_Selected, MPG_List[MPG_ProxyDefault], &attr);
    if (attr!=MainPrefs.mp_DefaultProxy) {
	MainPrefs.mp_DefaultProxy=attr;
	ConfigChanged=TRUE;
    }
	
    GetAttr(GA_Selected, MPG_List[MPG_DisplayBeep], &attr);
    if (attr!=MainPrefs.mp_DisplayBeep) {
	MainPrefs.mp_DisplayBeep=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_DeleteOnExit], &attr);
    if (attr!=MainPrefs.mp_DeleteFiles) {
	MainPrefs.mp_DeleteFiles=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_IgnoreCase], &attr);
    if (attr!=MainPrefs.mp_IgnoreCase) {
	MainPrefs.mp_IgnoreCase=attr;
	ConfigChanged=TRUE;
    }
	
    if (!MainPrefs.mp_AnonymousPW) {
	if(strlen(buf1)) {
	    MainPrefs.mp_AnonymousPW=strdup(buf1);
	    ConfigChanged=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_AnonymousPW, buf1)) {
	    free(MainPrefs.mp_AnonymousPW);
	    MainPrefs.mp_AnonymousPW=NULL;
	    if (strlen(buf1))
	      MainPrefs.mp_AnonymousPW=strdup(buf1);
	    ConfigChanged=TRUE;
	}
    }

    if (!MainPrefs.mp_ViewCommand) {
	if(strlen(buf2)) {
	    MainPrefs.mp_ViewCommand=strdup(buf2);
	    ConfigChanged=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_ViewCommand, buf2)) {
	    free(MainPrefs.mp_ViewCommand);
	    MainPrefs.mp_ViewCommand=NULL;
	    if (strlen(buf2))
	      MainPrefs.mp_ViewCommand=strdup(buf2);
	    ConfigChanged=TRUE;
	}
    }
	
    if (!MainPrefs.mp_LocalDir) {
	if(strlen(buf3)) {
	    MainPrefs.mp_LocalDir=strdup(buf3);
	    ConfigChanged=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_LocalDir, buf3)) {
	    free(MainPrefs.mp_LocalDir);
	    MainPrefs.mp_LocalDir=NULL;
	    if (strlen(buf3))
	      MainPrefs.mp_LocalDir=strdup(buf3);
	    ConfigChanged=TRUE;
	}
    }

    if (!MainPrefs.mp_ProxyServer) {
	if(strlen(buf4)) {
	    MainPrefs.mp_ProxyServer=strdup(buf4);
	    ConfigChanged=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_ProxyServer, buf4)) {
	    free(MainPrefs.mp_ProxyServer);
	    MainPrefs.mp_ProxyServer=NULL;
	    if (strlen(buf4))
	      MainPrefs.mp_ProxyServer=strdup(buf4);
	    ConfigChanged=TRUE;
	}
    }

    GetAttr(INTEGER_Number, MPG_List[MPG_ProxyPort], &attr);
    if (attr!=MainPrefs.mp_ProxyPort) {
	MainPrefs.mp_ProxyPort=attr;
	ConfigChanged=TRUE;
    }

    if (!MainPrefs.mp_HideADTPattern) {
	if(strlen(buf6)) {
	    MainPrefs.mp_HideADTPattern=strdup(buf6);
	    ConfigChanged=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_HideADTPattern, buf6)) {
	    free(MainPrefs.mp_HideADTPattern);
	    MainPrefs.mp_HideADTPattern=NULL;
	    if (strlen(buf6))
	      MainPrefs.mp_HideADTPattern=strdup(buf6);
	    ConfigChanged=TRUE;
	}
    }

    if (!MainPrefs.mp_FontName) {
	MainPrefs.mp_FontName=strdup(intfont);
	MainPrefs.mp_FontSize=intsize;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }
    else {
	if (strecmp(MainPrefs.mp_FontName, intfont) || MainPrefs.mp_FontSize!=intsize) {
	    free(MainPrefs.mp_FontName);
	    MainPrefs.mp_FontName=strdup(intfont);
	    MainPrefs.mp_FontSize=intsize;
	    ConfigChanged=TRUE;
	    MainInterfaceRestart=TRUE;
	}
    }

    if (!MainPrefs.mp_ListFontName) {
	MainPrefs.mp_ListFontName=strdup(listfont);
	MainPrefs.mp_ListFontSize=listsize;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }
    else {
	if (strecmp(MainPrefs.mp_ListFontName, listfont) || MainPrefs.mp_ListFontSize!=listsize) {
	    free(MainPrefs.mp_ListFontName);
	    MainPrefs.mp_ListFontName=strdup(listfont);
	    MainPrefs.mp_ListFontSize=listsize;
	    ConfigChanged=TRUE;
	    MainInterfaceRestart=TRUE;
	}
    }

    GetAttr(GA_Selected, MPG_List[MPG_ShowMOTD], &attr);
    if (attr!=MainPrefs.mp_ShowMOTD) {
	MainPrefs.mp_ShowMOTD=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_GetReadme], &attr);
    if (attr!=MainPrefs.mp_GetReadme) {
	MainPrefs.mp_GetReadme=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(INTEGER_Number, MPG_List[MPG_BufferSize], &attr);
    if (attr!=MainPrefs.mp_BufferSize) {
	MainPrefs.mp_BufferSize=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(INTEGER_Number, MPG_List[MPG_CacheSize], &attr);
    if (attr!=MainPrefs.mp_CacheSize) {
	MainPrefs.mp_CacheSize=attr;
	ConfigChanged=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_DefaultFonts], &attr);
    if (attr!=MainPrefs.mp_UseDefaultFonts) {
	MainPrefs.mp_UseDefaultFonts=attr;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_DefaultScreen], &attr);
    if (attr!=MainPrefs.mp_OpenOnDefaultScreen) {
	MainPrefs.mp_OpenOnDefaultScreen=attr;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_ShowButtons], &attr);
    if (attr!=MainPrefs.mp_ShowButtons) {
	MainPrefs.mp_ShowButtons=attr;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }

    GetAttr(GA_Selected, MPG_List[MPG_ToolBar], &attr);
    if (attr!=MainPrefs.mp_ShowToolBar) {
	MainPrefs.mp_ShowToolBar=attr;
	ConfigChanged=TRUE;
	MainInterfaceRestart=TRUE;
    }

    if (!MainPrefs.mp_PubScreen) {
	if (strlen(pubscreen)) {
	    MainPrefs.mp_PubScreen=strdup(pubscreen);
	    ConfigChanged=TRUE;
	    MainInterfaceRestart=TRUE;
	}
    }
    else {
	if (strecmp(MainPrefs.mp_PubScreen, pubscreen)) {
	    free(MainPrefs.mp_PubScreen);
	    MainPrefs.mp_PubScreen=NULL;
	    if (strlen(pubscreen))
	      MainPrefs.mp_PubScreen=strdup(pubscreen);
	    ConfigChanged=TRUE;
	    MainInterfaceRestart=TRUE;
	}
    }
}

void CloseMainPrefsWindow(void)
{
    if (MainPrefsWin_Object) {
	GetAttrs(MPG_List[MPG_Page], PAGE_Current, &LastPage, TAG_DONE);
	DisposeObject(MainPrefsWin_Object);
	MainPrefsWindow=NULL;
	MainPrefsWin_Object=NULL;
	MainPrefsLayout=NULL;
    }
}

static int SelectFont(char *FontName, UWORD *YSize)
{
    struct FontRequester *FontRequester;
    static ULONG font_tags[]={
	ASL_Window, NULL,
	ASLFO_PrivateIDCMP, TRUE,
	ASLFO_SleepWindow, TRUE,
	ASLFO_TitleText, NULL,
	ASLFO_InitialLeftEdge, NULL,
	ASLFO_InitialTopEdge, NULL,
	ASLFO_InitialName, NULL,
	ASLFO_InitialSize, NULL,
	TAG_END
      };
    int retval=0;

    font_tags[1]=(unsigned long)MainPrefsWindow;
    font_tags[7]=(unsigned long)"Select font...";
    font_tags[9]=MainPrefsWindow->LeftEdge;
    font_tags[11]=MainPrefsWindow->TopEdge;
    font_tags[13]=(ULONG)FontName;
    font_tags[15]=(ULONG)*YSize;

    FontRequester=AllocAslRequest(ASL_FontRequest, NULL);
    if (!FontRequester)
      return 0;

    LockWindow(MainPrefsWin_Object);

    if (AslRequest(FontRequester, (struct TagItem *)font_tags)) {
	strcpy(FontName, FontRequester->fo_Attr.ta_Name);
	*YSize=FontRequester->fo_Attr.ta_YSize;
	retval=1;
    }
    FreeAslRequest(FontRequester);

    UnlockWindow(MainPrefsWin_Object);

    return retval;
}

int BuildClicktabList(void)
{
    struct Node *node;
    int i;

    NewList(&tablist);
    for (i=0; i<4; i++) {
	if (node=(struct Node *)AllocClickTabNode(TNA_Text,GetAmiFTPString(clicktabs[i].String),
						  TNA_Number, i,
//						  TNA_Enabled, clicktabs[i].Enabled,
						  TNA_Spacing, 6,
						  TAG_DONE))
	  AddTail(&tablist, node);
	else
	  return NULL;
    }
    return 1;
}

void FreeClicktabList(struct List *list)
{
    struct Node *node;
    while(node=RemHead(list))
      FreeClickTabNode(node);
}

// EOF
