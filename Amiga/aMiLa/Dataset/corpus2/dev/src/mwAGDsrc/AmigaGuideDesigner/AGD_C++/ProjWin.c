/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProjWin.c
** FUNKTION:  ProjWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

       struct Window     *ProjWin=NULL;
       ULONG              ProjBit=0;

static char              *WinTitle;

static UWORD              Width,Height;
static WORD               WZoom[4];

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

static struct TagItem     WordWrapTags[]={GTCB_Checked,FALSE,GTCB_Scaled,TRUE,TAG_DONE};

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


/* GADGETS */
/* erste Spalte */
#define GD_AGUIDENAME_STR  0
#define GD_AGUIDENAME_SEL  1
#define GD_DATABASE_STR    2
#define GD_COPYRIGHT_STR   3
#define GD_MASTER_STR      4
#define GD_MASTER_SEL      5
#define GD_INDEX_STR       6
#define GD_INDEX_SEL       7
#define GD_WORDWRAP_CKB    8
#define GD_AUTHOR_STR      9
#define GD_VERSION_STR    10
#define GD_FONT_TXT       11
#define GD_FONT_SEL       12
#define GD_HELP_STR       13
#define GD_HELP_SEL       14
#define GD_GENERATE_BUT   15
#define GD_EDITDOCS_BUT   16
#define GD_QUIT_BUT       17
#define GDNUM             18

static struct GadgetData  GadDat[GDNUM];
static struct Gadget     *GadList;

static struct SepData     SepDat;

/* VANILLAKEYS */
#define KEY_AGUIDENAME_LWR  0
#define KEY_AGUIDENAME_UPR  1
#define KEY_DATABASE        2
#define KEY_COPYRIGHT       3
#define KEY_MASTER_LWR      4
#define KEY_MASTER_UPR      5
#define KEY_INDEX_LWR       6
#define KEY_INDEX_UPR       7
#define KEY_WORDWRAP        8
#define KEY_AUTHOR          9
#define KEY_VERSION        10
#define KEY_FONT           11
#define KEY_HELP_LWR       12
#define KEY_HELP_UPR       13
#define KEY_GENERATE       14
#define KEY_EDITDOCS       15
#define KEY_QUIT           16
#define KEY_NULL           17
#define KEYNUM             18

static char              VanKeys[KEYNUM];

static void SetStrGad(UBYTE,char *);
static void DoPathSelect(UBYTE,char **);
static void DoFontSelect(void);
static void DoIndexSelect(void);
static void ActGad(UBYTE);

/* ================================================================================= BuildProjWinTitle
** baut ProjWin-Titel
*/
void BuildProjWinTitle(void)
{
  char *project="Project Editor: ";
  ULONG projectlen=strlen(project);
  ULONG namelen=0;

  if (ProjectName) projectlen=strlen(ProjectName);

  if (WinTitle)
  {
    FreeVec(WinTitle);
    DEBUG_PRINTF("  memory for WinTitle freed\n");
  }

  if (WinTitle=(char *)
      AllocVec(projectlen+namelen+1,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
  {
    strcpy(WinTitle,project);
    if (ProjectName) strcpy(&WinTitle[projectlen],ProjectName);
  }
}

/* ================================================================================ UpdateProjWinTitle
** setzt ProjWin-Titel neu
*/
void UpdateProjWinTitle(void)
{
  BuildProjWinTitle();
  SetWindowTitles(ProjWin,WinTitle,Screen.ps_Title);
}

/* ======================================================================================= InitProjWin
** fordert alle wichtigen Resourcen für das ProjWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitProjWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,selw,lab1w,lab2w,butw,smstrw,smselstrw,bigstrw;
  UWORD borleft,left;
  UWORD top,gadh,yadd;
  char  *sel="Sel";

  DEBUG_PRINTF("\n  -- Invoking InitProjWin-Function --\n");

  /* Gadgetlabels initialisieren */
  /* StringGadgets und Select-Buttons */
  GadDat[GD_AGUIDENAME_STR].GadgetText ="_AmigaGuide";
  GadDat[GD_DATABASE_STR].GadgetText   ="_Database";
  GadDat[GD_AUTHOR_STR].GadgetText     ="A_uthor";
  GadDat[GD_COPYRIGHT_STR].GadgetText  ="_Copyright";
  GadDat[GD_VERSION_STR].GadgetText    ="_Version";
  GadDat[GD_MASTER_STR].GadgetText     ="_Master";
  GadDat[GD_FONT_TXT].GadgetText       ="_Font";
  GadDat[GD_INDEX_STR].GadgetText      ="_Index";
  GadDat[GD_HELP_STR].GadgetText       ="_Help";
  GadDat[GD_WORDWRAP_CKB].GadgetText   ="_WordWrap";

  GadDat[GD_AGUIDENAME_SEL].GadgetText =sel;
  GadDat[GD_MASTER_SEL].GadgetText     =sel;
  GadDat[GD_FONT_SEL].GadgetText       =sel;
  GadDat[GD_INDEX_SEL].GadgetText      =sel;
  GadDat[GD_HELP_SEL].GadgetText       =sel;

  /* Buttons */
  GadDat[GD_GENERATE_BUT].GadgetText   ="_Generate...";
  GadDat[GD_EDITDOCS_BUT].GadgetText   ="_Edit Documents...";
  GadDat[GD_QUIT_BUT].GadgetText       ="_Quit";

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Breite des Select-Buttons ermitteln */
  selw=TextLength(&Screen.ps_DummyRPort,
                  sel,strlen(sel))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* breitestes Gadgetlabel der ersten Spalte ermitteln */
  lab1w=0;
  for (i=GD_AGUIDENAME_STR;i<=GD_WORDWRAP_CKB;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (lab1w<tmp) lab1w=tmp;
  }
  lab1w+=INTERWIDTH;
  DEBUG_PRINTF("  lab1w calculated\n");

  /* breitestes Gadgetlabel der zweiten Spalte ermitteln */
  lab2w=0;
  for (i=GD_AUTHOR_STR;i<=GD_HELP_STR;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (lab2w<tmp) lab2w=tmp;
  }
  lab2w+=INTERWIDTH;
  DEBUG_PRINTF("  lab2w calculated\n");

  /* breitestes Gadgetlabel der Buttons ermitteln */
  butw=0;
  for (i=GD_GENERATE_BUT;i<=GD_QUIT_BUT;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (butw<tmp) butw=tmp;
  }
  butw+=INTERWIDTH;
  DEBUG_PRINTF("  butw calculated\n");

  /* Größen der Gadgets berechnen */
  smstrw   =Screen.ps_ScrFont->tf_XSize*15;

  if (3*butw+2*INTERWIDTH>lab1w+lab2w+2*smstrw)
    smstrw=(3*butw+2*INTERWIDTH-lab1w-lab2w)/2;
  else
    butw=(lab1w+lab2w+2*smstrw-2*INTERWIDTH)/3;

  smselstrw=smstrw-selw;
  bigstrw  =2*smstrw+lab2w+INTERWIDTH-selw;
  borleft  =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  left     =borleft+lab1w;
  gadh     =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd     =gadh+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (WinPosP.ProjWTop==~0) WinPosP.ProjWTop=Screen.ps_Screen->BarHeight+1;
  Width =lab1w+lab2w+2*smstrw+3*INTERWIDTH;
  Height=7*yadd+SEPHEIGHT+2*INTERHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=WinPosP.ProjWLeft;
  WZoom[1]=WinPosP.ProjWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_WBorTop;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_WBorTop+INTERHEIGHT;

  /* AGuideName-String-Gadget */
  gd=&GadDat[GD_AGUIDENAME_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =bigstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_AGUIDENAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =AGuideNameTags;

  /* AGuideName-Sel-Gadget */
  gd=&GadDat[GD_AGUIDENAME_SEL];
  gd->LeftEdge=left+GadDat[GD_AGUIDENAME_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_AGUIDENAME_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Database-String-Gadget */
  gd=&GadDat[GD_DATABASE_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_DATABASE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =DatabaseTags;

  top+=yadd;

  /* Copyright-String-Gadget */
  gd=&GadDat[GD_COPYRIGHT_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_COPYRIGHT_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =CopyrightTags;

  top+=yadd;

  /* Master-String-Gadget */
  gd=&GadDat[GD_MASTER_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smselstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_MASTER_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =MasterTags;

  /* Master-Sel-Gadget */
  gd=&GadDat[GD_MASTER_SEL];
  gd->LeftEdge=left+GadDat[GD_MASTER_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_MASTER_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Index-String-Gadget */
  gd=&GadDat[GD_INDEX_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smselstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_INDEX_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =IndexTags;

  /* Index-Sel-Gadget */
  gd=&GadDat[GD_INDEX_SEL];
  gd->LeftEdge=left+GadDat[GD_INDEX_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_INDEX_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* WordWrap-CheckBox-Gadget */
  gd=&GadDat[GD_WORDWRAP_CKB];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_WORDWRAP_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =WordWrapTags;

  /* SPALTE 2 */
  top=GadDat[GD_DATABASE_STR].TopEdge;
  left+=smstrw+INTERWIDTH+lab2w;

  /* Author-String-Gadget */
  gd=&GadDat[GD_AUTHOR_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_AUTHOR_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =AuthorTags;

  top+=yadd;

  /* Version-String-Gadget */
  gd=&GadDat[GD_VERSION_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_VERSION_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =VersionTags;

  top+=yadd;

  /* Font-TextDisplay-Gadget */
  gd=&GadDat[GD_FONT_TXT];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smselstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FONT_TXT;
  gd->Type    =TEXT_KIND;
  gd->Tags    =FontTags;

  /* Font-Sel-Gadget */
  gd=&GadDat[GD_FONT_SEL];
  gd->LeftEdge=left+GadDat[GD_FONT_TXT].Width;
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
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =smselstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_HELP_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =HelpTags;

  /* Help-Sel-Gadget */
  gd=&GadDat[GD_HELP_SEL];
  gd->LeftEdge=left+GadDat[GD_HELP_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_HELP_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top=GadDat[GD_WORDWRAP_CKB].TopEdge+yadd;

  /* Separator berechnen */
  SepDat.LeftEdge=borleft;
  SepDat.TopEdge =top;
  SepDat.Width   =Width-2*INTERWIDTH;

  /* BOTTOM-BUTTONS */
  top=SepDat.TopEdge+SEPHEIGHT+INTERHEIGHT;

  /* Generate-Button-Gadget */
  gd=&GadDat[GD_GENERATE_BUT];
  gd->LeftEdge=2*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_GENERATE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* EditDocs-Button-Gadget */
  gd=&GadDat[GD_EDITDOCS_BUT];
  gd->LeftEdge=3*INTERWIDTH+butw;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_EDITDOCS_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Quit-Button-Gadget */
  gd=&GadDat[GD_QUIT_BUT];
  gd->LeftEdge=4*INTERWIDTH+2*butw;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_QUIT_BUT;
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
  VanKeys[KEY_INDEX_LWR]     =FindVanillaKey(GadDat[GD_INDEX_STR].GadgetText);
  VanKeys[KEY_INDEX_UPR]     =toupper(VanKeys[KEY_INDEX_LWR]);
  VanKeys[KEY_WORDWRAP]      =FindVanillaKey(GadDat[GD_WORDWRAP_CKB].GadgetText);
  VanKeys[KEY_AUTHOR]        =FindVanillaKey(GadDat[GD_AUTHOR_STR].GadgetText);
  VanKeys[KEY_VERSION]       =FindVanillaKey(GadDat[GD_VERSION_STR].GadgetText);
  VanKeys[KEY_FONT]          =FindVanillaKey(GadDat[GD_FONT_TXT].GadgetText);
  VanKeys[KEY_HELP_LWR]      =FindVanillaKey(GadDat[GD_HELP_STR].GadgetText);
  VanKeys[KEY_HELP_UPR]      =toupper(VanKeys[KEY_HELP_LWR]);
  VanKeys[KEY_GENERATE]      =FindVanillaKey(GadDat[GD_GENERATE_BUT].GadgetText);
  VanKeys[KEY_EDITDOCS]      =FindVanillaKey(GadDat[GD_EDITDOCS_BUT].GadgetText);
  VanKeys[KEY_QUIT]          =FindVanillaKey(GadDat[GD_QUIT_BUT].GadgetText);
  VanKeys[KEY_NULL]          ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ====================================================================================== CloseProjWin
** schließt das Project-Fenster
*/
void CloseProjWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseProjWin-function --\n");

  if (WinTitle)
  {
    FreeVec(WinTitle);
    WinTitle=NULL;
    DEBUG_PRINTF("  WinTitle freed\n");
  }

  if (ProjWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(ProjWin);
    DEBUG_PRINTF("  MenuStrip at ProjWin cleared\n");

    /* Window schließen */
    CloseWindow(ProjWin);
    ProjWin=NULL;
    ProjBit=0;
    DEBUG_PRINTF("  ProjWin closed\n");

    /* GadList freigeben */
    FreeGadgets(GadList);
    DEBUG_PRINTF("  GadList freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= OpenProjWin
** öffnet das Project-Fenster
*/
BOOL OpenProjWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenProjWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!ProjWin)
  {
    BuildProjWinTitle();
    DEBUG_PRINTF("  window title built\n");

    AGuideNameTags[0].ti_Data=(ULONG)AGuide.gt_Name;
    DatabaseTags[0].ti_Data  =(ULONG)AGuide.gt_Database;
    CopyrightTags[0].ti_Data =(ULONG)AGuide.gt_Copyright;
    MasterTags[0].ti_Data    =(ULONG)AGuide.gt_Master;
    IndexTags[0].ti_Data     =(ULONG)AGuide.gt_Index;
    WordWrapTags[0].ti_Data  =(ULONG)AGuide.gt_WordWrap;
    AuthorTags[0].ti_Data    =(ULONG)AGuide.gt_Author;
    VersionTags[0].ti_Data   =(ULONG)AGuide.gt_Version;
    FontTags[0].ti_Data      =(ULONG)AGuide.gt_Font;
    HelpTags[0].ti_Data      =(ULONG)AGuide.gt_Help;

    if (GadList=
        CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (ProjWin=
          OpenWindowTags(NULL,
                         WA_Left,WinPosP.ProjWLeft,
                         WA_Top,WinPosP.ProjWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,WinTitle,
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|TEXTIDCMP|STRINGIDCMP|\
                                  IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|\
                                  IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  ProjWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(ProjWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at ProjWin\n");

        /* Window neu aufbauen */
        DrawSeparators(ProjWin,&SepDat,1);
        GT_RefreshWindow(ProjWin,NULL);
        DEBUG_PRINTF("  GadList refreshed\n");

        ProjBit=1UL<<ProjWin->UserPort->mp_SigBit;
        WinPosP.ProjWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening the Project Editor Window","Ok");
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "the Project Editor Window",
                         "Ok");

    DEBUG_PRINTF("  Error\n");
    CloseProjWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(ProjWin);
    WindowToFront(ProjWin);
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(TRUE);
}

/* ===================================================================================== GetProjWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetProjWinPos(void)
{
  if (ProjWin)
  {
    WinPosP.ProjWLeft=ProjWin->LeftEdge;
    WinPosP.ProjWTop =ProjWin->TopEdge;
  }
}

/* ===================================================================================== UpdateProjWin
** updated das ProjWin
*/
void UpdateProjWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking UpdateProjWin-function --\n");

  if (ProjWin)
  {
    SetStrGad(GD_AGUIDENAME_STR,AGuide.gt_Name);
    SetStrGad(GD_DATABASE_STR,AGuide.gt_Database);
    SetStrGad(GD_COPYRIGHT_STR,AGuide.gt_Copyright);
    SetStrGad(GD_MASTER_STR,AGuide.gt_Master);
    SetStrGad(GD_INDEX_STR,AGuide.gt_Index);
    GT_SetGadgetAttrs(GadDat[GD_WORDWRAP_CKB].Gadget,
                      ProjWin,NULL,
                      GTCB_Checked,AGuide.gt_WordWrap,
                      TAG_DONE);
    SetStrGad(GD_AUTHOR_STR,AGuide.gt_Author);
    SetStrGad(GD_VERSION_STR,AGuide.gt_Version);
    GT_SetGadgetAttrs(GadDat[GD_FONT_TXT].Gadget,
                      ProjWin,NULL,
                      GTTX_Text,AGuide.gt_Font,
                      TAG_DONE);
    SetStrGad(GD_HELP_STR,AGuide.gt_Help);
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ============================================================================================ ActGad
** aktiviert ein String-Gadget im ProjWin
*/
static
void ActGad(UBYTE gdnum)
{
  ActivateGadget(GadDat[gdnum].Gadget,ProjWin,NULL);
}
  
/* ========================================================================================= SetStrGad
** setzt ein String-Gadget im ProjWin
*/
static
void SetStrGad(UBYTE gdnum,char *str)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    ProjWin,NULL,
                    GTST_String,str,
                    TAG_DONE);
}

/* ====================================================================================== DoPathSelect
** Pfad-Auswahl per ASL-Requester und autom. Setzen des Windows
*/
static
void DoPathSelect(UBYTE gdnum,char **str)
{
  FileRD.Path     =*str;
  FileRD.Title    ="Pfad wählen";
  FileRD.Flags1   =FRF_DOPATTERNS;
  FileRD.Flags2   =0;

  /* FileRequester öffnen */
  if (OpenFileRequester())
  {
    if (*str) FreeVec(*str);
    *str=FileRD.Path;
    SetStrGad(gdnum,*str);
  }
}

/* ====================================================================================== DoFontSelect
** Auswahl eines Fonts per ASL-Requester und autm. Setzen des Gadgets
*/
static
void DoFontSelect(void)
{
  FontRD.Font.ta_Name =AGuide.gt_Font;
  FontRD.Font.ta_YSize=AGuide.gt_FoSize;
  FontRD.Flags        =0;
  FontRD.Title        ="Font wählen";

  if (OpenFontRequester())
  {
    if (AGuide.gt_Font) FreeVec(AGuide.gt_Font);

    AGuide.gt_Font  =FontRD.Font.ta_Name;
    AGuide.gt_FoSize=FontRD.Font.ta_YSize;

    GT_SetGadgetAttrs(GadDat[GD_FONT_TXT].Gadget,
                      ProjWin,NULL,
                      GTTX_Text,AGuide.gt_Font,
                      TAG_DONE);
  }
}

/* ===================================================================================== DoIndexSelect
** Auswahl des Indexes
*/
static
void DoIndexSelect(void)
{
  static LONG cursel2=0;

  LONG akt=OpenListReq(&AGuide.gt_Docs,
                       cursel2,
                       "Select Document");

  if (akt>=0)
  {
    cursel2=akt;

    if (AGuide.gt_Index) FreeVec(AGuide.gt_Index);
    AGuide.gt_Index=mstrdup(GetDocAddr(akt)->doc_Node.ln_Name);

    SetStrGad(GD_INDEX_STR,AGuide.gt_Index);
  }
}

/* ================================================================================ HandleProjWinIDCMP
** IDCMP-Message auswerten
*/
void HandleProjWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleProjWinIDCMP-function --\n");

  /* Message auslesen */
  while (ProjWin && (imsg=GT_GetIMsg(ProjWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from ProjWin->UserPort\n");

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
        GT_BeginRefresh(ProjWin);
        DrawSeparators(ProjWin,&SepDat,1);
        GT_EndRefresh(ProjWin,TRUE);
        DEBUG_PRINTF("  ProjWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetProjWinPos();
        CloseProjWin();
        WinPosP.ProjWin=FALSE;
        SetProgMenusStates();
        DEBUG_PRINTF("  ProjWin closed\n");

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
          case GD_AGUIDENAME_STR:
            DoStringCopy(&AGuide.gt_Name,GadDat[GD_AGUIDENAME_STR].Gadget);
            DEBUG_PRINTF("  GD_AGUIDENAME_STR processed\n");
            break;

          case GD_AGUIDENAME_SEL:
            DoPathSelect(GD_AGUIDENAME_STR,&AGuide.gt_Name);
            DEBUG_PRINTF("  GD_AGUIDENAME_SEL processed\n");
            break;

          /* Database */
          case GD_DATABASE_STR:
            DoStringCopy(&AGuide.gt_Database,GadDat[GD_DATABASE_STR].Gadget);
            DEBUG_PRINTF("  GD_DATABASE_STR processed\n");
            break;

          /* Copyright */
          case GD_COPYRIGHT_STR:
            DoStringCopy(&AGuide.gt_Copyright,GadDat[GD_COPYRIGHT_STR].Gadget);
            DEBUG_PRINTF("  GD_COPYRIGHT_STR processed\n");
            break;

          /* Master */
          case GD_MASTER_STR:
            DoStringCopy(&AGuide.gt_Master,GadDat[GD_MASTER_STR].Gadget);
            DEBUG_PRINTF("  GD_MASTER_STR processed\n");
            break;

          case GD_MASTER_SEL:
            DoPathSelect(GD_MASTER_STR,&AGuide.gt_Master);
            DEBUG_PRINTF("  GD_MASTER_SEL processed\n");
            break;

          /* Index */
          case GD_INDEX_STR:
            DoStringCopy(&AGuide.gt_Index,GadDat[GD_INDEX_STR].Gadget);
            DEBUG_PRINTF("  GD_INDEX_STR processed\n");
            break;

          case GD_INDEX_SEL:
            DoIndexSelect();
            DEBUG_PRINTF("  GD_INDEX_SEL processed\n");
            break;

          /* Author */
          case GD_AUTHOR_STR:
            DoStringCopy(&AGuide.gt_Author,GadDat[GD_AUTHOR_STR].Gadget);
            DEBUG_PRINTF("  GD_AUTHOR_STR processed\n");
            break;

          /* Version */
          case GD_VERSION_STR:
            DoStringCopy(&AGuide.gt_Version,GadDat[GD_VERSION_STR].Gadget);
            DEBUG_PRINTF("  GD_VERSION_STR processed\n");
            break;

          /* Font */
          case GD_FONT_SEL:
            DoFontSelect();
            DEBUG_PRINTF("  GD_FONT_SEL processed\n");
            break;

          /* Help */
          case GD_HELP_STR:
            DoStringCopy(&AGuide.gt_Help,GadDat[GD_HELP_STR].Gadget);
            DEBUG_PRINTF("  GD_HELP_STR processed\n");
            break;

          case GD_HELP_SEL:
            DoPathSelect(GD_HELP_STR,&AGuide.gt_Help);
            DEBUG_PRINTF("  GD_HELP_SEL processed\n");
            break;

          /* WordWrap */
          case GD_WORDWRAP_CKB:
            AGuide.gt_WordWrap=GadDat[GD_WORDWRAP_CKB].Gadget->Flags&GFLG_SELECTED;
            DEBUG_PRINTF("  GD_WORDWRAP_CKB processed\n");
            break;

          /* Generate */
          case GD_GENERATE_BUT:
            SaveAGuide();
            DEBUG_PRINTF("  GD_GENERATE_BUT processed\n");
            break;

          /* EditDocs */
          case GD_EDITDOCS_BUT:
            OpenDocsWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_EDITDOCS_BUT processed\n");
            break;

          /* Quit */
          case GD_QUIT_BUT:
            CloseAllWindows();
            DEBUG_PRINTF("  GD_QUIT_BUT processed\n");
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
            DoPathSelect(GD_AGUIDENAME_STR,&AGuide.gt_Name);
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
            DoPathSelect(GD_MASTER_STR,&AGuide.gt_Master);
            DEBUG_PRINTF("  KEY_MASTER_UPR processed\n");
            break;

          /* Index */
          case KEY_INDEX_LWR:
            ActGad(GD_INDEX_STR);
            DEBUG_PRINTF("  KEY_INDEX_LWR processed\n");
            break;

          case KEY_INDEX_UPR:
            DoIndexSelect();
            DEBUG_PRINTF("  KEY_INDEX_UPR processed\n");
            break;

          /* WordWrap */
          case KEY_WORDWRAP:
            AGuide.gt_WordWrap=!(GadDat[GD_WORDWRAP_CKB].Gadget->Flags&GFLG_SELECTED);

            GT_SetGadgetAttrs(GadDat[GD_WORDWRAP_CKB].Gadget,
                              ProjWin,NULL,
                              GTCB_Checked,AGuide.gt_WordWrap,
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
            DoPathSelect(GD_HELP_STR,&AGuide.gt_Help);
            DEBUG_PRINTF("  KEY_HELP_UPR processed\n");
            break;

          /* Generate */
          case KEY_GENERATE:
            SaveAGuide();
            DEBUG_PRINTF("  KEY_GENERATE processed\n");
            break;

          /* EditDocs */
          case KEY_EDITDOCS:
            OpenDocsWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_EDITDOCS processed\n");
            break;

          /* Quit */
          case KEY_QUIT:
            CloseAllWindows();
            DEBUG_PRINTF("  KEY_QUIT processed\n");
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
