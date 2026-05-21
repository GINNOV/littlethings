/* DiskMaster II Screen Module
**
** 2.5RC4
**
** 02-05-31 rri - various changes to make this module compile without
**                errors under vbcc
**
** 02-05-31 rri - Replaced GetDRI() call from InitScreenDefaults() by simple
**                init of BackPen/DirPen/FilePen/SelectPen - just looks better
**                in case DM2 is started without Startup.DM .
**
** 2.5RC9
**
** 03-01-25 rri - Replaced one memmove() cally by a CopyMem() call.
**
** 2.5RC10
**
** 03-03-15 rri - Added Pens20[] init to InitScreenDefaults()
**              - Removed some "new! ..." style comments.
**
** 03-03-16 rri - Added "SA_LikeWorkbench, TRUE," to DMOpenScreen()
**
** 03-04-11 rri - Removed "SA_LikeWorkbench, TRUE," again as it's not needed
**
** 2.5.23
**
** 03-05-30 rri - Removed a few GCC warnings.
**              - Needed or not, with "SA_LikeWorkbench, TRUE," the screen
**                looks better on start with the internal startup.
**              - Removed some dead code.
**
** 2.5.24
**
** 03-07-19 rri - Canceling the screenmode-requester won't open a cloned
**                WB screen anymore but just let DM2 open it's windows
**                on the WB or default pub-screen.
**                Suggested by Gerd Frank <Gerd.Frank@gmx.de>.
**
** 03-07-20 rri - DMFonts[DMFONTS_SCREEN] was not initialised when the screenmode
**                was selected from the mode-requester.
**
** 03-08-02 rri - Modified ParseScreenArgs(), if 'NewScreen' is used with an
**                invalid screen-mode-ID the WB's is used instead.
**
** 2.5.26
**
** 03-08-10 rri - Simplified InitScreenDefaults()
**              - Removed all comments from the top that were older
**                than a year (pre 2.5RC4)
**
** 2.5.28
**
** 03-12-20 rri - Bugfix: internal var "Bar_Height" was not updated when DM2 opened
**                        it's own screen -> window's top position could not
**                        be less than WB's bar-height +1.
**                        Thanks for reporting to: Alex Basana <ax.riez@biaccabi.com>!
**
** 2.5.31
**
** 04-10-12 rri - IntuitionBase is of type struct Library for OS4.
**
** 05-03-26 rri - Moved declaration of "FuckingTopaz" to here from DM.c.
**              - Renamed "FuckingTopaz" to "Default_TAttr".
**
** 05-09-06 jjt - InitScreenDefaults() - Also inits DMP_Screen_<x> vars.
**              - Bugfix:  InitScreenDefaults() - Initializing DMP_Screen_Depth is a good
**                idea, too.
**
** 05-09-07 jjt - Removed most of the DMP_Screen_<x> vars.
**              - InitScreenDefaults() - DMP_Screen_Font will only be initialized once,
**                the very first time InitScreenDefaults() is called..
**
** 05-10-05 jjt - DMOpenScreen() - Replaced a LoadRGB4() call with LoadRGB32().
**
** 05-11-22 rri - DMOpenScreen() - Added reading back of what we actually got for
**                Screen_ID, Screen_Width, Screen_Height and Screen_Depth to not get
**                fooled by screen-promotion.
**
** 2.7
**
** 06-02-05 rri - Added new global var initialised by InitScreenDefaults()
**                for OS4: vpadding
**
** 06-12-05 rri - Default_TAttr with Topaz is now only used in case the default
**                public screen couldn't be opened - which is very unlikely.
**              - Removed obsolete var "vpadding" and code for it again.
**
** b7
**
** 06-12-28 rri - Replaced Menu_TAttr with DMTextAttrs[DMFONTS_MENU].
**              - Replaced Screen_TAttr with DMTextAttrs[DMFONTS_SCREEN].
**              - Removed a few FontToAttr() calls, DMOpenFont() takes care of that now.
**
** b10
**
** 07-01-28 rri - Added a call to ClearScreen() to DMOpenScreen() as workaround for the problem
**                that P96 does seem to do so itself by default.
**
** b11
**
** 07-02-10 rri - Made the ClearScreen() call OS4 only.
**
**
*/

#include "DM.h"
#define AA      ActionArgs

#ifdef __amigaos4__ /* 2.5.31 rri */
extern struct Library *IntuitionBase;
#include <intuition/gui.h> /* 2.7 rri */
#else
extern struct IntuitionBase *IntuitionBase;
#endif

extern struct Library       *AslBase;
extern struct Screen        *Screen,*MyScreen;
extern struct MsgPort       *WinPort;
extern struct TextFont      *DMFonts[];  /* 2.5RC2 jjt */
extern struct TextAttr      DMTextAttrs[];  /* 2.7 rri */

extern UBYTE DMname[],Version[],*ActionArgs[],HostID[];

extern UWORD Pens20[];

extern LONG  DirPen, FilePen, BackPen, SelectPen; /* 2.5b12 rri */

extern ULONG UserCols, /* 2.5b10 rri */
             ColMap[], /* 2.6.1 jjt */
             DMP_Screen_FontSz;  /* 2.6 jjt */

extern APTR StringPool; /* 2.6 jjt */

extern STRPTR DMP_Screen_Font; /* 2.6 jjt */

LONG   Bar_Height; /* 2.5b10 rri */
UWORD  Screen_Depth;
ULONG  Screen_Width,Screen_Height,Screen_ID;

//struct TextAttr Screen_TAttr;  /* 2.5RC2 jjt */
struct TextAttr Default_TAttr={"topaz.font",8,0,0}; /* 2.5.31 rri */
//{"topaz.font",8,FSF_BOLD|FSF_UNDERLINED,FPF_ROMFONT|FPF_DISKFONT|FPB_DESIGNED};
//{"times.font",18,FSF_ITALIC|FSF_BOLD|FSF_UNDERLINED,0}; // test!

int CheckScreen()
{
struct Window *win;

win=MyScreen->FirstWindow;
while(win)
 {
  if(win->UserPort!=WinPort) return(1);
  win=win->NextWindow;
 }
 return(0);
}


void GetDRI(struct Screen *s)
{
struct DrawInfo *dri;

if(!s) return;

if((dri=GetScreenDrawInfo(s))) /* 2.5.23 gcc rri */
 {
  CopyMem((UBYTE *)dri->dri_Pens,(UBYTE *)Pens20,(ULONG) (dri->dri_NumPens*2)); /* 2.5RC9 rri */
  FreeScreenDrawInfo(s,dri);
 }

BackPen=Pens20[BACKGROUNDPEN]; /* 2.5b12 rri */
DirPen=Pens20[HIGHLIGHTTEXTPEN]; /* 2.5b12 rri */
FilePen=Pens20[TEXTPEN]; /* 2.5b12 rri */
SelectPen=Pens20[FILLPEN]; /* 2.5b12 rri */
}


void GetHostScreen(UBYTE *str)
{
struct Screen *s;

if(MyScreen) return;
if(HostID[0])
 {
  UnlockPubScreen(HostID,Screen);
  HostID[0]=0;
  InitScreenDefaults();
 }
if(!str||*str==0) return;
s=LockPubScreen(str);
if(s)
 {
  Screen=s;
  strcpy(HostID,str);
  GetDRI(s);
  CopyMem(Screen->Font, &DMTextAttrs[DMFONTS_SCREEN], sizeof (struct TextAttr)); /* 2.7 rri */
  CopyMem(&DMTextAttrs[DMFONTS_SCREEN], &DMTextAttrs[DMFONTS_MENU], sizeof (struct TextAttr));  /* 2.7 rri */
 }
}


void InitScreenDefaults()
{
struct Screen   *pub_screen;
struct DrawInfo *screen_drawinfo;

pub_screen = LockPubScreen(NULL); /* lock DefPubScreen - 2.5.26 rri */
if (pub_screen != NULL)
 {
  Screen = pub_screen;
  CopyMem(Screen->Font, &DMTextAttrs[DMFONTS_SCREEN], sizeof (struct TextAttr));  /* 2.7 rri */
  screen_drawinfo = GetScreenDrawInfo(pub_screen);
  if (screen_drawinfo != NULL)
   {
    CopyMem((UBYTE *)screen_drawinfo->dri_Pens,(UBYTE *)Pens20,(ULONG) (screen_drawinfo->dri_NumPens*2)); /* 2.5RC10 rri */
    Screen_ID = GetVPModeID(&(pub_screen->ViewPort));
    if(Screen_ID != (ULONG) INVALID_ID ) /* 2.5.23 gcc rri */
     {
      Screen_Width = pub_screen->Width;
      Screen_Height = pub_screen->Height;
      Screen_Depth = screen_drawinfo->dri_Depth;
      Bar_Height = pub_screen->BarHeight; /* 2.5b9 rri */
     }
   }
  FreeScreenDrawInfo(pub_screen,screen_drawinfo);
  UnlockPubScreen(NULL,pub_screen); /* 2.5.26 rri */
 }
else
 {
  Screen_ID = 0;     /* 2.5RC4 rri vbcc */
  Screen_Width = 0;  /* 2.5RC4 rri vbcc */
  Screen_Height = 0; /* 2.5RC4 rri vbcc */
  Screen_Depth = 0;  /* 2.5RC4 rri vbcc */
  Bar_Height = 0;    /* 2.5RC4 rri vbcc */
  CopyMem(&Default_TAttr, &DMTextAttrs[DMFONTS_SCREEN], sizeof (struct TextAttr));  /* 2.7 rri */
 }

/* 2.5RC4 rri */
BackPen=Pens20[BACKGROUNDPEN];
DirPen=Pens20[HIGHLIGHTTEXTPEN];
FilePen=Pens20[TEXTPEN];
SelectPen=Pens20[FILLPEN];

CopyMem(&DMTextAttrs[DMFONTS_SCREEN], &DMTextAttrs[DMFONTS_MENU], sizeof (struct TextAttr));  /* 2.7 rri */

if (!DMP_Screen_Font)  /* 2.6 jjt */
 {
  DMP_Screen_Font = CloneStr(DMTextAttrs[DMFONTS_SCREEN].ta_Name, StringPool);  /* 2.7 rri */
  DMP_Screen_FontSz = DMTextAttrs[DMFONTS_SCREEN].ta_YSize;  /* 2.7 rri */
 }
}


void ParseScreenArgs(void) /* 2.5b6 rri */
{
STRPTR font;  /* 2.5RC2 jjt */
ULONG  size;  /* 2.5RC2 jjt */
ULONG ID; /* 2.5.24 rri */

Screen_Depth = (UWORD) GetActionArg("D", AATYPE_NUM, (LONG) Screen_Depth); /* 2.5b10 rri */
if (Screen_Depth<2) Screen_Depth=2; /* 2.5b11 rri */

Screen_Height= GetActionArg("H", AATYPE_NUM, Screen_Height);
if (Screen_Height < 200) Screen_Height = 200;
Screen_Width = GetActionArg("W", AATYPE_NUM, Screen_Width);
if (Screen_Width < 320) Screen_Width=320;

ID = Screen_ID;
Screen_ID = GetActionArg("ID", AATYPE_NUM, Screen_ID);

if (FindDisplayInfo(Screen_ID)==NULL) /* 2.5.24 rri */
 {
  Screen_ID = ID; /* 2.5.24 rri */
 }

font = (STRPTR) GetActionArg("F", AATYPE_STR, (LONG) DMTextAttrs[DMFONTS_SCREEN].ta_Name);  /* 2.7 rri */
size = GetActionArg("FS", AATYPE_NUM, (LONG) DMTextAttrs[DMFONTS_SCREEN].ta_YSize);         /* 2.7 rri */
DMOpenFont(DMFONTS_SCREEN, font, size);                                      /* 2.5RC2 jjt */
// 2.7 rri FontToAttr(DMFonts[DMFONTS_SCREEN], &Screen_TAttr);                          /* 2.5RC2 jjt */
}


struct Screen *NewOpenScreen(int n,UBYTE *name)
{
struct ScreenModeRequester *ModeRequest;
STRPTR font; /* 2.5.24 rri */
ULONG  size; /* 2.5.24 rri */

if(AslBase)
 {
  if(!ActionArgs[n])
   {
    ModeRequest = AllocAslRequest (ASL_ScreenModeRequest, NULL);
    if (ModeRequest != NULL)
     {
      if (AslRequestTags (ModeRequest,
          ASLSM_TitleText, Version,
          ASLSM_InitialDisplayID, Screen_ID,
          ASLSM_InitialDisplayWidth, Screen_Width,
          ASLSM_InitialDisplayHeight, Screen_Height,
          ASLSM_InitialDisplayDepth, Screen_Depth,
          ASLSM_DoWidth, TRUE,
          ASLSM_DoHeight, TRUE,
          ASLSM_DoDepth, TRUE,
          ASLSM_MinWidth, 320,
          ASLSM_MinHeight, 200,
          TAG_DONE))
        {
         Screen_ID=ModeRequest->sm_DisplayID;
         Screen_Depth=ModeRequest->sm_DisplayDepth;
         Screen_Width=ModeRequest->sm_DisplayWidth;
         Screen_Height=ModeRequest->sm_DisplayHeight;

         font = DMTextAttrs[DMFONTS_SCREEN].ta_Name; /* 2.7 rri */
         size = DMTextAttrs[DMFONTS_SCREEN].ta_YSize; /* 2.7 rri */
         DMOpenFont(DMFONTS_SCREEN, font, size); /* 2.5.24 rri */
         // 2.7 rri FontToAttr(DMFonts[DMFONTS_SCREEN], &Screen_TAttr); /* 2.5.24 rri */

        } /* endif AslRequestTags... */
      else /* 2.5.24 rri */
       {
        if (ModeRequest) FreeAslRequest (ModeRequest);
        return(NULL);
       }
     } /* endif ModeRequest... */
    if (ModeRequest) FreeAslRequest (ModeRequest);
   } /* endif !ActionArgs... */
  else
   {
    ParseScreenArgs(); /* 2.5b6 rri */
   } /* endif else... */
 } /* endif AslBase... */

return(DMOpenScreen(Screen_Width,Screen_Height,Screen_ID,Screen_Depth,name)); /* 2.5.24 rri */
}


struct Screen *DMOpenScreen(ULONG Width,ULONG Height,ULONG ID,UWORD Depth,UBYTE *name)
{
struct  Screen *s;

s =(struct Screen *)OpenScreenTags(NULL,
                        SA_LikeWorkbench, TRUE, /* 2.5.23 rri */
                        SA_Width,       Width,
                        SA_Height,      Height,
                        SA_Depth,       Depth,
                        SA_Overscan,    OSCAN_TEXT,
                        SA_AutoScroll,  TRUE,
                        SA_Pens,        Pens20,
                        SA_SharePens,   TRUE,
                        SA_DisplayID,   ID,
                        SA_Title,       name,
                        SA_PubName,     name,
                        SA_Font,        &DMTextAttrs[DMFONTS_SCREEN], /* 2.7 rri */
                        TAG_DONE);

if(s)
 {
  if(UserCols)
   {
    LoadRGB32(&s->ViewPort, ColMap);  /* 2.6 jjt */
   }
  PubScreenStatus(s,0);
  Bar_Height = s->BarHeight; /* 2.5.28 rri */

  /* don't get fooled by screen-promotion... 2.6 rri */
  Screen_ID = GetVPModeID(&(s->ViewPort));
  Screen_Width = s->Width;
  Screen_Height = s->Height;
  Screen_Depth = GetBitMapAttr(s->RastPort.BitMap, BMA_DEPTH);

  #ifdef __amigaos4__
  ClearScreen(&s->RastPort); /* 2.7b10 rri */
  #endif
 }
return(s);
}

