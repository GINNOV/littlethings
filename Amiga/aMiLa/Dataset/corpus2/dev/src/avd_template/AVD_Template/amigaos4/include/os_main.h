/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2003 BITbyBIT Software Group, All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * BITbyBIT Software Group (Confidential Information).  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with BITbyBIT Software Group.
 *
 * BITbyBIT SOFTWARE GROUP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
 * SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * BITbyBIT Software Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 * Project: AVD_Template
 *
 * OS Specific Data and Functions (os_main.h)
 *
 * $VER: os_main.h 1.0
 * 
 */
 
#ifndef __OS_MAIN_H__
#define __OS_MAIN_H__

/* Required system include files */ 
#include <stdio.h> 
#include <fcntl.h> 
#include <stdlib.h> 
#include <string.h>

/* Source all custom types */
#include <avd_types.h>

/* Include OS specific headers */
#include <exec/exec.h>
#include <intuition/intuition.h>
#include <intuition/icclass.h>
#include <dos/dos.h>
#include <workbench/icon.h>
#include <workbench/startup.h>

/* Bring in the Amiga specific header files */
#include <proto/exec.h>
#include <proto/commodities.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/icon.h>
#include <proto/keymap.h>
#include <proto/dos.h>
#include <proto/wb.h>
#include <clib/alib_protos.h>

/* 
 * Simply include the proto file for all reaction classes you intent to use
 * to trigger their autoinitialization.
 */
#include <proto/arexx.h>
#include <proto/popupmenu.h>
#include <proto/requester.h>
#include <proto/window.h>

/* Protos for Gadget Class based Objects */
#include <proto/button.h>
#include <proto/checkbox.h>
#include <proto/chooser.h>
#include <proto/clicktab.h>
#include <proto/colorwheel.h>
#include <proto/datebrowser.h>
#include <proto/fuelgauge.h>
#include <proto/getfile.h>
#include <proto/getfont.h>
#include <proto/getscreenmode.h>
#include <proto/integer.h>
#include <proto/layout.h>
#include <proto/listbrowser.h>
#include <proto/palette.h>
#include <proto/partition.h>
#include <proto/popcycle.h>
#include <proto/radiobutton.h>
#include <proto/scroller.h>
#include <proto/sketchboard.h>
#include <proto/slider.h>
#include <proto/space.h>
#include <proto/speedbar.h>
#include <proto/string.h>
#include <proto/texteditor.h>
#include <proto/virtual.h>

/* Protos for Image Class based Objects */
#include <proto/bevel.h>
#include <proto/bitmap.h>
#include <proto/drawlist.h>
#include <proto/filler.h>
#include <proto/glyph.h>
#include <proto/label.h>
#include <proto/penmap.h>

/* Window Title String (Constant and Global Pointer) */
#define WINTITLE "AVD Template v" PRODUCT_VER " ©2005 BITbyBIT Software Group LLC"
#define VERSION_STRING "$VER:" WINTITLE
#define MAX_WINTITLE_LENGTH 80
#define MAX_POPKEY_LENGTH 128
#define MAX_HIDEKEY_LENGTH 128
#define DEFAULT_ICONTITLE_STR "AVD_Template"
#define DEFAULT_POPKEY_STR    "f3"
#define DEFAULT_HIDEKEY_STR   "esc"

#define TN_CX_POPUP    "CX_POPUP"
#define TN_CX_POPKEY   "CX_POPKEY"
#define TN_CX_PRIORITY "CX_PRIORITY"
#define TN_HIDEKEY     "HIDEKEY"
#define TN_PUBSCREEN   "PUBSCREEN"
#define TN_CENTERED    "CENTERED"
#define TN_LEFT        "LEFT"
#define TN_TOP         "TOP"
#define TN_WIDTH       "WIDTH"
#define TN_HEIGHT      "HEIGHT"

enum
{
	TT_CX_POPUP,
	TT_CX_POPKEY,
	TT_CX_PRIORITY,
	TT_HIDEKEY,
	TT_PUBSCREEN,
	TT_CENTERED,
	TT_LEFT,
	TT_TOP,
	TT_WIDTH,
	TT_HEIGHT,
	TT_DONENULL,
	TT_TOTAL
};

#define TOOLTYPE_MAXLEN 64

/* Defines for Commodity Events */
#define EVT_HOTKEY 1L

/* Define a few needed RAWKEY codes */
#define RAWKEY_MOUSEWHEEL_UP   0x7A
#define RAWKEY_MOUSEWHEEL_DOWN 0x7B
#define RAWKEY_TAB             0x42
#define RAWKEY_ESC             0x45
#define RAWKEY_CURSORUP        0x4C
#define RAWKEY_CURSORDOWN      0x4D
#define RAWKEY_CURSORRIGHT     0x4E
#define RAWKEY_CURSORLEFT      0x4F
#define RAWKEY_PAGEUP          0x48
#define RAWKEY_PAGEDOWN        0x49
#define RAWKEY_HOME            0x70
#define RAWKEY_END             0x71
#define RAWKEY_SPACE           0x40
#define RAWKEY_RETURN          0x44
#define RAWKEY_NUMPAD_ENTER    0x43
#define QUALIFIER_NONE         0x00
#define QUALIFIER_SHIFT        0x03
#define QUALIFIER_ALT          0x30
#define QUALIFIER_CTRL         0x08
#define MOVE_UP                1
#define MOVE_DOWN              0

#define DEFAULT_WINLEFT   0
#define DEFAULT_WINTOP    1
#define DEFAULT_WA_MINWIDTH  40
#define DEFAULT_WA_MINHEIGHT 40
#define DEFAULT_WINWIDTH     DEFAULT_WA_MINWIDTH
#define DEFAULT_WINHEIGHT    DEFAULT_WA_MINHEIGHT
#define DEFAULT_H0_WINWIDTH  1152
#define DEFAULT_H0_WINHEIGHT (964 - DEFAULT_WINTOP)
#define DEFAULT_H1_WINWIDTH  1024
#define DEFAULT_H1_WINHEIGHT (768 - DEFAULT_WINTOP)
#define DEFAULT_H2_WINWIDTH  800
#define DEFAULT_H2_WINHEIGHT (600 - DEFAULT_WINTOP)
#define DEFAULT_H3_WINWIDTH  640
#define DEFAULT_H3_WINHEIGHT (400 - DEFAULT_WINTOP)

#define DEFAULT_ZOOM_LEFTEDGE 0
#define DEFAULT_ZOOM_TOPEDGE  1
#define DEFAULT_ZOOM_WIDTH    1024
#define DEFAULT_ZOOM_HEIGHT   (768 - DEFAULT_ZOOM_TOPEDGE)

#define MENUID_MASK     0xFF
/* Project Menu (0x00) */
#define MENUID_HIDE     0x00
#define MENUID_ICONIFY  0x20
/* Menu Bar - skip 0x40 */
#define MENUID_ABOUT    0x60
/* Menu Bar - skip 0x80 */
#define MENUID_QUIT     0xA0
/* Window Menu (0x01) */
#define MENUID_SNAPSHOT 0x01
#define MENUID_CENTER   0x21
#define MENUID_ZOOMZIP  0x41

/* AVD Window Flags (Bitwise 1,2,4,8,16, etc.) */
#define WHFLG_NONE 0
#define WHFLG_OPENONSTART 1
#define WHFLG_MAKEACTIVE 2

struct AVD_WindowHandle
{
	struct Node   wh_Node;       /* Embedded Node structure for Linking into a List */
	Object        *wh_WinObj;    /* Pointer to the Window Class Object */
	struct Window *wh_Window;    /* Pointer to the Intuition Window for this Window Object */
	Object        *wh_Layout;    /* Pointer to the Window Class Object's root Layout objects (ReAction Interface) */
	struct IBox   wh_WindowSize; /* (struct IBox) { Left, Top, Width, Height } */
	struct IBox   wh_ZoomSize;   /* (struct IBox) { Left, Top, Width, Height } */
	uint32        wh_ObjectID;   /* The Object ID used to identify this Object */
	uint32        wh_Flags;      /* Holds useful flags for the WindowHandle (WHFLG_x) */
};

enum ListTypes
{
	LHT_UNKNOWN,
	LHT_CHOOSER_NODES,
	LHT_CLICKTAB_NODES,
	LHT_DROPDOWN_NODES,
	LHT_LISTBROWSER_NODES,
	LHT_PARTITION_NODES,
	LHT_RADIOBUTTON_NODES,
	LHT_SPEEDBAR_NODES
};

struct AVD_ListHandle
{
	struct Node    lhd_Node;     /* Embedded Node structure for Linking into a List */
	struct List    lhd_List;     /* Embedded List structure to hold ReAction class nodes (ListBrowser Nodes, ClickTab Nodes, etc.) */
	enum ListTypes lhd_ListType; /* Type of List this Object contains (ListBrowser, ClickTab, etc.) */
	uint32         lhd_ObjectID; /* The Object ID of the GUI Object which "owns" this list. Used to identify this list */
};

/* Include the defines for the GUI Interface */ 
#include "os_gui.h"

typedef struct OS_App
{
	/* Any OS Specific data here */
	STRPTR           *pToolTypes;      /* Pointer to ToolTypes Array */
	struct MsgPort   *pMsgPort;        /* Message Port for the Window Object */
	struct MsgPort   *pCxMsgPort;      /* Message Port for the Commodity Broker */
	CxObj            *broker;          /* (CxObj *) Pointer to Broker Object */
	CxObj            *hotkey_filter;   /* (CxObj *) Pointer to HotKey Filter Object */
	CxMsg            *cxMsg;           /* (CxMsg *) Pointer to Commodity Message */
	uint8            *pPopKey;         /* (uint8 *) Pointer to POPUP key description */
	uint8            *pHideKey;        /* (uint8 *) Pointer to HIDE key description */

	struct Screen    *screen;          /* Pointer to our (Public)Screen object */
	uint32           sigwinmask;       /* Signal Mask for the main window */

	struct NewBroker oNewBroker;       /* Our CxObject */
	IX               oHideKey;         /* RawKey (IX) structure for our Hide Key */
	char             *sWindowTitle;    /* Window Title String */
	char             *sPubScreenName;  /* Public Screen Name */
	char             oWindowTitle[MAX_WINTITLE_LENGTH+MAX_POPKEY_LENGTH+MAX_HIDEKEY_LENGTH];

	/* Global Window/Screen size position data */
	BOOL             bOpenOnStart;     /* TRUE if "CX_POPUP=YES" */
	BOOL             bFirstOpen;       /* TRUE if this is the first time this window has been opened */
	BOOL             bCenterWin;       /* TRUE if the Window should be Centered */
	struct IBox      oWindowSize;      /* (struct IBox) { Left, Top, Width, Height } */
	struct IBox      oZoomSize;        /* (struct IBox) { Left, Top, Width, Height } */

	/* Menu for Window */
	struct NewMenu   oWindowMenu[12];  /* (struct NewMenu) Make sure the array number matches (is one higher than) the initialized entries in <os_initapp.c> */

	/* List of AVD WindowHandles */
	struct List      oWindowList;      /* List structure to hold our Window Object (struct AVD_WindowHandle) nodes */

	/* List of AVD ListHandles */
	struct List      oListHandles;     /* List structure to hold our Dependent Object's Lists (struct AVD_ListHandle) nodes */

	/* Primary Array of Object pointers for the graphical interface */
	Object *         Objects[OBJ_NUM]; /* (Object *) Array of OO GUI Objects (see macros below for shortcuts to this array) */

} OSAPP;

/* Macro shortcuts for our objects */
#define OBJ(x) pOSApp->Objects[x]
#define GAD(x) (struct Gadget *)pOSApp->Objects[x]

/* Quite handy Reaction "Add Space" macro statement */
#define SPACE LAYOUT_AddChild, SpaceObject, End

/*
 * This is the entry point for the compiler, while the entry point for
 * our application is AVD_Main(). This provides for a clean "main" source
 * file, plus greatly enhances cross platform portability.
 */

/* OS Main */
int main(int argc, char *argv[]);

/*
 * OS Macros
 * This is a great way to "patch" functions that perfrom the exact same thing,
 * but have different names on each OS. Rather than wrapping the function with
 * an os_X() version, you can just pick the most commonly used name and create
 * a C MACRO to alias it to the common name.
 */
//#define strnicmp(pS1,pS2,n) strncasecmp(pS1,pS2,n)

#endif  /* End of __OS_MAIN_H__ */

