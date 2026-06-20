/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProjSetWin.c
** FUNKTION:  ProjSettingsWindow für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window     *ProjSetWin=NULL;
       ULONG              ProjSetBit=0;

static UWORD              Width,Height;
static WORD               WZoom[4];

static char              *FontName;
static UWORD              FontSize;

static struct TagItem     AGuideNameTags[]={GTST_String,NULL,
                                            GTST_MaxChars,STRMAXCHARS,
                                            TAG_DONE};

static struct TagItem     DatabaseTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem     CopyrightTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem     MasterTags[]={GTST_String,NULL,
                                        GTST_MaxChars,STRMAXCHARS,
                                        TAG_DONE};

static struct TagItem     IndexTags[]={GTST_String,NULL,
                                       GTST_MaxChars,STRMAXCHARS,
                                       TAG_DONE};

static struct TagItem     AuthorTags[]={GTST_String,NULL,
                                        GTST_MaxChars,STRMAXCHARS,
                                        TAG_DONE};

static struct TagItem     VersionTags[]={GTST_String,NULL,
                                         GTST_MaxChars,STRMAXCHARS,
                                         TAG_DONE};

static struct TagItem     FontTags[]={GTTX_Text,NULL,
                                      GTTX_Border,TRUE,
                                      TAG_DONE};

static struct TagItem     HelpTags[]={GTST_String,NULL,
                                      GTST_MaxChars,STRMAXCHARS,
                                      TAG_DONE};


static struct TagItem     WordWrapTags[]={GTCB_Checked,FALSE,GTCB_Scaled,TRUE,TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_AGUIDENAME_STR   0
#define GD_AGUIDENAME_SEL   1
#define GD_DATABASE_STR     2
#define GD_COPYRIGHT_STR    3
#define GD_MASTER_STR       4
#define GD_MASTER_SEL       5
#define GD_INDEX_STR        6
#define GD_AUTHOR_STR       7
#define GD_VERSION_STR      8
#define GD_FONT_TXT         9
#define GD_FONT_SEL        10
#define GD_HELP_STR        11
#define GD_HELP_SEL        12
#define GD_WORDWRAP_CKB    13
#define GD_USE_BUT         14
#define GD_CANCEL_BUT      15
#define GDNUM              16

static struct GadgetData  GadDat[GDNUM];
static struct Gadget     *GadList;
static struct SepData     SepD;

/* VANILLAKEYS */
#define KEY_AGUIDENAME_LWR   0
#define KEY_AGUIDENAME_UPR   1
#define KEY_DATABASE         2
#define KEY_COPYRIGHT        3
#define KEY_MASTER_LWR       4
#define KEY_MASTER_UPR       5
#define KEY_INDEX            6
#define KEY_AUTHOR           7
#define KEY_VERSION          8
#define KEY_FONT             9
#define KEY_HELP_LWR        10
#define KEY_HELP_UPR        11
#define KEY_WORDWRAP        12
#define KEY_USE             13
#define KEY_CANCEL          14
#define KEY_NULL            15
#define KEYNUM              16

static char               VanKeys[KEYNUM];

static void SetStrGad(UBYTE,char *);
static void DoPathSelect(UBYTE);
static void DoFontSelect(void);
static void ActGad(UBYTE);

/* ==================================================================================== InitProjSetWin
** fordert alle wichtigen Resourcen für das ProjSetWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitProjSetWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,selw,labw,butw,strw,selstrw,left,lableft;
  UWORD top,gadh,yadd;
  char  *sel="Sel";

  DEBUG_PRINTF("\n  -- Invoking InitProjSetWin-Function --\n");

  /* Gadgetlabels initialisieren */
  /* StringGadgets und Select-Buttons */
  GadDat[GD_AGUIDENAME_STR].GadgetText  ="_AmigaGuide";
  GadDat[GD_DATABASE_STR].GadgetText    ="_Database";
  GadDat[GD_AUTHOR_STR].GadgetText      ="Au_thor";
  GadDat[GD_COPYRIGHT_STR].GadgetText   ="C_opyright";
  GadDat[GD_VERSION_STR].GadgetText     ="_Version";
  GadDat[GD_MASTER_STR].GadgetText      ="_Master";
  GadDat[GD_FONT_TXT].GadgetText        ="_Font";
  GadDat[GD_INDEX_STR].GadgetText       ="_Index";
  GadDat[GD_HELP_STR].GadgetText        ="_Help";
  GadDat[GD_WORDWRAP_CKB].GadgetText    ="_WordWrap";

  GadDat[GD_AGUIDENAME_SEL].GadgetText  =sel;
  GadDat[GD_MASTER_SEL].GadgetText      =sel;
  GadDat[GD_FONT_SEL].GadgetText        =sel;
  GadDat[GD_HELP_SEL].GadgetText        =sel;

  /* Buttons */
  GadDat[GD_USE_BUT].GadgetText         ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText      ="_Cancel";

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Breite des Select-Buttons ermitteln */
  selw=TextLength(&Screen.ps_DummyRPort,
                  sel,strlen(sel))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* breitestes Gadgetlabel ermitteln */
  labw=0;
  for (i=GD_AGUIDENAME_STR;i<=GD_WORDWRAP_CKB;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText))+INTERWIDTH;

    if (labw<tmp) labw=tmp;
  }
  DEBUG_PRINTF("  lab1w calculated\n");

  /* breitestes Gadgetlabel der Buttons ermitteln */
  butw=TextLength(&Screen.ps_DummyRPort,
                  GadDat[GD_USE_BUT].GadgetText,
                  strlen(GadDat[GD_USE_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_CANCEL_BUT].GadgetText,
                 strlen(GadDat[GD_CANCEL_BUT].GadgetText));

  if (butw<tmp) butw=tmp;
  butw+=3*INTERWIDTH;
  DEBUG_PRINTF("  butw calculated\n");

  /* breitestes Gadgetlabel der DatabaseModes ermitteln */
  strw=Screen.ps_ScrFont->tf_XSize*20;
  DEBUG_PRINTF("  datbmlw calculated\n");

  /* Größen der Gadgets berechnen */

  if (2*butw+INTERWIDTH>labw+strw)
    strw=2*butw+INTERWIDTH-labw;

  selstrw=strw-selw;
  left   =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  lableft=left+labw;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.ProjSetWTop==~0) AGDPrefsP.ProjSetWTop=Screen.ps_Screen->BarHeight+1;
  Width =labw+strw+2*INTERWIDTH;
  Height=11*yadd+2*INTERHEIGHT+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.ProjSetWLeft;
  WZoom[1]=AGDPrefsP.ProjSetWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1+INTERHEIGHT;

  /* AGuideName-String-Gadget */
  gd=&GadDat[GD_AGUIDENAME_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_AGUIDENAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =AGuideNameTags;

  /* AGuideName-Sel-Gadget */
  gd=&GadDat[GD_AGUIDENAME_SEL];
  gd->LeftEdge=lableft+GadDat[GD_AGUIDENAME_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_AGUIDENAME_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =AGuideNameTags;

  top+=yadd;

  /* Database-String-Gadget */
  gd=&GadDat[GD_DATABASE_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_DATABASE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =DatabaseTags;

  top+=yadd;

  /* Copyright-String-Gadget */
  gd=&GadDat[GD_COPYRIGHT_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_COPYRIGHT_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =CopyrightTags;

  top+=yadd;

  /* Master-String-Gadget */
  gd=&GadDat[GD_MASTER_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_MASTER_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =MasterTags;

  /* Master-Sel-Gadget */
  gd=&GadDat[GD_MASTER_SEL];
  gd->LeftEdge=lableft+GadDat[GD_MASTER_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_MASTER_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =MasterTags;

  top+=yadd;

  /* Index-String-Gadget */
  gd=&GadDat[GD_INDEX_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_INDEX_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =IndexTags;

  top+=yadd;

  /* Author-String-Gadget */
  gd=&GadDat[GD_AUTHOR_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_AUTHOR_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =AuthorTags;

  top+=yadd;

  /* Version-String-Gadget */
  gd=&GadDat[GD_VERSION_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_VERSION_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =VersionTags;

  top+=yadd;

  /* Font-TextDisplay-Gadget */
  gd=&GadDat[GD_FONT_TXT];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FONT_TXT;
  gd->Type    =TEXT_KIND;
  gd->Tags    =FontTags;

  /* Font-Sel-Gadget */
  gd=&GadDat[GD_FONT_SEL];
  gd->LeftEdge=lableft+GadDat[GD_FONT_TXT].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_FONT_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Help-String-Gadget */
  gd=&GadDat[GD_HELP_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_HELP_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =HelpTags;

  /* Help-Sel-Gadget */
  gd=&GadDat[GD_HELP_SEL];
  gd->LeftEdge=lableft+GadDat[GD_HELP_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_HELP_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* WordWrap-CheckBox-Gadget */
  gd=&GadDat[GD_WORDWRAP_CKB];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_WORDWRAP_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =WordWrapTags;

  top+=yadd;

  SepD.LeftEdge=left;
  SepD.TopEdge =top;
  SepD.Width   =labw+strw;

  top+=SEPHEIGHT+INTERHEIGHT;

  /* BOTTOM-BUTTONS */
  /* Use-Button-Gadget */
  gd=&GadDat[GD_USE_BUT];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_USE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Cancel-Button-Gadget */
  gd=&GadDat[GD_CANCEL_BUT];
  gd->LeftEdge=left+Width-2*INTERWIDTH-butw;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_CANCEL_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_AGUIDENAME_LWR]=FindVanillaKey(GadDat[GD_AGUIDENAME_STR].GadgetText);
  VanKeys[KEY_AGUIDENAME_UPR]=toupper(VanKeys[KEY_AGUIDENAME_LWR]);
  VanKeys[KEY_DATABASE]      =FindVanillaKey(GadDat[GD_DATABASE_STR].GadgetText);
  VanKeys[KEY_COPYRIGHT]     =FindVanillaKey(GadDat[GD_COPYRIGHT_STR].GadgetText);
  VanKeys[KEY_MASTER_LWR]    =FindVanillaKey(GadDat[GD_MASTER_STR].GadgetText);
  VanKeys[KEY_MASTER_UPR]    =toupper(VanKeys[KEY_MASTER_LWR]);
  VanKeys[KEY_INDEX]         =FindVanillaKey(GadDat[GD_INDEX_STR].GadgetText);
  VanKeys[KEY_AUTHOR]        =FindVanillaKey(GadDat[GD_AUTHOR_STR].GadgetText);
  VanKeys[KEY_VERSION]       =FindVanillaKey(GadDat[GD_VERSION_STR].GadgetText);
  VanKeys[KEY_FONT]          =FindVanillaKey(GadDat[GD_FONT_TXT].GadgetText);
  VanKeys[KEY_HELP_LWR]      =FindVanillaKey(GadDat[GD_HELP_STR].GadgetText);
  VanKeys[KEY_HELP_UPR]      =toupper(VanKeys[KEY_HELP_LWR]);
  VanKeys[KEY_WORDWRAP]      =FindVanillaKey(GadDat[GD_WORDWRAP_CKB].GadgetText);
  VanKeys[KEY_USE]           =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL]        =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]          ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CloseProjSetWin
** schließt das ProjectSettings-Fenster
*/
void CloseProjSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseProjSetWin-function --\n");

  if (ProjSetWin)
  {
    if (FontName) FreeVec(FontName);

    /* MenuStrip löschen */
    ClearMenuStrip(ProjSetWin);
    DEBUG_PRINTF("  MenuStrip at ProjSetWin cleared\n");

    /* Window schließen */
    CloseWindow(ProjSetWin);
    ProjSetWin=NULL;
    ProjSetBit=0;
    DEBUG_PRINTF("  ProjSetWin closed\n");

    /* Gadgets freigeben */
    FreeGadgets(GadList);
    DEBUG_PRINTF("  GadList freed\n");
  }

  AGDPrefsP.ProjSetWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== OpenProjSetWin
** öffnet das ProjectSettings-Fenster
*/
BOOL OpenProjSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenProjSetWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!ProjSetWin)
  {
    FontName    =mstrdup(ProjP.FontName);
    FontSize    =ProjP.FontSize;

    AGuideNameTags[0].ti_Data  =(ULONG)ProjP.AGuidePath;
    DatabaseTags[0].ti_Data    =(ULONG)ProjP.Database;
    CopyrightTags[0].ti_Data   =(ULONG)ProjP.Copyright;
    MasterTags[0].ti_Data      =(ULONG)ProjP.Master;
    IndexTags[0].ti_Data       =(ULONG)ProjP.Index;
    AuthorTags[0].ti_Data      =(ULONG)ProjP.Author;
    VersionTags[0].ti_Data     =(ULONG)ProjP.Version;
    FontTags[0].ti_Data        =(ULONG)FontName;
    HelpTags[0].ti_Data        =(ULONG)ProjP.Help;
    WordWrapTags[0].ti_Data    =(ULONG)ProjP.WordWrap;

    if (GadList=
        CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (ProjSetWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.ProjSetWLeft,
                         WA_Top,AGDPrefsP.ProjSetWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,"Project Editor Settings",
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|TEXTIDCMP|STRINGIDCMP|CYCLEIDCMP|\
                                  IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|\
                                  IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  ProjSetWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(ProjSetWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at ProjSetWin\n");

        /* Window neu aufbauen */
        GT_RefreshWindow(ProjSetWin,NULL);
        DrawSeparators(ProjSetWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        ProjSetBit=1UL<<ProjSetWin->UserPort->mp_SigBit;
        AGDPrefsP.ProjSetWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening the Project\n"
                           "Editor Settings Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "the Project Editor Settings Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseProjSetWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(ProjSetWin);
    WindowToFront(ProjSetWin);
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(TRUE);
}

/* ================================================================================== GetProjSetWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetProjSetWinPos(void)
{
  if (ProjSetWin)
  {
    AGDPrefsP.ProjSetWLeft=ProjSetWin->LeftEdge;
    AGDPrefsP.ProjSetWTop =ProjSetWin->TopEdge;
  }
}

/* ================================================================================== UpdateProjSetWin
** updated das ProjSetWin
*/
void UpdateProjSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking UpdateProjSetWin-function --\n");

  if (ProjSetWin)
  {
    DEBUG_PRINTF("  ProjSetWin opened\n");

    FontSize=ProjP.FontSize;
    if (FontName) FreeVec(FontName);
    FontName=mstrdup(ProjP.FontName);

    SetStrGad(GD_AGUIDENAME_STR,ProjP.AGuidePath);
    SetStrGad(GD_DATABASE_STR,ProjP.Database);
    SetStrGad(GD_COPYRIGHT_STR,ProjP.Copyright);
    SetStrGad(GD_MASTER_STR,ProjP.Master);
    SetStrGad(GD_INDEX_STR,ProjP.Index);
    SetStrGad(GD_AUTHOR_STR,ProjP.Author);
    SetStrGad(GD_VERSION_STR,ProjP.Version);
    GT_SetGadgetAttrs(GadDat[GD_FONT_TXT].Gadget,
                      ProjSetWin,NULL,
                      GTTX_Text,ProjP.FontName,
                      TAG_DONE);
    SetStrGad(GD_HELP_STR,ProjP.Help);
    GT_SetGadgetAttrs(GadDat[GD_WORDWRAP_CKB].Gadget,
                      ProjSetWin,NULL,
                      GTCB_Checked,ProjP.WordWrap,
                      TAG_DONE);

    DEBUG_PRINTF("  gadgets set\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ==================================================================================== CopyProjSetWin
** kopiert die Gadgets im ProjSetWin
*/
void CopyProjSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CopyProjSetWin-function --\n");

  if (ProjSetWin)
  {
    DEBUG_PRINTF("  ProjSetWin opened\n");

    DoStringCopy(&ProjP.AGuidePath,GadDat[GD_AGUIDENAME_STR].Gadget);
    DoStringCopy(&ProjP.Database,GadDat[GD_DATABASE_STR].Gadget);
    DoStringCopy(&ProjP.Copyright,GadDat[GD_COPYRIGHT_STR].Gadget);
    DoStringCopy(&ProjP.Master,GadDat[GD_MASTER_STR].Gadget);
    DoStringCopy(&ProjP.Index,GadDat[GD_INDEX_STR].Gadget);
    DoStringCopy(&ProjP.Author,GadDat[GD_AUTHOR_STR].Gadget);
    DoStringCopy(&ProjP.Version,GadDat[GD_VERSION_STR].Gadget);
    ProjP.FontName=mstrdup(FontName);
    ProjP.FontSize=FontSize;
    DoStringCopy(&ProjP.Help,GadDat[GD_HELP_STR].Gadget);
    ProjP.WordWrap=GadDat[GD_WORDWRAP_CKB].Gadget->Flags&GFLG_SELECTED;

    DEBUG_PRINTF("  gadgets copied\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ============================================================================================ ActGad
** aktiviert ein String-Gadget im ProjSetWin
*/
static
void ActGad(UBYTE gdnum)
{
  ActivateGadget(GadDat[gdnum].Gadget,ProjSetWin,NULL);
}
  
/* ========================================================================================= SetStrGad
** setzt ein String-Gadget im ProjSetWin
*/
static
void SetStrGad(UBYTE gdnum,char *str)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    ProjSetWin,NULL,
                    GTST_String,str,
                    TAG_DONE);
}

/* ====================================================================================== DoPathSelect
** Pfad-Auswahl per ASL-Requester und autom. Setzen des Windows
*/
static
void DoPathSelect(UBYTE gdnum)
{
  FileRD.Path     =GetString(GadDat[gdnum].Gadget);
  FileRD.Title    ="Pfad wählen";
  FileRD.Flags1   =FRF_DOPATTERNS;
  FileRD.Flags2   =0;

  /* FileRequester öffnen */
  if (OpenFileRequester())
  {
    SetStrGad(gdnum,FileRD.Path);
    if (FileRD.Path) FreeVec(FileRD.Path);
  }
}

/* ====================================================================================== DoFontSelect
** Auswahl eines Fonts per ASL-Requester und autm. Setzen des Gadgets
*/
static
void DoFontSelect(void)
{
  FontRD.Font.ta_Name =FontName;
  FontRD.Font.ta_YSize=FontSize;
  FontRD.Flags        =0;
  FontRD.Title        ="Font wählen";

  if (OpenFontRequester())
  {
    if (FontName) FreeVec(FontName);

    FontName=FontRD.Font.ta_Name;
    FontSize=FontRD.Font.ta_YSize;

    GT_SetGadgetAttrs(GadDat[GD_FONT_TXT].Gadget,
                      ProjSetWin,NULL,
                      GTTX_Text,FontName,
                      TAG_DONE);
  }
}

/* ============================================================================= HandleProjSetWinIDCMP
** IDCMP-Message auswerten
*/
void HandleProjSetWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleProjSetWinIDCMP-function --\n");

  /* Message auslesen */
  while (ProjSetWin && (imsg=GT_GetIMsg(ProjSetWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from ProjSetWin->UserPort\n");

    class=imsg->Class;
    code =imsg->Code;
    iaddr=imsg->IAddress;

    /* antworten */
    GT_ReplyIMsg(imsg);
    DEBUG_PRINTF("  Message replyed\n");

    /* Welche Art Event? */
    switch (class)
    {
      /* muß Window neu gezeichnet werden ? */
      case IDCMP_REFRESHWINDOW:
        GT_BeginRefresh(ProjSetWin);
        DrawSeparators(ProjSetWin,&SepD,1);
        GT_EndRefresh(ProjSetWin,TRUE);
        DEBUG_PRINTF("  ProjSetWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetProjSetWinPos();
        CloseProjSetWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  ProjSetWin closed\n");

        break;

      /* Menu angewählt? */
      case IDCMP_MENUPICK:
        HandleProgMenus(code);
        DEBUG_PRINTF("  Menus handled\n");
        break;

      /* Gadget angeklickt? */
      case IDCMP_GADGETUP:
      {
        gad=(struct Gadget *)iaddr;

        /* welches Gadget */
        switch (gad->GadgetID)
        {
          /* AGuideName */
          case GD_AGUIDENAME_SEL:
            DoPathSelect(GD_AGUIDENAME_STR);
            DEBUG_PRINTF("  GD_AGUIDENAME_SEL processed\n");
            break;

          /* Master */
          case GD_MASTER_SEL:
            DoPathSelect(GD_MASTER_STR);
            DEBUG_PRINTF("  GD_MASTER_SEL processed\n");
            break;

          /* Font */
          case GD_FONT_SEL:
            DoFontSelect();
            DEBUG_PRINTF("  GD_FONT_SEL processed\n");
            break;

          /* Help */
          case GD_HELP_SEL:
            DoPathSelect(GD_HELP_STR);
            DEBUG_PRINTF("  GD_HELP_SEL processed\n");
            break;

          /* Use */
          case GD_USE_BUT:
            CopyProjSetWin();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          /* Cancel */
          case GD_CANCEL_BUT:
            if (AGDPrefsP.ReqMode)
            {
              GetProjSetWinPos();
              CloseProjSetWin();
              SetProgMenusStates();
            }
            else
              UpdateProjSetWin();

            DEBUG_PRINTF("  GD_CANCEL_BUT processed\n");
            break;
        }

        DEBUG_PRINTF("  Gadgets processed\n");
        break;
      }

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
      {
        /* welches Gadget */
        switch (MatchVanillaKey(code,VanKeys))
        {
          /* AGuideName */
          case KEY_AGUIDENAME_LWR:
            ActGad(GD_AGUIDENAME_STR);
            DEBUG_PRINTF("  KEY_AGUIDENAME_LWR processed\n");
            break;

          case KEY_AGUIDENAME_UPR:
            DoPathSelect(GD_AGUIDENAME_STR);
            DEBUG_PRINTF("  KEY_AGUIDENAME_UPR processed\n");
            break;

          /* Database */
          case KEY_DATABASE:
            ActGad(GD_DATABASE_STR);
            DEBUG_PRINTF("  KEY_DATABASE processed\n");
            break;

          /* Copyright */
          case KEY_COPYRIGHT:
            ActGad(GD_COPYRIGHT_STR);
            DEBUG_PRINTF("  KEY_COPYRIGHT processed\n");
            break;

          /* Master */
          case KEY_MASTER_LWR:
            ActGad(GD_MASTER_STR);
            DEBUG_PRINTF("  KEY_MASTER_LWR processed\n");
            break;

          case KEY_MASTER_UPR:
            DoPathSelect(GD_MASTER_STR);
            DEBUG_PRINTF("  KEY_MASTER_UPR processed\n");
            break;

          /* Index */
          case KEY_INDEX:
            ActGad(GD_INDEX_STR);
            DEBUG_PRINTF("  KEY_INDEX_LWR processed\n");
            break;

          /* WordWrap */
          case KEY_WORDWRAP:
            GT_SetGadgetAttrs(GadDat[GD_WORDWRAP_CKB].Gadget,
                              ProjSetWin,NULL,
                              GTCB_Checked,!(GadDat[GD_WORDWRAP_CKB].Gadget->Flags&GFLG_SELECTED),
                              TAG_DONE);

            DEBUG_PRINTF("  KEY_WORDWRAP processed\n");
            break;

          /* Author */
          case KEY_AUTHOR:
            ActGad(GD_AUTHOR_STR);
            DEBUG_PRINTF("  KEY_AUTHOR processed\n");
            break;

          /* Copyright */
          case KEY_VERSION:
            ActGad(GD_VERSION_STR);
            DEBUG_PRINTF("  KEY_VERSION processed\n");
            break;

          /* Font */
          case KEY_FONT:
            DoFontSelect();
            DEBUG_PRINTF("  KEY_FONT_UPR processed\n");
            break;

          /* Help */
          case KEY_HELP_LWR:
            ActGad(GD_HELP_STR);
            DEBUG_PRINTF("  KEY_HELP_LWR processed\n");
            break;

          case KEY_HELP_UPR:
            DoPathSelect(GD_HELP_STR);
            DEBUG_PRINTF("  KEY_HELP_UPR processed\n");
            break;

          /* Use */
          case KEY_USE:
            CopyProjSetWin();
            DEBUG_PRINTF("  KEY_USE processed\n");

          /* Cancel */
          case KEY_CANCEL:
            if (AGDPrefsP.ReqMode)
            {
              GetProjSetWinPos();
              CloseProjSetWin();
              SetProgMenusStates();
            }
            else
              UpdateProjSetWin();

            DEBUG_PRINTF("  KEY_CANCEL processed\n");
            break;
        }

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
      }
    }
  }

  /* Programm beendet? */
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
