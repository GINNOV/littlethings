/* DiskMaster II  Config Module    SaveConfig
**
** 2.5.30
**
** 04-05-20 jjt - SaveWindows() - DevList state is saved (if it != SHOWDEV_ALL).
**                Thanks for reporting to Glenn Edward <glenn_edw@email.com>!
**              - SaveWindows() - HideDev state is saved (if in use).
**                Thanks for reporting to Glenn Edward <glenn_edw@email.com>!
**
** 04-07-07 rri - Bugfix: DM2 won't iconify anymore if the WB is not open...
**
** 2.5.31
**
** 04-10-17 rri - Finally removed the trigraph warning VBCC and now GCC 3.4.2 issued
**                by changing "??-" into "?\?-".
**              - Fixed the warning about the "0" in "%03.3lx" which SAS-C needs and GCC complains about.
**
** 04-10-31 rri - Changed one LibOpen() call to the new format.
**
** 04-12-22 rri - Bumped the minimum version-number for workbench.lib to 39 -> DM2 goes V39+!
**
** 05-03-21 rri - Replaced 1 "#ifdef __PPC__" with "#ifdef __amigaos4__".
**
** 05-03-26 rri - Added saving of "TimePlus" to 'SetX'.
**
** 2.6
**
** 05-07-10 rri - Bugfix: removed a potential buffer-overflow from 'SaveConfig' which could occur
**                        in case ASL.library was not available.
** 05-07-17 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**
** 05-07-24 rri - Changed one "UBYTE *" to a "STRPTR" in SaveMenus() to get
**                rid of a warning from the OS4 SDK 51.10.
**
** 05-07-31 rri - Changed the internal startup to use "#" chars as indicator for empty
**                command-lines.
**              - Added a sort-by-length entry to the internal startup.
**
** 05-08-19 rri - Modified code for saving the "timeplus" option to use DMFLAG_TIMEPLUS.
**              - Added saving of "LongCmd" to 'SetX'.
**
** 05-08-23 rri - Modifed SaveWin() to correctly generate empty command-window lines.
**
** 05-08-28 jjt - SaveScreen() - May now save HostScreen instead of NewScreen
**                             - Can use screen prefs from DMPrefs instead of current screen.
**
** 05-08-31 jjt - SaveConfig() - Returns TRUE if the config was saved.
**
** 05-09-02 jjt - SaveConfig() - NewScreen generated from DMPrefs values contains font info.
**
** 05-09-06 jjt - SaveConfig() - Removed defx, defy = screen width, height test.
**              - Iconify() - v44+ only.
**              - SaveConfig() - Removed temporary screen prefs code.
**              - SaveConfig() - Changed 2 "MyScreen"s to Screen.
**              - Bugfix:  DMP_Screen_Font was declared wrong.
**              - Made RememberDMClose() and RememberDMOpen() from Iconify().
**
** 05-09-07 jjt - Removed most of the DMP_Screen_<x> vars.
**
** 05-09-07 jjt - SaveConfig() - SetX DragDelay and WheelMult are saved.
**
** 05-10-02 rri - Re-Installed the defx, defy = screen width, height test because
**                when using e.g. 800x600 as default and a real resolution of 1024x768
**                the *first* time the windows get scaled correctly...'Iconify'...
**
** 05-10-02 rri - Added DMPrefs command-line to the internal startup.
**
** 05-10-05 jjt - Added SaveColors(); replaces SaveConfig()'s color-saving code.
**
** 05-10-10 jjt - Bugfix: SaveColors() - Using DMP_ColorTable32 instead of ColMap.  The
**                terminating NULL of ColMap was overwritten by GetRGB32().
**
** 05-11-02 jjt - Bugfix: SaveScreen() - "HostScreen" should also be used when MyScreen == NULL.
**                Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**              - Bugfix: SaveScreen() - Font names are now enclosed in quotes (NewScreen & Font).
**                Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**              - Bugfix: SaveScreen() - SetX DefX & DefY won't be saved when the "Scale windows"
**                option in DMPrefs is turned off.
**
** 05-11-03 jjt - SaveScreen() - If DMP_UseWinScale is true then SetX DefX & DefY will use
**                Screen_Width & Screen_Height.
**
** 05-11-05 jjt - Bugfix: SaveScreen() - 11-02's fix worked too well.  Back to using only
**                DMP_UseHostScreen to determine when to use "HostScreen", but this time
**                it's state should always be correct.
**              - RememberDMOpen() - Added a ScreenToFront() call when using a public
**                screen.
**
** 05-11-08 jjt - SaveConfig() - SetX Guide is saved.
**
** 05-11-13 jjt - Bugfix: SaveScreen() - 11-03's experiment nearly worked, but should be
**                Screen->Width and Screen->Height, as DMPrefs changes Screen_Width and
**                Screen_Height to the desired _new_ dimensions.
**                Thanks for reporting to Gerd Frank <mainactor@gmx.net>.
**
** 05-11-19 rri - Modified the internal configuration once again to make it more
**                useable for new users.
**
** 05-11-20 rri - Removed two warnings with GCC4
**
** 05-11-22 rri - Iconify() is V40+ again.
**
** 05-11-23 jjt - SaveConfig() - Added SetX ReqHideHelp.
**
** 05-11-26 rri - Changed the "Startup.DM" reference in the internal config
**                to "DiskMaster2.prefs".
**
** 05-12-08 rri - Removed the usage of F-keys for key-commands from the default-config
**                following the suggestion of David Rey.
**
** 2.7
**
** 06-01-21 jjt - SaveScreen() - When DMP_PensModified is true, the Pens20 array is read
**                instead of the dri_Pens array.
**
** 06-03-05 rri - Adding additional brackets to the "sprintf(ptr," %lu"," line solved
**                a warning with GCC.
**
** 06-12-03 rri - Removed the AddPort() calls, FreeUserData() no longer does a RemPort()...
**
** b4
**
** 06-12-16 rri - Conditionally removed the var "drag_delay" from the OS4 build.
**
** b9
**
** 07-01-17 rri - Reworked Iconify() to not depend on the build-in icon and to just quit when
**                the system could not even supply a default-icon.
**              - Changed SaveConfig() to use the default project-icon rather than the build-in.
**              - Removed the old 4-color build-in icon with an "#if 0".
** b10
**
** 07-01-28 rri - Removed saving the alternative color-set for the commands from the OS4 build.
**
** 07-02-03 rri - Removed the "*" from the paths of the default config.
**              - Changed the appearance of "Delete" in the default config.
**              - Changed the CON: windows in the default config from 640x180 to 800x200.
**              - Re-arranged the default cmd-window commands a bit.
**              - Added "Help" entry to default main menu which displays "PROGDIR:DiskMaster2.guide".
**
*/

#include "DM.h"
#include <workbench/icon.h> /* 2.5.26 rri */

extern BOOL  DMP_UseHostScreen, DMP_UseWinScale, Req_ShowHelpBtn,  /* 2.6 jjt */
             DMP_PensModified;  /* 2.7 jjt */

extern UBYTE
             *ProgName, /* 2.5RC9 rri */
             *ActionArgs[],
             *AppIconPath, /* 2.5b13 rri */
             *AutoCmdStr[],
             BarFormat[],
             dcPath[],
             *DevHide_List[], /* 2.5.30 jjt */
             DispFormat[],
             DMname[], /* 2.5b7 rri */
             FontKeywords[][15],  /* 2.5RC2 jjt */
             g_buttons[], /* 2.5b13 rri */
             *Globuff, /* 2.5b7 rri */
             *KeyCmdStr[],
             PGadStr[],
             sbuff[],
             *Strap, /* 2.5.24 rri */
             TitleFormat[],
             Version[], /* 2.5.24 rri */
             DMP_HostScreen[];  /* 2.6 jjt */

extern UWORD Pens20[],Screen_Depth;

extern ULONG /*defx,defy,*/ /* 2.5.24 rri */
             DevHide_Count, /* 2.5.30 jjt */
             FLAGS, /* 2.5b10 rri */
             Screen_Width,Screen_Height,Screen_ID,
             ShowDev, /* 2.5.30 jjt */
             UserColors, /* 2.5b11 rri */
             DMP_Screen_FontSz,  /* 2.6 jjt */
             DMP_ColorTable32[];  /* 2.6 jjt */

extern LONG digits, /* 2.5.23 rri */
            Notify, /* 2.5.23 rri */
            Globuff_size, /* 2.5b7 rri */
            separator, sizes; /* 2.5RC8 rri */

extern LONG DirPen, FilePen, BackPen, SelectPen; /* 2.5b12 rri */

extern APTR StringPool; /* 2.6 rri */

extern STRPTR DMP_Screen_Font, /* 2.6 jjt */
              DiskMaster2Guide;  /* 2.6 jjt */

extern uint32 wheel_multiply;

#ifndef __amigaos4__ /* 2.7 rri - obsolete with Reaction */
extern uint32 drag_delay;  /* 2.6 jjt */
#endif

extern struct DirWindow *DirWin[],*CmdWin;
extern struct Menu *DMMenu;
extern struct Screen *Screen,*MyScreen; /* 2.5.24 rri */

extern struct TextFont *DMFonts[];  /* 2.5RC2 jjt */
extern struct MsgPort *WinPort; /* 2.5b7 rri */

LONG IconX=NO_ICON_POSITION,IconY=NO_ICON_POSITION; /* 2.5b9 rri */

UBYTE DefStart[]= /* 2.5.24 rri */

   "AddC Root,10,Root\n"
   "AddC Parent,10,Parent\n"
   "AddC #\n"
   "AddC All,30,Select *\n"
   "AddC Clear,30,Deselect *\n"
   "AddC Select,30,Select\n"
   "AddC Exclude,30,DeSelect\n"
   "AddC SwapSelect,30,SwapSel\n"
   "AddC Select duplicates N/S,30,Dupe n s\n" /* 2.6 rri */
   "AddC #\n"
   "AddC  SYS:,10,NewDir SYS:\n" /* 2.7b10 rri */
   "AddC   RAM:,10,NewDir RAM:\n" /* 2.7b10 rri */
   "AddC    CD0:,10,NewDir CD0:\n" /* 2.7b10 rri */
   "AddC #\n"
   "AddC Copy,20,ReqPattern;Copy %s %d warn\n"
   "AddC Move,20,ReqPattern;Move %s %d warn\n"
   "AddC Rename,20,Recurse OFF;Rename %s\n"
   "AddC MakeDir,20,MakeDir\n"
   "AddC #\n"
   "AddC Delete,14,ReqPattern;Confirm \"All selected files will be lost!\";Delete %s\n" /* 2.7b10 rri */
   "AddC #\n"
   "AddC Protect,20,Recurse OFF;Protect %s\n"
   "AddC De-Protect,20,Protect %s +D\n"
   "AddC Comment,20,Recurse OFF;Comment %s\n"
   "AddC Find File,20,ReqPattern \"Please enter a search pattern:\";Find %s\n"
   "AddC Find Text,20,Read %s SEARCH\n"
   "AddC #\n"
   "AddC Read,20,Read %s wait\n"
   "AddC HexRead,20,Read %s HEX wait\n"
   "AddC View,20,Single;View %s ASYNC\n" /* 2.6 rri */
   "AddC Info,20,Single;Info %s ASYNC\n" /* 2.6 rri */
   "AddC #\n"
   "AddC Size Check,20,UnMark OFF;Check %s\n"
   "AddC Make Icon,20,Icon %s\n"
   "AddC #\n"
   "AddC Auto,20,Auto %s\n"
   "AddC #\n"
   "AddC Execute...,20,Extern\n"
   "AddC Run Selected,20,Single;Extern run %n\n"
   "AddC #\n"
   "AddC Preferences,30,DMPrefs\n" /* 2.6 rri */

   "AddM DiskMaster2,About...,?,About\n" /* 2.6 rri */
   "AddM DiskMaster2,Help...,H,View PROGDIR:DiskMaster2.guide ASYNC\n" /* 2.7b10 rri */
   "AddM DiskMaster2,Barlabel,\n"
   "AddM DiskMaster2,Iconify,I,Iconify\n" /* 2.6 rri */
   "AddM DiskMaster2,Barlabel,\n"
   "AddM DiskMaster2,Quit...,Q,Confirm \"Really quit?\" _Yes _No;Quit\n"

   "AddM Archives,Lha Add,StdIO \"CON:0/12/800/200/DM2\";Archive \"Lha -r a\";StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,ZIP Add,StdIO \"CON:0/12/800/200/DM2\";Archive \"ZIP -rvN\";StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,Lha Extract,StdIO \"CON:0/12/800/200/DM2\";Extern Lha x %n;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,Lha X >Dest,StdIO \"CON:0/12/800/200/DM2\";Extern Lha x %n %d;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,Lha X Req,Confirm \"Enter destination path\" C_ontinue _Cancel %P;StdIO \"CON:0/12/800/200/Extract\";Extern Lha x %s %r;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,Lha List,StdIO \"CON:0/12/800/200/DM2\";Extern Lha v %n;Wait;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddM Archives,Pack,Pack %s TO %d SUFFIX KEEPORIG\n"
   "AddM Archives,Unpack,Unpack %s TO %d KEEPORIG\n"

   "AddM Settings,Preferences...,P,DMPrefs\n" /* 2.6 rri */
   "AddM Settings,Load Config...,L,Load\n"
   "AddM Settings,Save Config...,S,Save ICON WARN\n"
   "AddM Settings,Edit DiskMaster2.prefs,E,ScrBack;Extern Ed S:DiskMaster2.prefs;ScrFront\n" /* 2.6 rri */
   "AddM Settings,Barlabel,\n"
   "AddM Settings,Display Format...,F,SetFormat\n"

   "AddM Control,Sort by Name,Sort N g\n"
   "AddM Control,Sort by Size,Sort S g\n"
   "AddM Control,Sort by Date,Sort D g\n"
   "AddM Control,Sort by Extension,Sort E g\n"
   "AddM Control,Sort by Comment,Sort C g\n"
   "AddM Control,Sort by Length,Sort L g\n" /* 2.6 rri */

   "AddA (FORM????ILBM#?|@database#?|??????JFIF#?|GIF8#?|?PNG#?),View %s ASYNC\n" /* 2.6 rri */
   "AddA ?\?-lh#?,StdIO \"CON:0/12/800/200/DM2\";Extern Lha x %n;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddA PK#?,StdIO \"CON:0/12/800/200/DM2\";Extern UnZIP %n;StdIO CLOSE\n"  /* 2.7b10 rri */
   "AddA ,#?.PGP,StdIO \"Con:0/12/800/200/PGP!\";Extern s=200000 PGP %n;StdIO CLOSE\n" /* 2.7b10 rri */
   "AddA DEFAULT,Read %s\n" /* 2.6 rri */

/* 2.6 rri
   "AddKeyCmd f1,about\n"
   "AddKeyCmd f2,iconify\n"
*/

   "\x0";

#if 0 /* 2.7b9 rri */
UWORD RenderImageData[] =
{
  0xffff,0xffff,0xffff,0xffff,0xffff,0xf81f,0xffff,0xffff,
  0xe007,0xffff,0xffff,0xe007,0xffff,0xffff,0xc183,0xffff,
  0xffff,0xc3c3,0xffff,0xffff,0xc3c3,0xffff,0xffff,0xff83,
  0xffff,0xffff,0xff87,0xffff,0xffff,0xff07,0xffff,0xffff,
  0xfe0f,0xffff,0xffff,0xfc1f,0xffff,0xffff,0xf83f,0xffff,
  0xffff,0xf001,0xffff,0xffff,0xe001,0xffff,0xffff,0xc001,
  0xffff,0xffff,0xffff,0x0000,0x0000,0x0000,0x0000,0x7c7c,
  0x07e0,0x0000,0x7c7c,0x1ff8,0x0000,0x7c7c,0x1ff8,0x0000,
  0x7c7c,0x3e7c,0x0000,0xfefe,0x3c3c,0x0000,0xfefe,0x3c3c,
  0x0000,0xfefe,0x007c,0x0000,0xeeee,0x0078,0x0001,0xefef,
  0x00f8,0x0001,0xefef,0x01f0,0x0001,0xefef,0x03e0,0x0001,
  0xc7c7,0x07c0,0x0003,0xc7c7,0x8ffe,0x0003,0xc7c7,0x9ffe,
  0x0003,0xc7c7,0xbffe,0x0000,0x0000,0x0000,0x0000,0x0000,
  0x0000,0x7fc0,0x7c7c,0x0000,0x7ff0,0x7c7c,0x0000,0x7ff8,
  0x7c7c,0x0000,0x7878,0x7c7c,0x0000,0x783c,0xfefe,0x0000,
  0x783c,0xfefe,0x0000,0x783c,0xfefe,0x0000,0x783c,0xeeee,
  0x0000,0x783d,0xefef,0x0000,0x783d,0xefef,0x0000,0x783d,
  0xefef,0x0000,0x7879,0xc7c7,0x0000,0x7ffb,0xc7c7,0x8000,
  0x7ff3,0xc7c7,0x8000,0x7fc3,0xc7c7,0x8000,0x0000,0x0000,
  0x0000 /* 2.5.28 rri */
};

struct Image RenderImage=
{
 0,0,   /* Top Corner */
 48,17, /* Width, Height */
 3,     /* Depth */
 &RenderImageData[0], /* Image Data */
 7, 0,  /* PlanePick,PlaneOnOff */
 NULL   /* Next Image */
};

UWORD SelectRenderData[] =
{
  0xffff,0xc007,0xffff,0xffff,0x0000,0x707f,0xfffe,0x0000,
  0x707f,0xfffe,0x07c0,0x707f,0xfffe,0x07c0,0x707f,0xffff,
  0x7fc0,0x203f,0xffff,0x7f81,0x203f,0xffff,0xff01,0x203f,
  0xffff,0xfe02,0x223f,0xffff,0xfc06,0x021f,0xffff,0xf80e,
  0x021f,0xffff,0xf01a,0x021f,0xffff,0xe037,0x071f,0xffff,
  0xc000,0x070f,0xffff,0x8000,0x070f,0xffff,0x0000,0x070f,
  0xfffe,0x0000,0x7fff,0x0000,0x3ff8,0x0000,0x0000,0xfffe,
  0x0f80,0x0001,0xffff,0x0f80,0x0001,0xf83f,0x0f80,0x0001,
  0xf83f,0x0f80,0x0000,0x703f,0x1fc0,0x0000,0x707f,0x1fc0,
  0x0000,0x00ff,0x1fc0,0x0000,0x01fc,0x5dc0,0x0000,0x03fc,
  0x7de0,0x0000,0x07fc,0xfde0,0x0000,0x0ff9,0xfde0,0x0000,
  0x1ff0,0xf8e0,0x0000,0x3fff,0xf8f0,0x0000,0x7fff,0xf8f0,
  0x0000,0xffff,0x98f0,0x0001,0xffff,0x8000,0x0000,0x0000,
  0x0000,0x01ff,0x0001,0x8f80,0x01fe,0x0000,0x8f80,0x01fe,
  0x0000,0x8f80,0x01e0,0x0000,0x8f80,0x01e0,0x8000,0xdfc0,
  0x01e0,0x8000,0xdfc0,0x01e0,0xf000,0xdfc0,0x01e0,0xf001,
  0xddc0,0x01e0,0xf001,0xfde0,0x01e0,0xf001,0xfde0,0x01e0,
  0xf005,0xfde0,0x01e1,0xe008,0xf8e0,0x01ff,0xc000,0x78f0,
  0x01ff,0x8000,0x78f0,0x01ff,0x0000,0x78f0,0x0000,0x0000,
  0x0000 /* 2.5.28 rri */
};

struct Image SelectRender=
{
 0,0,
 48,17,
 3,
 &SelectRenderData[0],
 7,0,
 NULL
};

struct DiskObject do_dm_config=
 {
  WB_DISKMAGIC,
  WB_DISKVERSION,
   { /* Embedded Gadget Structure */
    NULL, /* Next Gadget Pointer */
    0,    /* LeftEdge */
    0,    /* TopEdge */
    48,   /* Width */
    17,   /* Height */
    GFLG_GADGHIMAGE|GFLG_GADGIMAGE, /* Flags */
    GACT_IMMEDIATE|GACT_RELVERIFY, /* Activation */
    GTYP_BOOLGADGET, /* GadgetType */
    (APTR)&RenderImage, /* GadgetRender */
    (APTR)&SelectRender, /* SelectRender */
    NULL, /* *GadgetText */
    0, /* MutualExclude */ /* 2.5RC4 rri vbcc */
    NULL, /* SpecialInfo */
    0, /* GadgetID */
    NULL /* UserData */
   },
  WBPROJECT, /* Icon Type */
  "", /* Default Tool */
  NULL, /* Tool Type Array */
  NO_ICON_POSITION, /* Current X */
  NO_ICON_POSITION, /* Current Y */
  NULL, /* Drawer Structure */
  NULL, /* Tool Window */
  9000 /* Stack Size */
 };
#endif


/* 2.5.23 rri */
void SaveMenus(UBYTE *savebuffer);
void SaveScreen(UBYTE *savebuffer);
void SaveWindows(UBYTE *savebuffer);
void SaveWin(struct DirWindow *dw,UBYTE *savebuffer);
void SaveColors(UBYTE *savebuffer);  /* 2.6 jjt */


void Catsbuff(UBYTE *xxxx) /* 2.5RC8 rri */
{
DMstrcat(sbuff,xxxx);
}


void FillSaveBuffer(UBYTE *savebuffer) /* 2.5b7 rri */
{
 sprintf(savebuffer,";%s\nReset\n",Version); /* 2.5.24 rri */
 SaveScreen(savebuffer);
 SaveWindows(savebuffer);
 SaveMenus(savebuffer);
 if(FLAGS&DMFLAG_EXPAND) DMstrcat(savebuffer,"\nExpand ON\n"); /* 2.5RC2 rri */
}


BOOL SaveConfig()
{
BOOL  savesuccess=FALSE;
UBYTE *buf=ActionArgs[1];
BPTR fh;
sFIB  destfib; /* 2.5.24 rri */
ULONG icon,
      n=1,
      warn; /* 2.5.24 rri */

icon=GetActionArg("ICON",AATYPE_BOOL,0); /* 2.5b7 rri */
warn=GetActionArg("WARN",AATYPE_BOOL,0); /* 2.5.24 rri */

if(!buf||*buf==0||icon==1||warn==1) /* 2.5.24 rri */
 {
  if(AslBase) /* 2.5.24 rri */
   {
    buf = DMFileReq(Strap,0,TRUE); /* 2.5.27 rri */
   }
  else
   {
    struct TagItem safetags[]={{DMREQ_BUTTONS,(ULONG) g_buttons},{TAG_END,0}}; /* 2.5.26 rri */

    MakeBtnString(0, msgGadIcon, 0); /* 2.5b13 rri */

    if(Strap) /* 2.6 rri */
     {
      strcpy(sbuff,Strap);
     }
    else
     {
      strcpy(sbuff,"Startup.DM");
     }
    buf = sbuff;

    n=DMReqTagList(msgReqSave, buf, 128, safetags); /* 2.5.26 rri */
   }
 }

if(*buf) /* 2.6 rri */
 {
  if(Strap) PoolFreeVec(Strap);
  if ((Strap = CloneStr(buf,StringPool)))
   {
    buf=Strap;
   }
  else
   {
    n=0;
   }
 }
else
 {
  n=0;
 }

if(n)
 {
  if(warn) /* 2.5.24 rri */
   {
    if((fh=Lock(buf,ACCESS_READ)))
     {
      Examine(fh,&destfib);
      UnLock(fh);
      if(REQ_FileExists(0,&destfib)==0) return FALSE;  /* 2.6 jjt (added FALSE) */
     }
   }
  if(!GetGlobuff()) return FALSE; /* 2.5b7 rri */  /* 2.6 jjt (added FALSE) */
  if((fh=Open(buf,MODE_NEWFILE))) /* 2.5.23 gcc rri */
   {
    FillSaveBuffer(Globuff); /* 2.5b7 rri */
    Write(fh,Globuff,(ULONG) strlen(Globuff)); /* 2.5b10 rri */
    Close(fh);
    savesuccess = TRUE;  /* 2.6 jjt */
    SmartAddEntry(buf);
    if(icon||n==2) /* 2.5b13 rri */
     {
      struct DiskObject *doodels; /* 2.7b9 rri */

      strcpy(sbuff,ProgName); /* 2.5RC9 rri */

      /* 2.5b9 rri */
      doodels = GetDefDiskObject(WBPROJECT);

      if (doodels)
      {
       doodels->do_DefaultTool=FilePart(sbuff);
       PutDiskObject(buf,doodels);
       sprintf(sbuff,"%s.info",buf);
       SmartAddEntry(sbuff);
       FreeDiskObject(doodels);
      }

/*
      do_dm_config.do_DefaultTool=FilePart(sbuff);
      PutDiskObject(buf,&do_dm_config);
      sprintf(sbuff,"%s.info",buf);
      SmartAddEntry(sbuff);
*/

     } /* if (Icon)... */
   } /* if (fh=... */
 } /* if(n)... */

return savesuccess;  /* 2.6 jjt */
}


void SaveScreen(UBYTE *savebuffer)
{
UBYTE *ptr;
ULONG i; /* 2.5.23 gcc rri */
struct DrawInfo *dri;

ptr=sbuff;

if (DMP_UseHostScreen)  /* 2.6 jjt */
 {
  sprintf(sbuff, "HostScreen %s\n", DMP_HostScreen);
  DMstrcat(savebuffer,sbuff);
 }
else /* 2.6 jjt */
 {
  DMstrcat(savebuffer,"Pens"); /* 2.5RC8 rri */
  if((dri=GetScreenDrawInfo(Screen))) /* 2.5.23 gcc rri */
   {
    for(i=0;i<(dri->dri_NumPens);i++)
     {
      /* the cast is necassary as SAS-C won't work with %u only */
/*      sprintf(ptr," %lu",(ULONG) dri->dri_Pens[i]);*/ /* 2.5.23 gcc rri */
      sprintf(ptr," %lu",(ULONG) (DMP_PensModified ? Pens20[i] : dri->dri_Pens[i]) ); /* 2.7 jjt rri */
      ptr+=strlen(ptr); /* 2.5b12 rri */
     }
    FreeScreenDrawInfo(Screen,dri);
    sprintf(ptr,"\n"); /* 2.5b12 rri */
    DMstrcat(savebuffer,sbuff);
   }

  sprintf(sbuff,"NewScreen ID=%lu D=%lu W=%lu H=%lu F=\"%s\" FS=%lu\n",
          Screen_ID, (ULONG) Screen_Depth, Screen_Width, Screen_Height,
          DMP_Screen_Font, DMP_Screen_FontSz);  /* 2.6 jjt */
  DMstrcat(savebuffer,sbuff);

  SaveColors(savebuffer);  /* 2.6 jjt */
 }

/* 2.5RC2 jjt */
strcpy(sbuff, "Font");
for (i=DMFONTS_MAIN; i < DMFONTS_SCREEN; i++)
 {
  if (DMFonts[i])
   {
    sprintf(sbuff,"%s %s=\"%s\" %ld",sbuff,FontKeywords[i],GetTFName(DMFonts[i]),(LONG) DMFonts[i]->tf_YSize); /* 2.5.23 gcc rri */  /* 2.6 jjt */
   }
 }
Catsbuff("\n"); /* 2.5RC8 rri */
DMstrcat(savebuffer, sbuff);


sprintf(sbuff,"SetX BPen=%ld DPen=%ld FPen=%ld SPen=%ld",
                    BackPen,DirPen,FilePen,SelectPen);  /* 2.5b12 rri */

if(digits!=5) /* 2.5.24 */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," digits=%ld",digits);
 }

if(Notify) /* 2.5b12 rri */
 {
  Catsbuff(" Notify"); /* 2.5RC8 rri */
 }

if(FLAGS & DMFLAG_TIMEPLUS) /* 2.6 rri */
 {
  Catsbuff(" TimePlus");
 }

if(FLAGS & DMFLAG_LONGCMD) /* 2.6 rri */
 {
  Catsbuff(" LongCmd");
 }

/*if(DMP_UseWinScale && defx && defy && (defx==Screen_Width) && (defy==Screen_Height) )*/ /* 2.6 rri */
/*
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," defx=%ld defy=%ld",defx,defy);
 }
*/
if(DMP_UseWinScale) /* 2.6 jjt */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," defx=%ld defy=%ld", (LONG) Screen->Width, (LONG) Screen->Height); /* 2.6 rri - warnings with GCC4... */
 }

if(IconX!=(LONG) NO_ICON_POSITION) /* 2.5.23 gcc rri */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," IconX=%ld",IconX);
 }

if(IconY!=(LONG) NO_ICON_POSITION) /* 2.5.23 gcc rri */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," IconY=%ld",IconY);
 }

if(AppIconPath&&(Stricmp(AppIconPath,ProgName)!=0)) /* 2.5.26 rri */
 {
  Catsbuff(" AppIcon="); /* 2.5RC8 rri */
  Catsbuff(AppIconPath); /* 2.5RC8 rri */
 }

if(UserColors>4) /* 2.5b12 rri */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," UserColors=%ld",UserColors);
 }

if(sizes>1) /* 2.5RC8 rri */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," sizes=%ld",sizes);
 }

if(separator!=0x2e) /* 2.5RC8 rri */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr," separator=%ld",separator);
 }

if (wheel_multiply != 3)  /* 2.6 jjt */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr, " WheelMult=%ld", wheel_multiply);
 }

#ifndef __amigaos4__ /* 2.7 rri - obsolete with Reaction */
if (drag_delay != 5000)  /* 2.6 jjt */
 {
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr, " DragDelay=%ld", drag_delay / 1000);
 }
#endif

if ( (Stricmp(DiskMaster2Guide, "PROGDIR:DiskMaster2.guide") ) != 0) /* 2.6 jjt */
{
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr, " Guide=\"%s\"", DiskMaster2Guide);
}

if (Req_ShowHelpBtn == FALSE)  /* 2.6 jjt */
{
  ptr=sbuff+strlen(sbuff);
  sprintf(ptr, " ReqHideHelp");
}

Catsbuff("\n\n"); /* 2.5RC8 rri */
DMstrcat(savebuffer,sbuff);
}

/* 2.5RC10 rri */
void SaveMenus(UBYTE *savebuffer)
{
struct Menu *menu=DMMenu;
struct MenuItem *item;
struct IntuiText *itext;
UBYTE *ptr,*ptr2,cmd[4],c;
STRPTR ptr3; /* 2.6 rri */
ULONG i;

while(menu)
 {
  item=menu->FirstItem;
  ptr=menu->MenuName;
  while(item)
   {
    itext=(struct IntuiText *)item->ItemFill;
    ptr2=itext->IText;

    ptr3 = GTMENUITEM_USERDATA(item); /* 2.5b5 hys */
    if(ptr3 == NM_BARLABEL)
     {
      sprintf(sbuff, "AddMenu %s, BARLABEL,\n", ptr);
     }
    else
     {
      c=item->Command;
      cmd[0]=cmd[3]=0;
      cmd[1]=',';
      cmd[2]=' ';
      if(c) cmd[0]=c;
      sprintf(sbuff,"AddMenu %s, %s, %s%s\n",ptr,ptr2,cmd,ptr3);
     }
    DMstrcat(savebuffer,sbuff);
    item=item->NextItem;
   }
  menu=menu->NextMenu;
  DMstrcat(savebuffer,"\n");
 }

for(i=0;i<255;i++)
if((ptr=AutoCmdStr[i])) /* 2.5.23 gcc rri */
 {
  sprintf(sbuff,"AddAutoCmd %s\n",ptr);
  DMstrcat(savebuffer,sbuff);
 }

DMstrcat(savebuffer,"\n");

for(i=0;i<100;i++)
if((ptr=KeyCmdStr[i])) /* 2.5.23 gcc rri */
 {
  sprintf(sbuff,"AddKeyCmd %s\n",ptr);
  DMstrcat(savebuffer,sbuff);
 }
}


/* 2.5RC10 rri */
void SaveWindows(UBYTE *savebuffer)
{
struct DirWindow *dw;
ULONG i;

sprintf(sbuff,"Button \"%s\"\nSetFormat \"%s\"\nBarFormat \"%s\"\nTitleFormat \"%s\"\n",
        PGadStr,DispFormat,BarFormat,TitleFormat);
DMstrcat(savebuffer,sbuff);

/* DevList - 2.5.30 jjt*/
if (ShowDev != SHOWDEV_ALL) {
  sprintf(sbuff, "DevList%s%s%s\n", (ShowDev & SHOWDEV_DEV) ? " DEV" : "",
                                    (ShowDev & SHOWDEV_VOL) ? " VOL" : "",
                                    (ShowDev & SHOWDEV_ASN) ? " ASN" : "");
  DMstrcat(savebuffer, sbuff);
}

/* HideDev - 2.5.30 jjt*/
if (DevHide_Count) {
  strcpy(sbuff, "HideDev ");
  for (i=0; i < DevHide_Count; i++) {
    DMstrcat(sbuff, DevHide_List[i]);
    DMstrcat(sbuff, ": ");
    if (((strlen(sbuff)) > 80) && (i+1 < DevHide_Count)) {  /* Prevent line from getting too long. */
      DMstrcat(sbuff, "\n");
      DMstrcat(savebuffer, sbuff);
      strcpy(sbuff, "HideDev ADD ");
    }
  }
  DMstrcat(sbuff, "\n");
  DMstrcat(savebuffer, sbuff);
}

DMstrcat(savebuffer, "\n"); /* 2.5.30 jjt */

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&!(dw->Flags&DW_CMD)) /* dir-windows first */
   {
    SaveWin(dw,savebuffer);
   }
 }

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&dw->Flags&DW_CMD) /* now cmd-windows */
   {
    SaveWin(dw,savebuffer);
   }
 }
}


/* 2.5RC10 rri */
void SaveWin(struct DirWindow *dw,UBYTE *savebuffer)
{
struct DirList **dl,*dlp;
UBYTE *ptr2="\n"; /* 2.5RC6 rri */
LONG j; /* 2.5.23 rri */
UBYTE sorts[8]="NSDCEF"; /* 2.5.24 rri */
UBYTE *ptr; /* 2.5.24 rri */

if(dw->Flags&DW_SOURCE) ptr2="Lock S\n\n"; /* 2.5.24 rri */
if(dw->Flags&DW_DEST  ) ptr2="Lock D\n\n"; /* 2.5.24 rri */

DMstrcat(savebuffer,"OpenWindow");

if(dw->Flags&DW_CMD)
 {
  DMstrcat(savebuffer," CMD");
 }
else
 {
  if(dw->Path[0])
   {
    sprintf(sbuff," Path=\"%s\"",dw->Path); /* 2.5RC6 rri */
    DMstrcat(savebuffer,sbuff);
   }
 }

if(!(dw->Window->Flags&WFLG_CLOSEGADGET))
 {
  DMstrcat(savebuffer," NOCLOSE");
 }
if(!(dw->Window->Flags&WFLG_DRAGBAR))
 {
  DMstrcat(savebuffer," NODRAG");
 }

/* the casts are necassary as SAS-C won't work with %d only... */
sprintf(sbuff," Left=%ld Top=%ld Width=%ld Height=%ld"
              " ZoomL=%ld ZoomT=%ld ZoomW=%ld ZoomH=%ld",
       (LONG)dw->norm[0],(LONG)dw->norm[1],(LONG)dw->norm[2],(LONG)dw->norm[3], /* 2.5.23 rri */
       (LONG)dw->zoom[0],(LONG)dw->zoom[1],(LONG)dw->zoom[2],(LONG)dw->zoom[3]); /* 2.5.23 rri */

Catsbuff(((dw->Window->Flags&WFLG_ZOOMED) ? " Zoomed\n" : "\n")); /* 2.5RC8 rri */
DMstrcat(savebuffer,sbuff);

/* 2.5.24 rri */
if(!(dw->Flags&DW_CMD))
 {
  sprintf(sbuff,"Sort ");
  ptr=sbuff+strlen(sbuff);
  ptr[1]=0;
  ptr[2]=0;
  ptr[3]=0;
  ptr[4]=0;
  ptr[0]=sorts[dw->Sorting/2];
  if(dw->Sorting%2)
   {
    ptr[1]='-';
   }
  Catsbuff("\n");
  DMstrcat(savebuffer,sbuff);
 }

DMstrcat(savebuffer,ptr2);

if(dw->Flags&DW_CMD)
 {
  dl=dw->DirList;
  for(j=0;j<dw->FileCount;j++)
   {
    dlp=dl[j];
    if(dlp->name) /* 2.5.24 rri */
     {
      #ifdef __amigaos4__ /* 2.7b10 rri */
      sprintf(sbuff,"AddCmd %s, %lx%lx, %s\n",dlp->name,
      dlp->attr&0xf,(dlp->attr>>4)&0xf,dlp->cmt);
      #else
      /* 2.5b12 rri */
      sprintf(sbuff,"AddCmd %s, %lx%lx, %lx%lx, %s\n",dlp->name,
      dlp->attr&0xf,(dlp->attr>>4)&0xf,(dlp->attr>>8)&0xf,(dlp->attr>>12)&0xf,
      dlp->cmt);
      #endif
     }
    else /* 2.5.24 rri */
     {
      sprintf(sbuff,"AddCmd #\n"); /* 2.6 rri */
     }
    DMstrcat(savebuffer,sbuff);
   }
  DMstrcat(savebuffer,"\n");
 }
}


void SaveColors(UBYTE *savebuffer)  /* 2.6 jjt */
{
  UBYTE *sptr;
  ULONG cmax, cidx=0, tblidx=1, r, g, b, i;

  /* --- Save the colormap  ---*/
  cmax = 1 << (min(Screen_Depth, 8));
  GetRGB32(Screen->ViewPort.ColorMap, 0, cmax, &(DMP_ColorTable32[1]));

  while (cidx < UserColors)
  {
    sptr = sbuff;
    sprintf(sbuff, "Color OFFSET=%ld", cidx);
    sptr += strlen(sbuff);

    for(i=0; (i < 8) && (cidx < UserColors); i++, cidx++)
    {
      r = DMP_ColorTable32[tblidx++] >> 24;
      g = DMP_ColorTable32[tblidx++] >> 24;
      b = DMP_ColorTable32[tblidx++] >> 24;

      #ifdef __SASC /* SAS-C prints no leading zero's unless being told so */
        sprintf(sptr, " %02.2lx%02.2lx%02.2lx", r, g, b);
      #else         /* GCC prints leading zeros and gives a warning with the above */
        sprintf(sptr, " %2.2lx%2.2lx%2.2lx", r, g, b);
      #endif
      sptr += 7;
    }
    *sptr++ = '\n';
    *sptr = 0;

    DMstrcat(savebuffer, sbuff);
  }
}


void Iconify(void) /* 2.5b7 rri */
{
struct AppIcon *appicon;
struct AppMessage *appmsg;
struct RexxMsg *rexxmsg;
int loop=1;
struct DiskObject *diskobj=0; /* 2.5b13 rri */

if(FLAGS&DMFLAG_BATCH) /* 2.5RC2 rri */
 {
  return; /* 2.5b13 rri */
 }

FLAGS|=DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */

#ifdef __amigaos4__ /* 2.5.31 rri */
if (LibOpen("workbench", &WorkbenchBase, 44, (uint32) &IWorkbench)) /* 2.5.31 rri */
#else
if (LibOpen("workbench", &WorkbenchBase, 39)) /* 2.5.31 rri */
#endif
 {
  if (RememberDMClose())  /* 2.6 jjt */
   {
    if(IconBase->lib_Version >= 44)
     {
      diskobj = GetIconTags(AppIconPath,
                           ICONGETA_FailIfUnavailable, FALSE, /* 2.5.26 rri */
                           TAG_DONE,0);
     }
    else
     {
      diskobj=GetDiskObjectNew(AppIconPath); /* 2.5.26 rri */
     }

    if(diskobj != 0)
     {
      diskobj->do_CurrentX = IconX; /* 2.5RC2 rri */
      diskobj->do_CurrentY = IconY; /* 2.5RC2 rri */

      appicon=AddAppIconA(0,0,DMname,WinPort,0,diskobj,0); /* 2.7b9 rri */

      if(appicon != NULL) /* 2.5.30 rri - only iconify if WB actually is open... */
       {
        while(loop) /* 2.5b9 rri */
         {
          WaitPort(WinPort);

          while((appmsg=(struct AppMessage *) GetMsg(WinPort))) /* 2.5.23 gcc rri */
           {
            if(RexxSysBase&&IsRexxMsg((struct Message *) appmsg)) /* 2.5.30 rri  */
             {
              rexxmsg=(struct RexxMsg *)appmsg;
              if(Strnicmp("QUIT",rexxmsg->rm_Args[0],4)==0) /* 2.5RC6 rri */
               {
                FLAGS&=~DMFLAG_KEEPGOING; /* 2.5RC2 rri */
                loop=2;
               }
              else if(Strnicmp("WAKE",rexxmsg->rm_Args[0],4)!=0) /* 2.5RC6 rri */
               {
                ReplyMsg((struct Message *)appmsg); /* 2.5b13 rri */
                continue;
               }
             }
            ReplyMsg((struct Message *)appmsg); /* 2.5b13 rri */

            while((appmsg=(struct AppMessage *)GetMsg(WinPort))) /* 2.5.23 gcc rri */
             {
              ReplyMsg((struct Message *)appmsg);
             }

            RemoveAppIcon(appicon);
            if(loop==1)
             {
              RememberDMOpen();
             }
            loop=0;
           }
         }
       }
      FreeDiskObject(diskobj); /* 2.7b9 rri */
     } // if (diskobj != 0)...
    else /* 2.7b9 rri - if we can't even get a default icon something is wrong, probably the */
    {    /* system ran out of memory - so we just quit here */
     FLAGS&=~DMFLAG_KEEPGOING;
    }
   }
 }

//do_dm_config.do_CurrentX = NO_ICON_POSITION; /* 2.5b9 rri */
//do_dm_config.do_CurrentY = NO_ICON_POSITION; /* 2.5b9 rri */
}


BOOL RememberDMClose()  /* 2.6 jjt */
{
  BOOL success = FALSE;

  FLAGS|=DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */

  if (GetGlobuff())
  {
    FillSaveBuffer(Globuff);

    if(!CmdWin) /* 2.5b13 rri */
    {
      FindCmdWin();
    }
    if(CmdWin) /* 2.5b13 rri */
    {
      strcpy(dcPath,CmdWin->Path);
    }

    FreeUserData(); /* 2.5RC10 rri */

    success = TRUE;
  }
  else
  {
    FLAGS&=~DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */
  }

  return success;
}


void RememberDMOpen()  /* 2.6 jjt */
{
  FLAGS|=DMFLAG_BATCH; /* 2.5RC2 rri */

  ActionCmd(254,Globuff); /* 2.5RC10 rri */

  FLAGS&=~DMFLAG_BATCH; /* 2.5RC2 rri */
  DMLayoutMenus(); /* 2.5RC10 rri */
  FindCmdWin();
  /* AddPort(WinPort);*/ /* 2.7 rri */ /* port is removed by FreeUserData() */ /* 2.5RC10 rri */

  FLAGS&=~DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */

  if (!MyScreen)  /* 2.6 jjt */
  {
    ScreenToFront(Screen);
  }
}

