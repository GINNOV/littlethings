head	1.815;
access;
symbols;
locks
	lilja:1.815; strict;
comment	@ * @;


1.815
date	96.12.14.12.13.03;	author lilja;	state Exp;
branches;
next	1.802;

1.802
date	96.11.30.13.15.06;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.736;

1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
branches;
next	1.720;

1.720
date	96.07.27.23.43.40;	author lilja;	state Exp;
branches;
next	1.711;

1.711
date	96.07.25.00.40.33;	author lilja;	state Exp;
branches;
next	1.710;

1.710
date	96.07.25.00.21.30;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.585;

1.585
date	96.06.13.00.03.21;	author lilja;	state Exp;
branches;
next	1.540;

1.540
date	96.06.01.14.56.20;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.774;

0.774
date	95.10.07.00.18.25;	author lilja;	state Exp;
branches;
next	0.753;

0.753
date	95.09.30.13.35.40;	author lilja;	state Exp;
branches;
next	0.588;

0.588
date	95.09.12.16.24.08;	author lilja;	state Exp;
branches;
next	0.544;

0.544
date	95.09.08.14.11.28;	author lilja;	state Exp;
branches;
next	0.541;

0.541
date	95.09.06.12.36.41;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.348;

0.348
date	95.06.22.18.56.45;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Main Preferences GUI
@


1.815
log
@Fixed the proxy-port settings.
Replaced % with @@ since the proxy actually seems to work with other
ftpproxies.
Fixed the Height/Width save-problem.
@
text
@/* RCS Id: $Id: PrefsWindow.c 1.802 1996/11/30 13:15:06 lilja Exp lilja $
   Locked version: $Revision: 1.802 $
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
    MPG_FilelistFontB, MPG_ShowButtons, MPG_ToolBar,
    MPG_OK, MPG_Cancel,
    NumGadgets_MPG};

struct Gadget *MPG_List[NumGadgets_MPG];

static char buf1[100],buf2[100],buf3[100],buf4[100],buf5[100],buf6[256];
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
    {MPW_Proxy, FALSE}
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
    if (MainPrefs.mp_ViewCommand)
      strcpy(buf2, MainPrefs.mp_ViewCommand);
    if (MainPrefs.mp_LocalDir)
      strcpy(buf3, MainPrefs.mp_LocalDir);
    if (MainPrefs.mp_ProxyServer)
      strcpy(buf4, MainPrefs.mp_ProxyServer);
    if (MainPrefs.mp_HideADTPattern)
      strcpy(buf6, MainPrefs.mp_HideADTPattern);
    if (MainPrefs.mp_PubScreen)
      strcpy(pubscreen, MainPrefs.mp_PubScreen);
    else memset(pubscreen, 0, sizeof(pubscreen));

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
                       STRINGA_MaxChars, 255,
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
@


1.802
log
@DLDir-func is no longer called via UserData, it's called from the
main event-switch. This seems to have solved the problem with
some setups.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
d691 6
@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
a17 1
static void DefDLDir(void);
d158 14
d252 1
a252 1
    else pubscreen[0]=0;
a305 1
                         GA_UserData, (ULONG)DefDLDir,
a820 13
}

static void DefDLDir(void)
{
    char tbuf[255];

    geta4();
    if (DLPath(MainPrefsWin_Object, GetString(MPG_List[MPG_DefaultDLDir]), tbuf)) {
	if (SetGadgetAttrs(MPG_List[MPG_DefaultDLDir], MainPrefsWindow, NULL,
			   STRINGA_TextVal, tbuf, TAG_END))
	  RefreshGList(MPG_List[MPG_DefaultDLDir], MainPrefsWindow, NULL, 1);
    }
    return;
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.720 1996/07/27 23:43:40 lilja Exp lilja $
   Locked version: $Revision: 1.720 $
d27 1
a27 1
    MPG_PublicScreen,
d59 2
a60 2
    {MPW_Proxy, FALSE},
    {MPW_Display, FALSE}
d159 10
d239 1
d397 1
a397 1
                   PAGE_Add, VGroupObject, TAligned, /* Start of page 2 proxy */
a399 8
                     StartMember, MPG_List[MPG_ProxyHost]=StringObject,
                       GA_ID, MPG_ProxyHost,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, (ULONG)buf4,
                       STRINGA_MaxChars, 40,
                       StringEnd,
                       Label(GetAmiFTPString(MPW_ProxyHost)),
d401 2
a402 13
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
d404 2
a405 2
                       GA_Text, GetAmiFTPString(MPW_ProxyDefault),
                       GA_Selected, MainPrefs.mp_DefaultProxy,
a408 6
                   EndGroup, CHILD_WeightedHeight, 0,
                   LayoutEnd, /* End of page 2 */

                   PAGE_Add, VGroupObject, TAligned, /* Start of page 3 display */
                     GA_TextAttr, AmiFTPAttrF,
                     StartVGroup, TAligned, 
d412 1
d418 1
a418 1
                       Label("Public screen"),
d424 1
a424 1
                       GA_Text, "Use system fonts",
d448 1
a448 1
                     Label("Interface font"),
d469 1
a469 1
                     Label("Filelist font"),
d475 1
a475 1
                       GA_Text, "Show buttons",
d484 1
a484 1
                       GA_Text, "Show toolbar",
d491 34
d760 7
d874 1
a874 1
						  TNA_Enabled, clicktabs[i].Enabled,
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.711 1996/07/25 00:40:33 lilja Exp lilja $
   Locked version: $Revision: 1.711 $
d27 1
d36 2
d227 2
d424 9
d751 18
@


1.711
log
@Different fonts works now. Use GA_TextAttr in every PAGE_Add.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Locked version: $Revision: 1.710 $
d15 2
d48 12
d64 1
d67 3
a69 46
    {
	struct Node *node;

	NewList(&tablist);
	if (node=(struct Node *)AllocClickTabNode(TNA_Text, GetAmiFTPString(MPW_General),
						  TNA_Number, 0,
						  TNA_Enabled, TRUE,
						  TNA_Spacing, 6,
						  TAG_DONE))
	  AddTail(&tablist, node);
	else
	  return NULL;
	if (node=(struct Node *)AllocClickTabNode(TNA_Text, GetAmiFTPString(MPW_ADT),
						  TNA_Number, 1,
						  TNA_Enabled, FALSE,
						  TNA_Spacing, 6,
						  TAG_DONE))
	  AddTail(&tablist, node);
	else {
	    FreeClickTabNode(FirstNode(&tablist));
	    return NULL;
	}
	if (node=(struct Node *)AllocClickTabNode(TNA_Text, GetAmiFTPString(MPW_Proxy),
						  TNA_Number, 2,
						  TNA_Enabled, FALSE,
						  TNA_Spacing, 6,
						  TAG_DONE))
	  AddTail(&tablist, node);
	else {
	    FreeClickTabNode(RemHead(&tablist));
	    FreeClickTabNode(RemHead(&tablist));
	    return NULL;
	}

	if (node=(struct Node *)AllocClickTabNode(TNA_Text, "Display",
						  TNA_Number, 3,
						  TNA_Enabled, FALSE,
						  TNA_Spacing, 6,
						  TAG_DONE))
	  AddTail(&tablist, node);
	else {
	    FreeClickTabNode(RemHead(&tablist));
	    FreeClickTabNode(RemHead(&tablist));
	    FreeClickTabNode(RemHead(&tablist));
	    return NULL;
	}
d103 2
a104 6
    {
	struct Node *node;
	while(node=RemHead(&tablist)) {
	    FreeClickTabNode(node);
	}
    }
d208 2
a209 2
    sprintf(intfontname,"%s/%ld", intfont, intsize);
    sprintf(listfontname,"%s/%ld", listfont, listsize);
d215 1
a215 1
      strcpy(buf1,MainPrefs.mp_AnonymousPW);
d217 1
a217 1
      strcpy(buf2,MainPrefs.mp_ViewCommand);
d219 1
a219 1
      strcpy(buf3,MainPrefs.mp_LocalDir);
d221 1
a221 1
      strcpy(buf4,MainPrefs.mp_ProxyServer);
d223 1
a223 1
      strcpy(buf6,MainPrefs.mp_HideADTPattern);
d753 1
a753 13
    struct FileRequester *DirRequester;
    static ULONG dlpath_tags[]={
	ASL_Window, NULL,
	ASLFR_PrivateIDCMP, TRUE,
	ASLFR_SleepWindow, TRUE,
	ASLFR_InitialDrawer, NULL,
	ASLFR_DrawersOnly, TRUE,
	ASLFR_RejectIcons, TRUE,
	ASLFR_TitleText, NULL,
	ASLFR_InitialLeftEdge, NULL,
	ASLFR_InitialTopEdge, NULL,
	TAG_END
      };
d756 1
a756 14

    dlpath_tags[1]=(unsigned long)MainPrefsWindow;
    dlpath_tags[7]=(unsigned long)GetString(MPG_List[MPG_DefaultDLDir]);
    dlpath_tags[13]=(unsigned long)GetAmiFTPString(Str_SelectDLPath);
    dlpath_tags[15]=MainPrefsWindow->LeftEdge;
    dlpath_tags[17]=MainPrefsWindow->TopEdge;

    DirRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!DirRequester)
      return;

    LockWindow(MainPrefsWin_Object);

    if (AslRequest(DirRequester, (struct TagItem *)dlpath_tags)) {
d758 1
a758 1
			   STRINGA_TextVal, DirRequester->rf_Dir, TAG_END))
a760 4
    FreeAslRequest(DirRequester);

    UnlockWindow(MainPrefsWin_Object);

d803 26
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d274 1
d373 1
d414 1
d447 2
a448 1
                   PAGE_Add, VGroupObject, TAligned, /* Start of page 3 proxy */
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d17 1
a17 1
static void SelectFont(void);
d25 1
a25 1
    MPG_InterfaceFont, MPG_InterfaceFontB, MPG_FilelistFont, 
d39 7
d54 1
d171 30
a200 1
		SelectFont();
a217 3
static char intfontname[40];
static char listfontname[40];

d222 20
a241 2
    sprintf(intfontname,"%s/%ld", AmiFTPAttrF->ta_Name, AmiFTPAttrF->ta_YSize);
    sprintf(intfontname,"%s/%ld", ListViewAttrF->ta_Name, ListViewAttrF->ta_YSize);
d446 10
d461 1
d469 1
d482 2
a483 1
                       GA_Text, "XEN/8",
d490 1
d690 32
d746 7
d821 1
a821 1
static void SelectFont(void)
d826 7
a832 5
	ASLFR_PrivateIDCMP, TRUE,
	ASLFR_SleepWindow, TRUE,
	ASLFR_TitleText, NULL,
	ASLFR_InitialLeftEdge, NULL,
	ASLFR_InitialTopEdge, NULL,
d835 1
d838 1
a838 1
    font_tags[7]=(unsigned long)GetString(MPG_List[MPG_DefaultDLDir]);
d841 2
d846 1
a846 1
      return;
d851 3
a853 5
	kprintf("Font %s/%ld selected.\n", FontRequester->fo_Attr.ta_Name,
		FontRequester->fo_Attr.ta_YSize);
/*	if (SetGadgetAttrs(MPG_List[MPG_DefaultDLDir], MainPrefsWindow, NULL,
			   STRINGA_TextVal, DirRequester->rf_Dir, TAG_END))
	  RefreshGList(MPG_List[MPG_DefaultDLDir], MainPrefsWindow, NULL, 1);*/
d859 1
a859 1
    return;
d861 2
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@d1 2
a2 2
/* RCS Id: $Id: PrefsWindow.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d17 1
d24 4
a27 2
    MPG_ADTPattern, MPG_PreserveDir, MPG_ShowMOTD, MPG_GetReadme, MPG_OK,
    MPG_Cancel,
d36 2
d43 1
d77 13
d117 6
d162 3
d181 2
d188 3
d216 1
a216 1
                          CLICKTAB_Current, 0L,
d392 61
a452 1
                   PageEnd, /* End of pageobject */
d483 2
d648 13
d666 1
d710 38
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
d42 4
a45 4
	if (node=(struct Node *)AllocClickTabNode(TNA_Text,GetAmiFTPString(MPW_General),
						  TNA_Number,0,
						  TNA_Enabled,TRUE,
						  TNA_Spacing,6,
d47 1
a47 1
	  AddTail(&tablist,node);
d50 4
a53 4
	if (node=(struct Node *)AllocClickTabNode(TNA_Text,GetAmiFTPString(MPW_ADT),
						  TNA_Number,1,
						  TNA_Enabled,FALSE,
						  TNA_Spacing,6,
d55 1
a55 1
	  AddTail(&tablist,node);
d60 4
a63 4
	if (node=(struct Node *)AllocClickTabNode(TNA_Text,GetAmiFTPString(MPW_Proxy),
						  TNA_Number,2,
						  TNA_Enabled,FALSE,
						  TNA_Spacing,6,
d65 1
a65 1
	  AddTail(&tablist,node);
d82 1
a82 1
    GetAttr(WINDOW_SigMask, MainWin_Object,&mainwinsignal);
a106 1

d112 1
a112 1
    while ((result=CA_HandleInput(MainPrefsWin_Object,&code))!=WMHI_LASTMSG) {
d128 2
a129 2
		  GetAttrs(MPG_List[MPG_Tab],CLICKTAB_Current, &tabnum,TAG_DONE);
		  GetAttrs(MPG_List[MPG_Page], PAGE_Current, &pagenum,TAG_DONE);
d131 2
a132 2
		      SetGadgetAttrs(MPG_List[MPG_Page],MainPrefsWindow,NULL,
				     PAGE_Current, tabnum,TAG_DONE);
d180 1
a180 1
                          GA_ID,MPG_Tab,
d195 2
a196 2
                       GA_TabCycle,TRUE,
                       STRINGA_Buffer,(ULONG)buf1,
d204 2
a205 2
                       GA_TabCycle,TRUE,
                       STRINGA_Buffer,(ULONG)buf2,
d215 2
a216 2
                         GA_TabCycle,TRUE,
                         STRINGA_Buffer,(ULONG)buf3,
d226 2
a227 2
                         CHILD_WeightedWidth,0,
                         CHILD_WeightedHeight,0,
d234 2
a235 2
                       GA_TabCycle,TRUE,
                       INTEGER_Minimum,512,
d237 1
a237 1
                       INTEGER_MaxChars,8,
d239 2
a240 2
//                       CHILD_NominalSize,TRUE,
//                       CHILD_WeightedWidth,0,
d246 1
a246 1
                       GA_TabCycle,TRUE,
d249 2
a250 2
                       INTEGER_Maximum,10,
                       INTEGER_MaxChars,6,
d261 1
a261 1
                       GA_Text,GetAmiFTPString(MPW_DeleteViewed),
d279 1
a279 1
                       GA_Text,GetAmiFTPString(MPW_Beep),
d283 1
a283 1
                     EndGroup,EndGroup,CHILD_WeightedWidth,0,
d291 2
a292 2
                       GA_TabCycle,TRUE,
                       STRINGA_Buffer,(ULONG)buf6,
d323 1
a323 1
                   EndGroup, CHILD_WeightedHeight,0,
d331 2
a332 2
                       GA_TabCycle,TRUE,
                       STRINGA_Buffer,(ULONG)buf4,
d340 1
a340 1
                       GA_TabCycle,TRUE,
d343 1
a343 1
                       INTEGER_MaxChars,6,
d345 2
a346 2
                       CHILD_NominalSize,TRUE,
                       CHILD_WeightedWidth,0,
d351 1
a351 1
                       GA_Text,GetAmiFTPString(MPW_ProxyDefault),
d356 1
a356 1
                   EndGroup, CHILD_WeightedHeight,0,
a384 1

d390 1
a390 1
    LayoutLimits((struct Gadget *)MainPrefsLayout,&limits,PropFont,Screen);
d396 1
a396 1
                          WA_PubScreen,Screen,
d425 1
a425 1
    GetAttr(GA_Selected,MPG_List[MPG_ProxyDefault],&attr);
d431 1
a431 1
    GetAttr(GA_Selected,MPG_List[MPG_DisplayBeep],&attr);
d437 1
a437 1
    GetAttr(GA_Selected,MPG_List[MPG_DeleteOnExit],&attr);
d443 1
a443 1
    GetAttr(GA_Selected,MPG_List[MPG_IgnoreCase],&attr);
d456 1
a456 1
	if (strecmp(MainPrefs.mp_AnonymousPW,buf1)) {
d472 1
a472 1
	if (strecmp(MainPrefs.mp_ViewCommand,buf2)) {
d488 1
a488 1
	if (strecmp(MainPrefs.mp_LocalDir,buf3)) {
d504 1
a504 1
	if (strecmp(MainPrefs.mp_ProxyServer,buf4)) {
d520 1
a520 1
	if (strecmp(MainPrefs.mp_HideADTPattern,buf6)) {
d529 1
a529 1
    GetAttr(GA_Selected,MPG_List[MPG_ShowMOTD],&attr);
d569 9
a577 9
	ASL_Window,NULL,
	ASLFR_PrivateIDCMP,TRUE,
	ASLFR_SleepWindow,TRUE,
	ASLFR_InitialDrawer,NULL,
	ASLFR_DrawersOnly,TRUE,
	ASLFR_RejectIcons,TRUE,
	ASLFR_TitleText,NULL,
	ASLFR_InitialLeftEdge,NULL,
	ASLFR_InitialTopEdge,NULL,
d589 1
a589 1
    DirRequester=AllocAslRequest(ASL_FileRequest,NULL);
d595 4
a598 4
    if (AslRequest(DirRequester,(struct TagItem *)dlpath_tags)) {
	if (SetGadgetAttrs(MPG_List[MPG_DefaultDLDir],MainPrefsWindow,NULL,
			   STRINGA_TextVal,DirRequester->rf_Dir,TAG_END))
	  RefreshGList(MPG_List[MPG_DefaultDLDir],MainPrefsWindow,NULL,1);
@


1.585
log
@Changed the parsing of the command line site.
ESC now closes all windows but connect- and transferwindow.
RETURN connects to the current site.
Using the Exec-list functions/macros.
New windowtitle, now with # of files selected and more.
@
text
@d1 4
@


1.540
log
@GetReadme wasn't read properly from the gadget.
@
text
@d53 1
a53 1
	    FreeClickTabNode(GetHead(&tablist));
d114 6
d402 1
a404 2
                          WINDOW_IDCMPHook,&IDCMPHook,
                          WINDOW_IDCMPHookBits,IDCMP_RAWKEY,
@


1.531
log
@Lots of stuff
@
text
@d528 1
a528 1
    GetAttr(INTEGER_Number, MPG_List[MPG_GetReadme], &attr);
@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d10 1
d19 2
a20 1
    MPG_ADTPattern, MPG_PreserveDir, MPG_ShowMOTD, MPG_GetReadme,
d128 9
d167 1
a167 1
                     LAYOUT_SpaceOuter, TRUE,
d177 1
a177 1
                     LAYOUT_AddChild,pagelayout=LayoutObject,
d277 2
a278 3
                   PAGE_Add, LayoutObject, /* Start of page 1 ADT */
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                     LAYOUT_SpaceInner, TRUE, LAYOUT_ShrinkWrap, TRUE,
d291 1
d309 1
d314 1
a315 1
                   CHILD_WeightedHeight,0,
d317 2
a318 3
                   PAGE_Add, LayoutObject, /* Start of page 2 proxy */
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                     LAYOUT_HorizAlignment, LALIGN_RIGHT,
d347 2
a348 2

                   LayoutEnd,CHILD_WeightMinimum,TRUE, /* End of page 2 */
d352 25
d414 1
a414 1
void CloseMainPrefsWindow(void)
d418 17
a434 6
    if (MainPrefsWin_Object) {
	GetAttr(GA_Selected,MPG_List[MPG_ProxyDefault],&attr);
	if (attr!=MainPrefs.mp_DefaultProxy) {
	    MainPrefs.mp_DefaultProxy=attr;
	    ConfigChanged=TRUE;
	}
d436 9
a444 3
	GetAttr(GA_Selected,MPG_List[MPG_DisplayBeep],&attr);
	if (attr!=MainPrefs.mp_DisplayBeep) {
	    MainPrefs.mp_DisplayBeep=attr;
d447 7
a453 4

	GetAttr(GA_Selected,MPG_List[MPG_ShowMOTD],&attr);
	if (attr!=MainPrefs.mp_ShowMOTD) {
	    MainPrefs.mp_ShowMOTD=attr;
d456 1
d458 3
a460 3
	GetAttr(GA_Selected,MPG_List[MPG_DeleteOnExit],&attr);
	if (attr!=MainPrefs.mp_DeleteFiles) {
	    MainPrefs.mp_DeleteFiles=attr;
d463 7
a469 4

	GetAttr(GA_Selected,MPG_List[MPG_IgnoreCase],&attr);
	if (attr!=MainPrefs.mp_IgnoreCase) {
	    MainPrefs.mp_IgnoreCase=attr;
d472 1
d474 4
a477 5
	if (!MainPrefs.mp_AnonymousPW) {
	    if(strlen(buf1)) {
		MainPrefs.mp_AnonymousPW=strdup(buf1);
		ConfigChanged=TRUE;
	    }
d479 8
a486 8
	else {
	    if (strecmp(MainPrefs.mp_AnonymousPW,buf1)) {
		free(MainPrefs.mp_AnonymousPW);
		MainPrefs.mp_AnonymousPW=NULL;
		if (strlen(buf1))
		  MainPrefs.mp_AnonymousPW=strdup(buf1);
		ConfigChanged=TRUE;
	    }
d488 1
d490 4
a493 5
	if (!MainPrefs.mp_ViewCommand) {
	    if(strlen(buf2)) {
		MainPrefs.mp_ViewCommand=strdup(buf2);
		ConfigChanged=TRUE;
	    }
d495 8
a502 8
	else {
	    if (strecmp(MainPrefs.mp_ViewCommand,buf2)) {
		free(MainPrefs.mp_ViewCommand);
		MainPrefs.mp_ViewCommand=NULL;
		if (strlen(buf2))
		  MainPrefs.mp_ViewCommand=strdup(buf2);
		ConfigChanged=TRUE;
	    }
d504 6
a509 6
	
	if (!MainPrefs.mp_LocalDir) {
	    if(strlen(buf3)) {
		MainPrefs.mp_LocalDir=strdup(buf3);
		ConfigChanged=TRUE;
	    }
d511 8
a518 8
	else {
	    if (strecmp(MainPrefs.mp_LocalDir,buf3)) {
		free(MainPrefs.mp_LocalDir);
		MainPrefs.mp_LocalDir=NULL;
		if (strlen(buf3))
		  MainPrefs.mp_LocalDir=strdup(buf3);
		ConfigChanged=TRUE;
	    }
d520 1
d522 5
a526 15
	if (!MainPrefs.mp_ProxyServer) {
	    if(strlen(buf4)) {
		MainPrefs.mp_ProxyServer=strdup(buf4);
		ConfigChanged=TRUE;
	    }
	}
	else {
	    if (strecmp(MainPrefs.mp_ProxyServer,buf4)) {
		free(MainPrefs.mp_ProxyServer);
		MainPrefs.mp_ProxyServer=NULL;
		if (strlen(buf4))
		  MainPrefs.mp_ProxyServer=strdup(buf4);
		ConfigChanged=TRUE;
	    }
	}
d528 5
a532 15
	if (!MainPrefs.mp_HideADTPattern) {
	    if(strlen(buf6)) {
		MainPrefs.mp_HideADTPattern=strdup(buf6);
		ConfigChanged=TRUE;
	    }
	}
	else {
	    if (strecmp(MainPrefs.mp_HideADTPattern,buf6)) {
		free(MainPrefs.mp_HideADTPattern);
		MainPrefs.mp_HideADTPattern=NULL;
		if (strlen(buf6))
		  MainPrefs.mp_HideADTPattern=strdup(buf6);
		ConfigChanged=TRUE;
	    }
	}
d534 5
a538 5
	GetAttr(INTEGER_Number, MPG_List[MPG_ProxyPort], &attr);
	if (attr!=MainPrefs.mp_ProxyPort) {
	    MainPrefs.mp_ProxyPort=attr;
	    ConfigChanged=TRUE;
	}
d540 5
a544 5
	GetAttr(INTEGER_Number, MPG_List[MPG_BufferSize], &attr);
	if (attr!=MainPrefs.mp_BufferSize) {
	    MainPrefs.mp_BufferSize=attr;
	    ConfigChanged=TRUE;
	}
d546 1
a546 5
	GetAttr(INTEGER_Number, MPG_List[MPG_CacheSize], &attr);
	if (attr!=MainPrefs.mp_CacheSize) {
	    MainPrefs.mp_CacheSize=attr;
	    ConfigChanged=TRUE;
	}
d548 3
@


1.200
log
@GETATTR-hit fixed.
@
text
@d14 5
a18 2
    MPG_AnonymousPW=0, MPG_ViewCommand, MPG_DefaultDLDir, MPG_DefaultDLDirGad, MPG_ProxyHost,
    MPG_ProxyPort, MPG_ProxyDefault, MPG_IgnoreCase,
d23 1
a23 1
static char buf1[100],buf2[100],buf3[100],buf4[100],buf5[100];
d25 2
d33 41
a73 2
    if (!OpenMainPrefsWindow())
      return 0;
d77 1
d91 7
d112 16
d149 2
d158 12
d171 1
a171 2
//                     LAYOUT_BevelStyle,BVS_THIN,

d211 97
d313 1
a313 1
                       STRINGA_MaxChars, 50,
a327 1

d337 4
a340 17
/*                     StartMember, MPG_List[MPG_DotFiles]=CheckBoxObject,
                       GA_ID, MPG_DotFiles,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_ShowDots),
                       GA_Selected, MainPrefs.mp_Showdotfiles,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
*/
                     StartMember, MPG_List[MPG_IgnoreCase]=CheckBoxObject,
                       GA_ID, MPG_IgnoreCase,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(MPW_IgnoreCase),
                       GA_Selected, MainPrefs.mp_IgnoreCase,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,
                       CHILD_WeightMinimum, TRUE,
d389 9
a397 3
/*	GetAttr(GA_Selected,MPG_List[MPG_DotFiles],&attr);
	if (attr!=MainPrefs.mp_Showdotfiles) {
	    MainPrefs.mp_Showdotfiles=attr;
d400 7
a406 1
*/
d477 16
d496 12
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@a22 10
int strecmp(char *s1, char *s2)
{
	int n1, n2;

	if((n1 = strlen(s1)) == (n2 = strlen(s2)))
		return(strnicmp(s1, s2, n1));
	else
		return(n1 < n2 ? -1 : 1);
}

d29 1
a29 1
      return (0);
d46 1
a46 1
    return (1);
d62 1
a62 1
    return (done);
d71 1
a71 1
      return (MainPrefsWindow);
d180 1
a180 1
      return (NULL);
d203 1
a203 1
      return (NULL);
d206 1
a206 1
	return (MainPrefsWindow);
d211 1
a211 1
    return (NULL);
@


1.124
log
@AmiTCP and AS225r2 support in the same binary.
ARexx-command VIEW added.
New option to SETATTR, QUIET.
SETATTR LOCALDIR didn't update the download dir-gadget.
GETATTR STEM=bar didn't work since bar is in lowercase.
Enforcer hits when trying to open AmiFTP on a non-existing screen removed.
Moved 'Show dot-files?' to the Settings-menu.
Icelandic and Spanish catalogs added.
@
text
@a338 1
    APTR wlock;
d352 1
a352 1
    wlock=rtLockWindow(MainPrefsWindow);
d361 1
a361 1
    rtUnlockWindow(MainPrefsWindow,wlock);
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d15 1
a15 1
    MPG_ProxyPort, MPG_ProxyDefault, MPG_DotFiles, MPG_IgnoreCase,
d94 1
d170 1
a170 1
                     StartMember, MPG_List[MPG_DotFiles]=CheckBoxObject,
d178 1
a178 1

d192 1
a192 1
    LayoutLimits((struct Gadget *)MainPrefsLayout,&limits,ScreenFont,Screen);
d235 1
a235 1
	GetAttr(GA_Selected,MPG_List[MPG_DotFiles],&attr);
d240 1
a240 1

a321 2
    if (ScreenFont)
      CloseFont(ScreenFont);
@


0.814
log
@Added default download-dir.
@
text
@d4 3
a6 2
enum {PR_PASSWORD=0,PR_VIEWCMD,PR_SHOWDOTS,PR_PROXYGAD,PR_PROXYPGAD,PR_DEFPROXY,PR_DEFDLDIR,PR_IGNORECASE,
	NumGadgets_pr};
d8 2
a9 1
struct Gadget *pr_Gadgets[NumGadgets_pr];
d11 1
a11 1
extern char www[];
d13 4
a16 10
struct NewGadget pr_NewGadgets[]={
    {0,0,0,0,NULL,NULL,0,PLACETEXT_LEFT,NULL,NULL},   /* Anonymous Password */
    {0,0,0,0,NULL,NULL,6,PLACETEXT_LEFT,NULL,NULL},   /* Viewcommand */
    {0,0,0,0,NULL,NULL,1,PLACETEXT_LEFT,NULL,NULL},   /* Show dot-files */
    {0,0,0,0,NULL,NULL,2,PLACETEXT_LEFT,NULL,NULL},   /* Proxy host */
    {0,0,0,0,NULL,NULL,3,PLACETEXT_LEFT,NULL,NULL},   /* Proxy port */
    {0,0,0,0,NULL,NULL,4,PLACETEXT_LEFT,NULL,NULL},   /* Use proxy as default */
    {0,0,0,0,NULL,NULL,5,PLACETEXT_LEFT,NULL,NULL}, /* Def.download dir */
    {0,0,0,0,NULL,NULL,7,PLACETEXT_LEFT,NULL,NULL}    /* Ignore case */
};
d18 16
a33 1
LONG pr_GadgetLabels[]=
d35 8
a42 64
    (LONG)MPW_Password,
    (LONG)MPW_ViewCommand,
    (LONG)MPW_ShowDots,
    (LONG)MPW_ProxyHost,
    (LONG)MPW_ProxyPort,
    (LONG)MPW_ProxyDefault,
    (LONG)MPW_DefDownloadDir,
    (LONG)MPW_IgnoreCase,
    -1
};

ULONG pr_tags[]={
    /* Password */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* Viewcommand */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* Showdots */
    GTCB_Checked,NULL,
    GTCB_Scaled,TRUE,
    GT_Underscore,'_',
    TAG_END,
    /* Proxyhost */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* Proxyport */
    GTIN_Number,21,
    GTIN_MaxChars,6,
    GT_Underscore,'_',
    TAG_END,
    /* Defproxy */
    GTCB_Checked,NULL,
    GTCB_Scaled,TRUE,
    GT_Underscore,'_',
    TAG_END,
    /* DefDLDir */
    GA_TabCycle,TRUE,
    GT_Underscore,'_',
    GTST_MaxChars,100,
    TAG_END,
    /* IgnoreCase */
    GTCB_Checked,NULL,
    GTCB_Scaled,TRUE,
    GT_Underscore,'_',
    TAG_END
};

ULONG pr_types[]={
    STRING_KIND,   /* Password */
    STRING_KIND,   /* Viewcommand */
    CHECKBOX_KIND, /* Showdots */
    STRING_KIND,   /* Proxyhost */
    INTEGER_KIND,  /* Proxyport */
    CHECKBOX_KIND, /* Defproxy */
    STRING_KIND,   /* Defdldir */
    CHECKBOX_KIND  /* IgnoreCase */
};
d44 10
d55 3
a57 2
struct Gadget *pr_glist;
struct Window *pr_Win;
a58 1
static char pr_FastKeys[NumGadgets_pr+1];
d60 1
a60 1
void ComputeSize_pr(UWORD *minwidth,UWORD *minheight)
d62 11
a72 62
    int i;
    long n1,n2;
    n1=GadgetTextLength(PropRPort,pr_NewGadgets[PR_PASSWORD]);
    n2=GadgetTextLength(PropRPort,pr_NewGadgets[PR_VIEWCMD]);
    n1=max(n1,n2);
    n2=GadgetTextLength(PropRPort,pr_NewGadgets[PR_DEFDLDIR]);
    n1=max(n1,n2);
    n2=GadgetTextLength(PropRPort,pr_NewGadgets[PR_PROXYGAD]);
    n1=max(n1,n2);
    pr_NewGadgets[PR_PASSWORD].ng_Width=TextLength(PropRPort,www,20);
    pr_NewGadgets[PR_PASSWORD].ng_Height=PropFHigh+2*INTERHEIGHT;
    pr_NewGadgets[PR_PASSWORD].ng_TopEdge=INTERHEIGHT/2+INTERHEIGHT;
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=2*INTERWIDTH+n1;
    
    pr_NewGadgets[PR_VIEWCMD].ng_TopEdge=pr_NewGadgets[PR_PASSWORD].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_PASSWORD].ng_Height;
    pr_NewGadgets[PR_VIEWCMD].ng_LeftEdge=pr_NewGadgets[PR_PASSWORD].ng_LeftEdge;
    pr_NewGadgets[PR_VIEWCMD].ng_Width=pr_NewGadgets[PR_PASSWORD].ng_Width;
    pr_NewGadgets[PR_VIEWCMD].ng_Height=PropFHigh+2*INTERHEIGHT;

    pr_NewGadgets[PR_DEFDLDIR].ng_TopEdge=pr_NewGadgets[PR_VIEWCMD].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_VIEWCMD].ng_Height;
    pr_NewGadgets[PR_DEFDLDIR].ng_LeftEdge=pr_NewGadgets[PR_VIEWCMD].ng_LeftEdge;
    pr_NewGadgets[PR_DEFDLDIR].ng_Width=pr_NewGadgets[PR_VIEWCMD].ng_Width;
    pr_NewGadgets[PR_DEFDLDIR].ng_Height=PropFHigh+2*INTERHEIGHT;

    pr_NewGadgets[PR_PROXYGAD].ng_Height=PropFHigh+2*INTERHEIGHT;
    pr_NewGadgets[PR_PROXYGAD].ng_Width=pr_NewGadgets[PR_DEFDLDIR].ng_Width;
    pr_NewGadgets[PR_PROXYGAD].ng_LeftEdge=pr_NewGadgets[PR_DEFDLDIR].ng_LeftEdge;
    pr_NewGadgets[PR_PROXYGAD].ng_TopEdge=pr_NewGadgets[PR_DEFDLDIR].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_DEFDLDIR].ng_Height;

    pr_NewGadgets[PR_PROXYPGAD].ng_Height=pr_NewGadgets[PR_PROXYGAD].ng_Height;
    pr_NewGadgets[PR_PROXYPGAD].ng_Width=2*INTERWIDTH+TextLength(PropRPort,www,6);
    pr_NewGadgets[PR_PROXYPGAD].ng_LeftEdge=pr_NewGadgets[PR_PROXYGAD].ng_LeftEdge+pr_NewGadgets[PR_PROXYGAD].ng_Width-pr_NewGadgets[PR_PROXYPGAD].ng_Width;
    pr_NewGadgets[PR_PROXYPGAD].ng_TopEdge=pr_NewGadgets[PR_PROXYGAD].ng_TopEdge+pr_NewGadgets[PR_PROXYPGAD].ng_Height+INTERHEIGHT;

    pr_NewGadgets[PR_DEFPROXY].ng_TopEdge=pr_NewGadgets[PR_PROXYPGAD].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_PROXYPGAD].ng_Height;
    pr_NewGadgets[PR_DEFPROXY].ng_Width=2*PropFHigh+INTERWIDTH;
    pr_NewGadgets[PR_DEFPROXY].ng_LeftEdge=pr_NewGadgets[PR_PROXYPGAD].ng_LeftEdge+pr_NewGadgets[PR_DEFPROXY].ng_Width-pr_NewGadgets[PR_DEFPROXY].ng_Width;
    pr_NewGadgets[PR_DEFPROXY].ng_Height=PropFHigh+INTERHEIGHT;

    pr_NewGadgets[PR_SHOWDOTS].ng_Width=2*PropFHigh+INTERWIDTH;
    pr_NewGadgets[PR_SHOWDOTS].ng_Height=PropFHigh+INTERHEIGHT;
    pr_NewGadgets[PR_SHOWDOTS].ng_TopEdge=pr_NewGadgets[PR_DEFPROXY].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_DEFPROXY].ng_Height;
    pr_NewGadgets[PR_SHOWDOTS].ng_LeftEdge=pr_NewGadgets[PR_DEFPROXY].ng_LeftEdge;

    pr_NewGadgets[PR_IGNORECASE].ng_Width=2*PropFHigh+INTERWIDTH;
    pr_NewGadgets[PR_IGNORECASE].ng_Height=PropFHigh+INTERHEIGHT;
    pr_NewGadgets[PR_IGNORECASE].ng_TopEdge=pr_NewGadgets[PR_SHOWDOTS].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_SHOWDOTS].ng_Height;
    pr_NewGadgets[PR_IGNORECASE].ng_LeftEdge=pr_NewGadgets[PR_DEFPROXY].ng_LeftEdge;

    pr_FastKeys[PR_PASSWORD] = FindVanillaKey(pr_NewGadgets[PR_PASSWORD].ng_GadgetText);
    pr_FastKeys[PR_VIEWCMD]  = FindVanillaKey(pr_NewGadgets[PR_VIEWCMD].ng_GadgetText);
    pr_FastKeys[PR_PROXYGAD] = FindVanillaKey(pr_NewGadgets[PR_PROXYGAD].ng_GadgetText);
    pr_FastKeys[PR_PROXYPGAD] = FindVanillaKey(pr_NewGadgets[PR_PROXYPGAD].ng_GadgetText);
    pr_FastKeys[PR_DEFPROXY] = FindVanillaKey(pr_NewGadgets[PR_DEFPROXY].ng_GadgetText);
    pr_FastKeys[PR_SHOWDOTS] = FindVanillaKey(pr_NewGadgets[PR_SHOWDOTS].ng_GadgetText);
    pr_FastKeys[PR_IGNORECASE] = FindVanillaKey(pr_NewGadgets[PR_IGNORECASE].ng_GadgetText);
    pr_FastKeys[PR_DEFDLDIR] = FindVanillaKey(pr_NewGadgets[PR_DEFDLDIR].ng_GadgetText);
    for (i=0;i<NumGadgets_pr;i++)
      if (!pr_FastKeys[i])
	pr_FastKeys[i]=-1;
    *minwidth=INTERWIDTH+pr_NewGadgets[PR_PASSWORD].ng_Width+pr_NewGadgets[PR_PASSWORD].ng_LeftEdge;
    *minheight=pr_NewGadgets[PR_IGNORECASE].ng_TopEdge+pr_NewGadgets[PR_IGNORECASE].ng_Height+INTERHEIGHT/2;
d75 2
a76 1
int OpenPrefsWindow()
d78 4
a81 34
    UWORD Width,Height;
    struct Gadget *gad;
    struct IntuiMessage *imsg;
    BOOL Continue=TRUE;
    BOOL PWChanged=FALSE;
    BOOL PRChanged=FALSE;
    BOOL VCChanged=FALSE;
    BOOL DefDLDirChanged=FALSE;
    ULONG mask,winmask;
    ComputeSize_pr(&Width,&Height);

    pr_Win = OpenWindowTags(NULL,
			    WA_PubScreen,myScn,
			    WA_Top,mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge,
			    WA_Left,mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge,
			    WA_Width,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_InnerHeight,Height,
			    WA_Width,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_Height,Height+myScn->WBorTop+myScn->WBorBottom,
			    WA_Title,GetAmiFTPString(MPW_WinTitle),
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|IDCMP_VANILLAKEY|IDCMP_GADGETHELP|IDCMP_RAWKEY,
			    WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
			    TAG_DONE
			    );
    if (!pr_Win)
      return(1);

    SetFont(pr_Win->RPort,Propdfont);
    gad = CreateContext(&pr_glist);
    if (!gad) {
	StripIntuiMessages(pr_Win->UserPort,pr_Win);
	CloseWindow(pr_Win);
	return(2);
    }
a82 9
    if (!(Layout(&gad,pr_Win,&pr_NewGadgets[0],&pr_tags[0],&pr_types[0],&pr_Gadgets[0],NumGadgets_pr))) {
	StripIntuiMessages(pr_Win->UserPort,pr_Win);
	CloseWindow(pr_Win);
	FreeGadgets(pr_glist);
	return(3);
    }
    AddGList(pr_Win,pr_glist,~0,-1,NULL);
    RefreshGList(pr_Win->FirstGadget,pr_Win,NULL,-1);
    GT_RefreshWindow(pr_Win,NULL);
d84 1
a84 7
      GT_SetGadgetAttrs(pr_Gadgets[PR_PASSWORD],pr_Win,NULL,
			GTST_String,MainPrefs.mp_AnonymousPW,
			TAG_END);
    if (MainPrefs.mp_ProxyServer)
      GT_SetGadgetAttrs(pr_Gadgets[PR_PROXYGAD],pr_Win,NULL,
			GTST_String,MainPrefs.mp_ProxyServer,
			TAG_END);
d86 1
a86 3
      GT_SetGadgetAttrs(pr_Gadgets[PR_VIEWCMD],pr_Win,NULL,
			GTST_String,MainPrefs.mp_ViewCommand,
			TAG_END);
d88 125
a212 22
      GT_SetGadgetAttrs(pr_Gadgets[PR_DEFDLDIR],pr_Win,NULL,
			GTST_String,MainPrefs.mp_LocalDir,
			TAG_END);
    GT_SetGadgetAttrs(pr_Gadgets[PR_PROXYPGAD],pr_Win,NULL,
		      GTIN_Number,MainPrefs.mp_ProxyPort?MainPrefs.mp_ProxyPort:21,
		      TAG_END);
    GT_SetGadgetAttrs(pr_Gadgets[PR_SHOWDOTS],pr_Win,NULL,
		      GTCB_Checked,MainPrefs.mp_Showdotfiles,
		      TAG_END);
    GT_SetGadgetAttrs(pr_Gadgets[PR_DEFPROXY],pr_Win,NULL,
		      GTCB_Checked,MainPrefs.mp_DefaultProxy,
		      TAG_END);
    GT_SetGadgetAttrs(pr_Gadgets[PR_IGNORECASE],pr_Win,NULL,
		      GTCB_Checked,MainPrefs.mp_IgnoreCase,
		      TAG_END);
    HelpControl(pr_Win,HC_GADGETHELP);
    winmask=1<<pr_Win->UserPort->mp_SigBit;
    while (Continue) {
	mask=Wait(winmask|AG_Signal);
	if (mask&AG_Signal)
	  HandleAmigaGuide();
	if (mask&winmask) {
d214 2
a215 81
	    while (imsg=GT_GetIMsg(pr_Win->UserPort)) {
		int (*func)();
		struct IntuiMessage pr_Msg;
		ULONG MsgClass;
		UWORD Code;
		MsgClass = imsg->Class;
		Code     = imsg->Code;
		CopyMem(imsg,&pr_Msg,sizeof(pr_Msg));
		GT_ReplyIMsg(imsg);

		switch(MsgClass) {
		  case IDCMP_CLOSEWINDOW:
		    Continue=FALSE;
		    break;
		  case IDCMP_REFRESHWINDOW:
		    GT_BeginRefresh(pr_Win);
		    GT_EndRefresh(pr_Win,TRUE);
		    break;
		  case IDCMP_GADGETHELP:
		    ag.ag_region=-1;
		    if (pr_Msg.IAddress==(APTR)pr_Win) {
			ag.ag_region=0;
		    }
		    break;
		  case IDCMP_RAWKEY:
		    if (pr_Msg.Code==95) {
			SendAGMessage(AG_GLOBPREFS);
		    }
		    break;
		  case IDCMP_GADGETUP:
		  case IDCMP_GADGETDOWN:
		    if ( pr_Msg.IAddress == pr_Gadgets[PR_PASSWORD]) {
			PWChanged=TRUE;
		    }
		    else if (pr_Msg.IAddress == pr_Gadgets[PR_PROXYGAD]) {
			PRChanged=TRUE;
		    }
		    else if (pr_Msg.IAddress == pr_Gadgets[PR_VIEWCMD]) {
			VCChanged=TRUE;
		    }
		    else if (pr_Msg.IAddress == pr_Gadgets[PR_DEFDLDIR]) {
			DefDLDirChanged=TRUE;
		    }
		    break;
		  case IDCMP_VANILLAKEY:
		    {
			ULONG num;
			num=MatchVanillaKey(pr_Msg.Code,pr_FastKeys);
			if (num!=-1) {
			    if (num<NumGadgets_pr && num>=0) {
				switch (num) {
				  case PR_PASSWORD:
				  case PR_VIEWCMD:
				  case PR_PROXYGAD:
				  case PR_PROXYPGAD:
				  case PR_DEFDLDIR:
				    ActivateGadget(pr_Gadgets[num],pr_Win,NULL);
				    break;
				  case PR_SHOWDOTS:
				  case PR_DEFPROXY:
				  case PR_IGNORECASE:
				    {
					long p;
					GT_GetGadgetAttrs(pr_Gadgets[num],pr_Win,NULL,GTCB_Checked,&p,TAG_DONE);
					GT_SetGadgetAttrs(pr_Gadgets[num],pr_Win,NULL,
							  GTCB_Checked,p?0:1,
							  TAG_END);
				    }
				    break;
				  default:
				    break;
				}
			    }
			}
		    }
		    break;
		  default:
		    break;
		}
	    }
	}
d217 14
a230 38
    if  (PWChanged) {
	if (MainPrefs.mp_AnonymousPW)
	  free(MainPrefs.mp_AnonymousPW);
	if (strlen(GetString(pr_Gadgets[PR_PASSWORD])))
	  MainPrefs.mp_AnonymousPW=strdup(GetString(pr_Gadgets[PR_PASSWORD]));
	ConfigChanged=TRUE;
    }
    if (PRChanged) {
	if (MainPrefs.mp_ProxyServer) {
	    free(MainPrefs.mp_ProxyServer);
	    MainPrefs.mp_ProxyServer=NULL;
	}
	if (strlen(GetString(pr_Gadgets[PR_PROXYGAD])))
	  MainPrefs.mp_ProxyServer=strdup(GetString(pr_Gadgets[PR_PROXYGAD]));
	ConfigChanged=TRUE;
    }
    if (VCChanged) {
	if (MainPrefs.mp_ViewCommand) {
	    free(MainPrefs.mp_ViewCommand);
	    MainPrefs.mp_ViewCommand=NULL;
	}
	if (strlen(GetString(pr_Gadgets[PR_VIEWCMD])))
	  MainPrefs.mp_ViewCommand=strdup(GetString(pr_Gadgets[PR_VIEWCMD]));
	ConfigChanged=TRUE;
    }
    if (DefDLDirChanged) {
	if (MainPrefs.mp_LocalDir) {
	    free(MainPrefs.mp_LocalDir);
	    MainPrefs.mp_LocalDir=NULL;
	}
	if (strlen(GetString(pr_Gadgets[PR_DEFDLDIR])))
	  MainPrefs.mp_LocalDir=strdup(GetString(pr_Gadgets[PR_DEFDLDIR]));
	ConfigChanged=TRUE;
    }
    {
	long p;
	GT_GetGadgetAttrs(pr_Gadgets[PR_SHOWDOTS],pr_Win,NULL,GTCB_Checked,&p,TAG_DONE);
	if (p!=MainPrefs.mp_Showdotfiles) {
a231 1
	    MainPrefs.mp_Showdotfiles=MainPrefs.mp_Showdotfiles?FALSE:TRUE;
d233 4
a236 2
	p=GetNumber(pr_Gadgets[PR_PROXYPGAD]);
	if (p!=MainPrefs.mp_ProxyPort) {
a237 1
	    MainPrefs.mp_ProxyPort=p;
d239 4
a242 2
	GT_GetGadgetAttrs(pr_Gadgets[PR_DEFPROXY],pr_Win,NULL,GTCB_Checked,&p,TAG_DONE);
	if (p!=MainPrefs.mp_DefaultProxy) {
a243 1
	    MainPrefs.mp_DefaultProxy=p;
d245 68
a312 2
	GT_GetGadgetAttrs(pr_Gadgets[PR_IGNORECASE],pr_Win,NULL,GTCB_Checked,&p,TAG_DONE);
	if (p!=MainPrefs.mp_IgnoreCase) {
a313 1
	    MainPrefs.mp_IgnoreCase=p;
d315 5
d321 2
a322 4
    StripIntuiMessages(pr_Win->UserPort,pr_Win);
    CloseWindow(pr_Win);
    FreeGadgets(pr_glist);
    return(1);
d325 42
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d4 1
a4 1
enum {PR_PASSWORD=0,PR_VIEWCMD,PR_SHOWDOTS,PR_PROXYGAD,PR_PROXYPGAD,PR_DEFPROXY,PR_IGNORECASE,
d18 1
a18 1
//    {0,0,0,0,NULL,NULL,5,PLACETEXT_LEFT,NULL,NULL}, /* Def.download dir */
d30 1
a30 1
/*    (LONG)MPW_DefDownloadDir,*/
d66 5
d85 1
d98 8
a105 1

d109 1
a109 1
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=2*INTERWIDTH+GadgetTextLength(PropRPort,pr_NewGadgets[PR_PASSWORD]);
d116 5
d122 3
a124 3
    pr_NewGadgets[PR_PROXYGAD].ng_Width=pr_NewGadgets[PR_VIEWCMD].ng_Width;
    pr_NewGadgets[PR_PROXYGAD].ng_LeftEdge=pr_NewGadgets[PR_VIEWCMD].ng_LeftEdge;
    pr_NewGadgets[PR_PROXYGAD].ng_TopEdge=pr_NewGadgets[PR_VIEWCMD].ng_TopEdge+INTERHEIGHT+pr_NewGadgets[PR_VIEWCMD].ng_Height;
d153 1
a153 1

d170 1
d219 4
d283 3
d298 1
d348 9
@


0.774
log
@Now handles filenames up to 128 chars, atleast in DownloadFile().
@
text
@d152 1
a152 1

d164 1
a164 1
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|IDCMP_VANILLAKEY,
d212 2
d215 72
a286 54
	WaitPort(pr_Win->UserPort);

	while (imsg=GT_GetIMsg(pr_Win->UserPort)) {
	    int (*func)();
	    struct IntuiMessage pr_Msg;
	    ULONG MsgClass;
	    UWORD Code;
	    MsgClass = imsg->Class;
	    Code     = imsg->Code;
	    CopyMem(imsg,&pr_Msg,sizeof(pr_Msg));
	    GT_ReplyIMsg(imsg);

	    switch(MsgClass) {
	      case IDCMP_CLOSEWINDOW:
		Continue=FALSE;
		break;
	      case IDCMP_REFRESHWINDOW:
		GT_BeginRefresh(pr_Win);
		GT_EndRefresh(pr_Win,TRUE);
		break;
	      case IDCMP_GADGETUP:
	      case IDCMP_GADGETDOWN:
		if ( pr_Msg.IAddress == pr_Gadgets[PR_PASSWORD]) {
		    PWChanged=TRUE;
		}
		else if (pr_Msg.IAddress == pr_Gadgets[PR_PROXYGAD]) {
		    PRChanged=TRUE;
		}
		else if (pr_Msg.IAddress == pr_Gadgets[PR_VIEWCMD]) {
		    VCChanged=TRUE;
		}
		break;
	      case IDCMP_VANILLAKEY:
		{
		    ULONG num;
		    num=MatchVanillaKey(pr_Msg.Code,pr_FastKeys);
		    if (num!=-1) {
			if (num<NumGadgets_pr && num>=0) {
			    switch (num) {
			      case PR_PASSWORD:
			      case PR_VIEWCMD:
			      case PR_PROXYGAD:
			      case PR_PROXYPGAD:
				ActivateGadget(pr_Gadgets[num],pr_Win,NULL);
				break;
			      case PR_SHOWDOTS:
			      case PR_DEFPROXY:
			      case PR_IGNORECASE:
				{
				    long p;
				    GT_GetGadgetAttrs(pr_Gadgets[num],pr_Win,NULL,GTCB_Checked,&p,TAG_DONE);
				    GT_SetGadgetAttrs(pr_Gadgets[num],pr_Win,NULL,
						   GTCB_Checked,p?0:1,
						   TAG_END);
a287 3
				break;
			      default:
				break;
d291 3
a294 3
		break;
	      default:
		break;
@


0.753
log
@Improved fastkeys-handling.
@
text
@a155 1
//			    WA_AutoAdjust,FALSE,
d178 1
a178 1
//    if (!Layout_pr(&gad,pr_Win)) {
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@d88 1
d91 2
d96 2
a97 2
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=2*INTERWIDTH+GadgetTextLength(PropRPort,pr_NewGadgets[PR_PASSWORD]);//.ng_GadgetText,strlen(pr_NewGadgets[PR_PASSWORD].ng_GadgetText));

d135 4
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d90 2
a91 2
    pr_NewGadgets[PR_PASSWORD].ng_Width=TextLength(RPort,www,30);
    pr_NewGadgets[PR_PASSWORD].ng_Height=FHigh+2*INTERHEIGHT;
d93 1
a93 1
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=2*INTERWIDTH+GadgetTextLength(RPort,pr_NewGadgets[PR_PASSWORD]);//.ng_GadgetText,strlen(pr_NewGadgets[PR_PASSWORD].ng_GadgetText));
d98 1
a98 1
    pr_NewGadgets[PR_VIEWCMD].ng_Height=FHigh+2*INTERHEIGHT;
d100 1
a100 1
    pr_NewGadgets[PR_PROXYGAD].ng_Height=FHigh+2*INTERHEIGHT;
d106 1
a106 1
    pr_NewGadgets[PR_PROXYPGAD].ng_Width=2*INTERWIDTH+TextLength(RPort,www,6);
d111 1
a111 1
    pr_NewGadgets[PR_DEFPROXY].ng_Width=2*FHigh+INTERWIDTH;
d113 1
a113 1
    pr_NewGadgets[PR_DEFPROXY].ng_Height=FHigh+INTERHEIGHT;
d115 2
a116 2
    pr_NewGadgets[PR_SHOWDOTS].ng_Width=2*FHigh+INTERWIDTH;
    pr_NewGadgets[PR_SHOWDOTS].ng_Height=FHigh+INTERHEIGHT;
d120 2
a121 2
    pr_NewGadgets[PR_IGNORECASE].ng_Width=2*FHigh+INTERWIDTH;
    pr_NewGadgets[PR_IGNORECASE].ng_Height=FHigh+INTERHEIGHT;
d147 1
d149 1
a149 1
			    WA_AutoAdjust,FALSE,
d155 2
d165 1
a165 1
    SetFont(pr_Win->RPort,dfont);
@


0.541
log
@Forgot to set ConfigChanged=FALSE when saving the config
Added more hotkeys.
@
text
@a87 1

d93 1
a93 1
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=2*INTERWIDTH+TextLength(RPort,pr_NewGadgets[PR_PASSWORD].ng_GadgetText,strlen(pr_NewGadgets[PR_PASSWORD].ng_GadgetText));
d154 1
a154 1
			    WA_Title,"AmiFTP Preferences",
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d44 1
d49 1
d54 1
d59 1
d64 1
d69 1
d127 6
a132 1

d242 23
a264 2
			if (num==PR_PASSWORD)
			  ActivateGadget(pr_Gadgets[PR_PASSWORD],pr_Win,NULL);
@


0.371
log
@Localized source.
@
text
@d88 1
a88 1
    pr_NewGadgets[PR_PASSWORD].ng_LeftEdge=INTERWIDTH+TextLength(RPort,pr_NewGadgets[PR_PASSWORD].ng_GadgetText,strlen(pr_NewGadgets[PR_PASSWORD].ng_GadgetText));
@


0.348
log
@Fixed the gadgets in site_gui (functions were messed up)
Enumerated gadgetnumbers to prevent the above in the future.
@
text
@d12 21
a32 8
    {0,0,0,0,"_Anonymous password",NULL,0,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"View command",NULL,6,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Show dot-files?",NULL,1,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Proxy host",NULL,2,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Proxy port",NULL,3,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Use proxy per default?",NULL,4,PLACETEXT_LEFT,NULL,NULL},
//    {0,0,0,0,"Default download directory",NULL,5,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Ignore case?",NULL,7,PLACETEXT_LEFT,NULL,NULL}
@


0.284
log
@First RCS version.
@
text
@d4 2
a5 9
#define PR_PASSWORD   0
#define PR_VIEWCMD    1
#define PR_SHOWDOTS   2
#define PR_PROXYGAD   3
#define PR_PROXYPGAD  4
#define PR_DEFPROXY   5
//#define PR_DEFAULTDL  5
#define PR_IGNORECASE 6
#define NumGadgets_pr 7
@
