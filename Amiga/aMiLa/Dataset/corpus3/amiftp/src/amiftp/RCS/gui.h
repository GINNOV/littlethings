head	1.795;
access;
symbols;
locks
	lilja:1.795; strict;
comment	@ * @;


1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
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
next	0.588;

0.588
date	95.09.12.16.24.08;	author lilja;	state Exp;
branches;
next	0.348;

0.348
date	95.06.22.18.56.45;	author lilja;	state Exp;
branches;
next	0.303;

0.303
date	95.06.08.15.30.02;	author lilja;	state Exp;
branches;
next	;


desc
@Headerfile for gui.c
@


1.795
log
@Stuff.
@
text
@/* RCS Id:  $Id: gui.h 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>
#include <graphics/rpattr.h>
#include <clib/macros.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>
#include <string.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <dos.h>
#include <math.h>

#include <proto/window.h>
#include <classes/window.h>

#include <proto/layout.h>
#include <gadgets/layout.h>

#include <proto/button.h>
#include <gadgets/button.h>

#include <proto/string.h>
#include <gadgets/string.h>

#include <proto/arexx.h>
#include <classes/arexx.h>

#include <proto/clicktab.h>
#include <gadgets/clicktab.h>

#include <proto/speedbar.h>
#include <gadgets/speedbar.h>

#include <proto/penmap.h>
#include <images/penmap.h>

#include <libraries/gadtools.h>
#include <classact.h>
#include <classact_author.h>
#include <classact_lib_protos.h>

#ifndef QUALIFIER_SHIFT
#define RAWKEY_CURSORUP 76
#define RAWKEY_CURSORDOWN 77
#define QUALIFIER_SHIFT 0x03
#define QUALIFIER_ALT 0x30
#define QUALIFIER_CTRL 0x08
#endif

extern struct RastPort *NonPropRPort,*PropRPort;
extern UWORD PropFHigh,MinHigh,MinWide,PropBLine;
extern UWORD NonPropFHigh,NonPropBLine;

extern struct GfxBase *GfxBase;
extern struct Library *GadToolsBase;
extern struct IntuitionBase *IntuitionBase;

extern char *PropFontName,*NonPropFontName,*PubScreenName;
extern int PropFontSize,NonPropFontSize;
extern struct TextFont *Propdfont,*NonPropdfont;
extern struct TextAttr Propta,NonPropta;

void ComputeMinSize(UWORD *minwide,UWORD *minheight);
BOOL LayoutElements(struct Gadget **gadg,UWORD MinWide,UWORD MinWidth);
struct Window *OpenFTPWindow(const BOOL StartIconified);
int CloseFTPWindow(void);

int Parent_clicked(void);
int File_clicked(void);
int Put_clicked(void);
int Connect_clicked(void);
int DLPath_clicked(void);
int Disconnect_clicked(void);
int Site_clicked(void);
int Dir_clicked(void);
int Abort_clicked(void);

#define GetString( g ) ((( struct StringInfo * )g->SpecialInfo)->Buffer)
#define GetNumber( g ) ((( struct StringInfo * )g->SpecialInfo)->LongInt)

extern struct Screen *Screen;
extern struct DrawInfo *DrawInfo;

extern Object *MainWin_Object;
extern struct Gadget *MG_List[];

extern struct ColumnInfo columninfo[];

enum {
    MG_ListView=0,
    MG_SiteName, MG_DirName, MG_CacheList,
    MG_DLString, MG_DLButton,
    MG_Parent, MG_Get, MG_Put, MG_View,
    MG_Readme, MG_Get2, MG_Put2, MG_View2,
    MG_Connect, MG_Disconnect, MG_Reload,
    MG_Page2, MG_SpeedBar,
    NumGadgets_main
  };

/* EOF */
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: gui.h 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d106 3
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id:  $Id$
   Locked version: $Revision$
d51 6
d108 6
a113 6
    MG_SiteName,MG_DirName,
    MG_DLString,MG_DLButton,
    MG_Parent,MG_Get,MG_Put,MG_View,
    MG_Readme,MG_Get2,MG_Put2,MG_View2,
    MG_Connect,MG_Disconnect,MG_Reload,
    MG_Page2, MG_FreeDisk, 
@


1.531
log
@Lots of stuff
@
text
@d1 4
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
@d50 1
d103 1
a103 1
    MG_Page2,
@


1.200
log
@GETATTR-hit fixed.
@
text
@d44 3
a78 1
int View_clicked(void);
d96 7
a102 3
    MG_ListView=0,MG_SiteName,MG_DirName,MG_Parent,
    MG_Get,MG_Put,MG_View,MG_DLString,
    MG_DLButton,MG_Connect,MG_Disconnect,MG_Reload,
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d71 1
a71 1
struct Window *OpenFTPWindow(BOOL StartIconified);
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
@a62 2
//extern struct Window *mainWin;
//extern struct TextAttr *PropFont,*NonPropFont;
a67 2
//extern struct Gadget *glist;
//extern struct Screen *myScn;
a87 4
//extern struct Gadget *mainGadgets[];
//extern struct Gadget *dl_Gadgets[];
//extern struct IntuiMessage mainMsg;

a98 7

struct GadGroup {
	UWORD Width;
	UWORD Height;
	UWORD WidestLabel;
	UWORD Extra;
};
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d41 3
d64 1
a64 1
extern struct TextAttr *PropFont,*NonPropFont;
a97 1
extern struct TextFont *ScreenFont;
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@d12 2
d29 24
d60 1
a60 1
extern struct Window *mainWin;
a62 1
extern APTR myVisualInfo;
d67 2
a68 2
extern struct Gadget *glist;
extern struct Screen *myScn;
d72 1
a72 2
int OpenFTPWindow(void);
int HandleFTPIDCMP(void);
a77 1
int Get_clicked(void);
a85 7
enum {GD_Files_LV=0,GD_SiteName,GD_DirName,GD_DLPathName,GD_Parent_gadget,GD_Get_gadget,GD_Put_gadget,
	GD_View_gadget,GD_DLPath_gadget,GD_Connect_gadget,GD_Disconnect_gadget,
	NumGadgets_main};

enum {GD_dl_RemoteFile=0,GD_dl_LocalFile,GD_dl_Size,GD_dl_CPS,GD_dl_DataTransferred,GD_dl_AbortGad,
	NumGadgets_dl};

d89 16
a104 3
extern struct Gadget *mainGadgets[];
extern struct Gadget *dl_Gadgets[];
extern struct IntuiMessage mainMsg;
@


0.348
log
@Fixed the gadgets in site_gui (functions were messed up)
Enumerated gadgetnumbers to prevent the above in the future.
@
text
@d27 3
a29 2
extern struct RastPort *RPort;
extern UWORD FHigh,MinHigh,MinWide,BLine;
d35 1
a35 1
extern struct TextAttr *Font;
d38 4
a41 4
extern char *FontName,*PubScreenName;
extern int FontSize;
extern struct TextFont *dfont;
extern struct TextAttr ta;
@


0.303
log
@Initial version
@
text
@d62 3
a64 12
#define GD_Files_LV           0
#define GD_SiteName           1
#define GD_DirName            2
#define GD_DLPathName         3
#define GD_Parent_gadget      4
#define GD_Get_gadget         5
#define GD_Put_gadget         6
#define GD_View_gadget        7
#define GD_DLPath_gadget      8
#define GD_Connect_gadget     9
#define GD_Disconnect_gadget 10
#define NumGadgets_main      11
d66 2
a67 7
#define GD_dl_RemoteFile      0
#define GD_dl_LocalFile       1
#define GD_dl_Size            2
#define GD_dl_CPS             3
#define GD_dl_DataTransferred 4
#define GD_dl_AbortGad        5
#define NumGadgets_dl         6
@
