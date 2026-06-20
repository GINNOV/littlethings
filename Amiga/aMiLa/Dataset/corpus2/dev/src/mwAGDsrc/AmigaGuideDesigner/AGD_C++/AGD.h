/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     AGD.h
** FUNKTION:  Haupt-Includefile für AmigaGuideDesigner mit allen globalen Variablen,
**            Prototypen und Library-Includes
**
*/

#ifndef AGD_AGD_H
#define AGD_AGD_H

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
#include <graphics/gfxmacros.h>
#include <graphics/text.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/icclass.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <libraries/iffparse.h>
#include <libraries/reqtools.h>
#include <prefs/prefhdr.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <dos/notify.h>
#include <devices/inputevent.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include <stdarg.h>

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
#include <clib/utility_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/reqtools_protos.h>
#include <clib/alib_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/diskfont_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/utility_pragmas.h>
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

/* Bits und Flags für FormatPrefsString */
#define PSSEQ_AGUIDENAME    0
#define PSSEQ_AGUIDEPATH    1
#define PSSEQ_DATABASE      2
#define PSSEQ_COPYRIGHT     3
#define PSSEQ_AUTHOR        4
#define PSSEQ_VERSION       5
#define PSSEQ_MASTER        6
#define PSSEQ_INDEX         7
#define PSSEQ_NODENAME      8
#define PSSEQ_PREVNODE      9
#define PSSEQ_NEXTNODE      10
#define PSSEQ_FILENAME      11
#define PSSEQ_SEQNUM        12

#define PSSEQF_AGUIDENAME   (1L<<PSSEQ_AGUIDENAME)
#define PSSEQF_AGUIDEPATH   (1L<<PSSEQ_AGUIDEPATH)
#define PSSEQF_DATABASE     (1L<<PSSEQ_DATABASE)
#define PSSEQF_COPYRIGHT    (1L<<PSSEQ_COPYRIGHT)
#define PSSEQF_AUTHOR       (1L<<PSSEQ_AUTHOR)
#define PSSEQF_VERSION      (1L<<PSSEQ_VERSION)
#define PSSEQF_MASTER       (1L<<PSSEQ_MASTER)
#define PSSEQF_INDEX        (1L<<PSSEQ_INDEX)
#define PSSEQF_NODENAME     (1L<<PSSEQ_NODENAME)
#define PSSEQF_PREVNODE     (1L<<PSSEQ_PREVNODE)
#define PSSEQF_NEXTNODE     (1L<<PSSEQ_NEXTNODE)
#define PSSEQF_FILENAME     (1L<<PSSEQ_FILENAME)
#define PSSEQF_NOTHING      (0)

/* verschiedene Versionen */
#define PROGNAME  "AmigaGuideDesigner"
#define SPROGNAME "AGD"
#define VERSION   "0"
#define REVISION  "50"
#define YEARS     "1994-1996"

#define REOPEN_NOTHING      0
#define REOPEN_PREFSNAME    1
#define REOPEN_PREFSNAMEENV 2
#define REOPEN_WINPOSP      3

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

struct Command {
                struct MinNode  com_Node;

                WORD            com_Char;
                WORD            com_Len;

                UBYTE           com_Type;

                char           *com_StrData;

                UBYTE           com_FGPen;
                UBYTE           com_BGPen;
                UBYTE           com_Style;
               };

struct ASCIILine {
                  char   *al_Line;
                  UWORD   al_Len;
                 };
 
struct Document {
                 struct Node       doc_Node;

                 char             *doc_FileName;    

                 char             *doc_Buf;
                 char             *doc_BufEnd;
                 LONG              doc_BufLen;

                 struct ASCIILine *doc_Lines;
                 ULONG             doc_LinesBufLen;
                 LONG              doc_NumLn;
                 LONG              doc_MaxCol;

                 char             *doc_WinTitle;
                 char             *doc_NextNode;
                 char             *doc_PrevNode;
                 char             *doc_TOCNode;

                 struct MinList   *doc_Comms;
                 ULONG             doc_CommsBufLen;
                 struct Command   *doc_CurComm;
                };

struct AGuide {
               struct List      gt_Docs;
               struct Document *gt_CurDoc;
               LONG             gt_CurSel;

               char            *gt_Database;
               char            *gt_Author;
               char            *gt_Copyright;
               char            *gt_Version;
               char            *gt_Master;
               char            *gt_Font;
               UWORD            gt_FoSize;
               char            *gt_Index;
               char            *gt_Help;

               char            *gt_Name;

               BOOL             gt_WordWrap;
              };

struct ProgScreen {
                   struct Screen   *ps_Screen;
                   struct DrawInfo *ps_DrawInfo;
                   void            *ps_VisualInfo;
                   struct TextFont *ps_ScrFont;
                   struct TextFont *ps_PrintFont;
                   struct RastPort  ps_DummyRPort;
                   struct RastPort  ps_PDummyRPort;

                   char            *ps_Title;
                   UWORD            ps_WBorRight;
                   UWORD            ps_WBorBottom;
                   UWORD            ps_WBorTop;

                   BYTE             ps_PubSig;
                  };

#define PREFSVERSION      0

#define PREFSMODE_PROGPREFS 1
#define PREFSMODE_WINPOS    2

struct PrefsPaths {
                   char *PrefsName;
                   char *PrefsNameEnv;
                   char *PrefsNameEnvArc;
                   char *WinPosP;
                   char *WinPosPEnv;
                   char *WinPosPEnvArc;
                  };

struct WinPosP {
                BOOL ProjWin;
                WORD ProjWLeft;
                WORD ProjWTop;
                BOOL DocsWin;
                WORD DocsWLeft;
                WORD DocsWTop;
                WORD DocsWHeight;
                BOOL EditWin;
                WORD EditWLeft;
                WORD EditWTop;
                WORD EditWWidth;
                WORD EditWHeight;
                BOOL CommWin;
                WORD CommWLeft;
                WORD CommWTop;
                WORD CommWWidth;
                WORD CommWHeight;

                WORD FileRLeft;
                WORD FileRTop;
                WORD FileRWidth;
                WORD FileRHeight;
                WORD FontRLeft;
                WORD FontRTop;
                WORD FontRWidth;
                WORD FontRHeight;
                WORD ListRLeft;
                WORD ListRTop;
                WORD ListRWidth;
                WORD ListRHeight;
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

#define GetCommVecLnTail(doc,ln) ((struct Command *)((doc)->doc_Comms[ln].mlh_TailPred))
#define GetCommVecLnHead(doc,ln) ((struct Command *)((doc)->doc_Comms[ln].mlh_Head))
#define GetCommVecLn(doc,ln) (&(doc)->doc_Comms[ln])

/* interne Prototypen */
/* ASCII.c */
void             FreeASCIIText(struct Document *);
BOOL             LoadASCIIText(struct Document *,char *);
BOOL             SaveASCIIText(struct Document *,char *);
BOOL             EditASCIIText(struct Document *,struct MsgPort *);

/* AGuide.c */
BOOL             InitAGuide(void);
void             FormatAGuidePrefsStrings(void);
void             FreeAGuide(void);
BOOL             LoadAGuide(void);
BOOL             SaveAGuide(void);

/* Document.c */
struct Document *DeleteDoc(struct Document *);
struct Document *InsertDoc(struct Document *);
void             FormatDocsPrefsStrings(struct Document *);
struct Document *ClearDoc(struct Document *);
struct Document *CopyDoc(struct Document *);
void             MoveDocFirst(struct Document *);
void             MoveDocLast(struct Document *);
BOOL             MoveDocUp(struct Document *);
BOOL             MoveDocDown(struct Document *);
LONG             GetDocNum(struct Document *);
struct Document *GetDocAddr(LONG);
void             FreeCommVector(struct Document *);
BOOL             AllocCommVector(struct Document *,LONG);

/* Command.c */
struct Command  *DeleteComm(struct Command *);
struct Command  *InsertComm(struct Document *,LONG,LONG,LONG);

/* Prefs.c */
void             InitPrefs(void);
void             FreePrefs(void);
BOOL             LoadPrefs(char *,UBYTE);
BOOL             SavePrefs(char *,UBYTE);

/* Project.c */
BOOL             LoadProject(void);
BOOL             SaveProject(void);

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

/* ProjWin.c */
void             UpdateProjWinTitle(void);
void             InitProjWin(void);
void             CloseProjWin(void);
BOOL             OpenProjWin(void);
void             GetProjWinPos(void);
void             SetProjWinPos(void);
void             UpdateProjWin(void);
void             HandleProjWinIDCMP(void);

/* DocsWin.c */
void             InitDocsWin(void);
void             CloseDocsWin(void);
BOOL             OpenDocsWin(void);
void             UpdateDocsWin(void);
void             GetDocsWinSize(void);
void             SetDocsWinSize(void);
void             HandleDocsWinIDCMP(void);

/* EditWin.c */
void             UnInitEditWin(void);
BOOL             InitEditWin(void);
void             CloseEditWin(void);
BOOL             OpenEditWin(void);
void             UpdateEditWin(void);
void             GetEditWinSize(void);
void             SetEditWinSize(void);
void             HandleEditWinIDCMP(void);

/* CommWin.c */
void             UnInitCommWin(void);
BOOL             InitCommWin(void);
void             CloseCommWin(void);
BOOL             OpenCommWin(void);
void             UpdateCommWin(void);
void             GetCommWinPos(void);
void             SetCommWinPos(void);
void             HandleCommWinIDCMP(void);

/* ListReq.c */
void             InitListReq(void);
LONG             OpenListReq(struct List *,LONG,char *);

/* ReqFuncs.c */
BOOL             OpenFileRequester(void);
BOOL             OpenFontRequester(void);
ULONG            EasyRequester(struct Window *,char *,char *,APTR);
ULONG            EasyRequestAllWins(char *,char *,...);

/* IntuiFuncs.c */
struct Window   *GetValidWindow(void);
ULONG            DisableWindow(struct Window *,struct Requester *);
void             EnableWindow(struct Window *,struct Requester *,ULONG);
void             DisableAllWindows(void);
void             EnableAllWindows(void);
void             CloseAllWindows(void);
void             UpdateAllWindows(void);
void             FixOpenWindows(void);
struct Gadget   *CreateGadgetList(struct GadgetData *, UBYTE);
void             DrawSeparators(struct Window *,struct SepData *,UBYTE);
char             FindVanillaKey(const char *);
LONG             MatchVanillaKey(char,const char *);
void             DoStringCopy(char **,struct Gadget *);
 
/* MiscFuncs.c */
char            *mstrdup(const char *);
char            *FormatPrefsString(const char *,struct Document *,ULONG);

/* globale Variablen */
extern struct Library      *SysBase;
extern struct Library      *DOSBase;
extern struct GfxBase      *GfxBase;
extern struct Library      *LayersBase;
extern struct Library      *IntuitionBase;
extern struct Library      *DiskfontBase;
extern struct Library      *IconBase;
extern struct Library      *GadToolsBase;
extern struct Library      *AslBase;
extern struct Library      *WorkbenchBase;
extern struct Library      *UtilityBase;
extern struct Library      *IFFParseBase;
extern struct ReqToolsBase *ReqToolsBase;

extern struct FileRD        FileRD;
extern struct FontRD        FontRD;

extern struct ASCIIText     ASCII;
extern struct AGuide        AGuide;
extern struct ProgScreen    Screen;
extern struct Menu         *Menus;
extern struct Window       *ProjWin,*DocsWin,*EditWin,*CommWin;
extern ULONG                ProjBit,DocsBit,EditBit,CommBit;

extern struct WinPosP       WinPosP;
extern struct ProjP         ProjP;
extern struct DocsP         DocsP;
extern struct CommP         CommP;
extern struct MiscP         MiscP;
extern struct ScrP          ScrP;
extern struct Requester     BlockReq;

extern struct PrefsPaths    PrefsPaths;
extern char                *ProjectName;
extern char                *PortName;
extern UBYTE                ReOpen;

extern struct TagItem       UnderscoreTags[];

#endif

/* ======================================================================================= End of File
*/

