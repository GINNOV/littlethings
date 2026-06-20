/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     AGD.h
** FUNKTION:  Haupt-Includefile für AmigaGuideDesigner mit allen globalen Variablen,
**            Prototypen und Library-Includes
**
*/

#ifndef AGDPREFS_AGDPREFS_H
#define AGDPREFS_AGDPREFS_H

/* Includes, Prototypes & Pragmas */
#define INTUI_V36_NAMES_ONLY
#define ASL_V38_NAMES_ONLY
#define IFFPARSE_V37_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <exec/ports.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <libraries/iffparse.h>
#include <libraries/reqtools.h>
#include <prefs/prefhdr.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <devices/inputevent.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>

#ifdef DEBUG
#include <stdio.h>
#define DEBUG_PRINTF(a) printf(a)
#else
#define DEBUG_PRINTF(a)
#endif

#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/asl_protos.h>
#include <clib/icon_protos.h>
#include <clib/wb_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/reqtools_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/diskfont_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/reqtools_pragmas.h>

/* Defines */
/* ASCII-Codes */
#define EOL            ('\n')    /* ==0x1a==26 */
#define EOS            ('\0')    /* ==0x00==0  */

/* Gadget-Extreme */
#define STRMAXCHARS    1024
#define NUMMAXCHARS    7

/* CommTypes */
#define COMT_LINK      0
#define COMT_ALINK     1
#define COMT_RX        2
#define COMT_RXS       3
#define COMT_SYSTEM    4
#define COMT_CLOSE     5
#define COMT_QUIT      6
#define COMT_STYLE     7

/* Colors */
#define COL_TEXT       0
#define COL_SHINE      1
#define COL_SHADOW     2
#define COL_FILL       3
#define COL_FILLTEXT   4
#define COL_BG         5
#define COL_HIGHL      6

/* verschiedene Versionen */
#define PROGNAME  "AmigaGuideDesigner Preferences"
#define SPROGNAME "AGDPrefs"
#define VERSION   "0"
#define REVISION  "50"
#define YEARS     "1994-1996"

/* Strukturen */
struct FileRD {
               char  *Path;
               char  *Title;
               ULONG  Flags1;
               ULONG  Flags2;
              };

struct FontRD {
               struct TextAttr Font;
               char  *Title;
               ULONG  Flags;
              };

struct ScreenRD {
                 char  *Title;

                 ULONG  DisplayID;
                 ULONG  Width;
                 ULONG  Height;
                 UWORD  Depth;
                 UWORD  Overscan;
                 BOOL   AutoScroll;
                };

/* GadgetDaten für CreateGadgetList */
struct GadgetData {
                   char  *GadgetText;
                   WORD   LeftEdge;
                   WORD   TopEdge;
                   WORD   Width;
                   WORD   Height;
                   ULONG  Flags;
                   ULONG  GadgetID;
                   ULONG  Type;
                   struct TagItem *Tags;
                   struct Gadget *Gadget;
                  };

/* Separator-Höhe */
#define SEPHEIGHT           2

/* SeperatorDaten für DrawSeparators */
struct SepData {
                WORD LeftEdge;
                WORD TopEdge;
                WORD Width;
               };

struct ProgScreen {
                   struct Screen   *ps_Screen;
                   struct DrawInfo *ps_DrawInfo;
                   void            *ps_VisualInfo;
                   struct TextFont *ps_ScrFont;
                   struct RastPort  ps_DummyRPort;

                   char            *ps_Title;
                   UWORD            ps_WBorTop;

                   struct TextAttr  ps_ScrAttr;
                  };

#define PREFSVERSION      0

#define DATAB_AGUIDEPATH  0
#define DATAB_AGUIDENAME  1
#define DATAB_MODENUM     2

struct AGDPrefsP {
                  BOOL  MainWin;
                  WORD  MainWLeft;
                  WORD  MainWTop;
                  BOOL  ProjSetWin;
                  WORD  ProjSetWLeft;
                  WORD  ProjSetWTop;
                  BOOL  DocsSetWin;
                  WORD  DocsSetWLeft;
                  WORD  DocsSetWTop;
                  BOOL  CommSetWin;
                  WORD  CommSetWLeft;
                  WORD  CommSetWTop;
                  BOOL  MiscSetWin;
                  WORD  MiscSetWLeft;
                  WORD  MiscSetWTop;
                  BOOL  ScrSetWin;
                  WORD  ScrSetWLeft;
                  WORD  ScrSetWTop;

                  WORD  FileRLeft;
                  WORD  FileRTop;
                  WORD  FileRWidth;
                  WORD  FileRHeight;
                  WORD  FontRLeft;
                  WORD  FontRTop;
                  WORD  FontRWidth;
                  WORD  FontRHeight;
                  WORD  ScrMRLeft;
                  WORD  ScrMRTop;
                  WORD  ScrMRWidth;
                  WORD  ScrMRHeight;
                  WORD  ListRLeft;
                  WORD  ListRTop;
                  WORD  ListRWidth;
                  WORD  ListRHeight;

                  BOOL  CrIcons;
                  BOOL  ReqMode;

                  BOOL  RTFileReq;
                  BOOL  RTFontReq;
                  BOOL  RTScrMReq;
                  BOOL  RTEasyReq;

                  BOOL  DefaultFont;

                  char *Pattern;
                  char *PubScreenName;
                 };

struct ProjP {
              char  *AGuidePath;
              char  *Database;
              char  *Copyright;
              char  *Master;
              char  *Index;
              char  *Author;
              char  *Version;
              char  *FontName;
              char  *Help;
              UBYTE  DatabaseMode;
              UWORD  FontSize;
              BOOL   WordWrap;
             };

struct DocsP {
              char *NodeName;
              char *WinTitle;
              char *NextNodeName;
              char *PrevNodeName;
              char *TOCNodeName;
              char *FileName;
             };

struct CommP {
              ULONG  CommTypeLVRows;
              UBYTE  CommType;
              char  *StrData;
              UBYTE  FGPen;
              UBYTE  BGPen;
              UBYTE  Style;
             };

struct MiscP {
              char *Editor;
              char *TmpDocFileName;
              BOOL  CrIcons;
              BOOL  RTFileReq;
              BOOL  RTFontReq;
              BOOL  RTEasyReq;
              char *Pattern;
             };

struct ScrP {
             BOOL   CustomScreen;

             ULONG  DisplayID;
             ULONG  Width;
             ULONG  Height;
             UWORD  Depth;
             UWORD  Overscan;
             BOOL   AutoScroll;

             char  *PubScreenName;

             struct TextAttr PrintAttr;
             struct TextAttr ScrAttr;
            };

/* Makros */
#define GetString( g ) ((( struct StringInfo * )g->SpecialInfo )->Buffer  )
#define GetNumber( g ) ((( struct StringInfo * )g->SpecialInfo )->LongInt )

/* interne Prototypen */
/* Prefs.c */
void             InitAGDPrefs(void);
void             FreeAGDPrefs(void);
void             InitPrefs(void);
void             FreePrefs(void);
BOOL             LoadPrefs(char *);
BOOL             SavePrefs(char *);

/* ProgScreen.c */
void             FreeProgScreen(void);
BOOL             GetProgScreen(void);
void             BeepProgScreen(void);
void             ProgScreenToFront(void);

/* ProgMenus.c */
void             FreeProgMenus(void);
BOOL             CreateProgMenus(void);
void             HandleProgMenus(UWORD);
void             SetProgMenusStates(void);

/* MainWindow */
void             InitMainWin(void);
void             CloseMainWin(void);
BOOL             OpenMainWin(void);
void             GetMainWinPos(void);
void             HandleMainWinIDCMP(void);

/* ProjSetWin.c */
void             InitProjSetWin(void);
void             CloseProjSetWin(void);
BOOL             OpenProjSetWin(void);
void             GetProjSetWinPos(void);
void             UpdateProjSetWin(void);
void             HandleProjSetWinIDCMP(void);

/* DocsSetWin.c */
void             InitDocsSetWin(void);
void             CloseDocsSetWin(void);
BOOL             OpenDocsSetWin(void);
void             GetDocsSetWinPos(void);
void             UpdateDocsSetWin(void);
void             HandleDocsSetWinIDCMP(void);

/* CommSetWin.c */
void             InitCommSetWin(void);
void             CloseCommSetWin(void);
BOOL             OpenCommSetWin(void);
void             GetCommSetWinPos(void);
void             UpdateCommSetWin(void);
void             HandleCommSetWinIDCMP(void);

/* MiscSetWin.c */
void             InitMiscSetWin(void);
void             CloseMiscSetWin(void);
BOOL             OpenMiscSetWin(void);
void             GetMiscSetWinPos(void);
void             UpdateMiscSetWin(void);
void             HandleMiscSetWinIDCMP(void);

/* ScrSetWin.c */
void             InitScrSetWin(void);
void             CloseScrSetWin(void);
BOOL             OpenScrSetWin(void);
void             GetScrSetWinPos(void);
void             UpdateScrSetWin(void);
void             HandleScrSetWinIDCMP(void);

/* ListReq.c */
void             InitListReq(void);
LONG             OpenListReq(struct List *,LONG,char *);

/* ReqFuncs.c */
BOOL             OpenFileRequester(void);
BOOL             OpenFontRequester(void);
BOOL             OpenScrModeRequester(void);
ULONG            EasyRequester(struct Window *,char *,char *,APTR);
ULONG            EasyRequestAllWins(char *,char *,APTR);

/* IntuiFuncs.c */
struct Window   *GetValidWindow(void);
ULONG            DisableWindow(struct Window *,struct Requester *);
void             EnableWindow(struct Window *,struct Requester *,ULONG);
void             DisableAllWindows(void);
void             EnableAllWindows(void);
void             CloseAllWindows(void);
void             UpdateAllWindows(void);
struct Gadget   *CreateGadgetList(struct GadgetData *, UBYTE);
void             DrawSeparators(struct Window *,struct SepData *,UBYTE);
char             FindVanillaKey(const char *);
LONG             MatchVanillaKey(char,const char *);
void             DoStringCopy(char **,struct Gadget *);
 
/* MiscFuncs.c */
char            *mstrdup(const char *);
LONG             GetNodeNum(struct Node *);
struct Node *    GetNodeAddr(struct List *,LONG num);


/* globale Variablen */
extern struct Library      *SysBase;
extern struct Library      *DOSBase;
extern struct GfxBase      *GfxBase;
extern struct Library      *IntuitionBase;
extern struct Library      *DiskfontBase;
extern struct Library      *IconBase;
extern struct Library      *GadToolsBase;
extern struct Library      *AslBase;
extern struct Library      *WorkbenchBase;
extern struct Library      *IFFParseBase;
extern struct ReqToolsBase *ReqToolsBase;

extern struct FileRD        FileRD;
extern struct FontRD        FontRD;
extern struct ScreenRD      ScreenRD;

extern struct ASCIIText     ASCII;
extern struct AGuide        AGuide;
extern struct ProgScreen    Screen;
extern struct Menu         *Menus;
extern struct Window       *MainWin,*ProjSetWin,*DocsSetWin,*CommSetWin,*MiscSetWin,*ScrSetWin;
extern ULONG                MainBit,ProjSetBit,DocsSetBit,CommSetBit,MiscSetBit,ScrSetBit;

extern struct AGDPrefsP     AGDPrefsP;
extern struct WinPosP       WinPosP;
extern struct ProjP         ProjP;
extern struct DocsP         DocsP;
extern struct CommP         CommP;
extern struct MiscP         MiscP;
extern struct ScrP          ScrP;
extern struct Requester     BlockReq;

extern char                *ProjectName;
extern char                *PrefsName,*PrefsNameEnv,*PrefsNameEnvArc;
extern char                *PortName;

extern struct TagItem       UnderscoreTags[];

#endif

/* ======================================================================================= End of File
*/

