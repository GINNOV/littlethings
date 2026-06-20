/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ScrSetWin.c
** FUNKTION:  ScrSetWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window      *ScrSetWin=NULL;
       ULONG               ScrSetBit=0;

static UWORD               Width,Height;
static WORD                WZoom[4];

static struct TextAttr     ScrFont,PrintFont;
static BOOL                CustomScreen,AutoScroll;
static ULONG               DisplayID,ScrWidth,ScrHeight;
static UWORD               ScrDepth,Overscan;
static char               *PubScreenName;

static char               *ScrTypeLabels[3];

static struct TagItem      ScrTypeTags[]={GTMX_Active,0,
                                          GTMX_Spacing,0,
                                          GTMX_Labels,(ULONG)ScrTypeLabels,
                                          GTMX_Scaled,TRUE,
                                          TAG_DONE};

static struct TagItem      PubScrNameTags[]={GTST_String,NULL,
                                             GA_Disabled,FALSE,
                                             GTST_MaxChars,STRMAXCHARS,
                                             TAG_DONE};

static struct TagItem      PubScrSelTags[]={GA_Disabled,FALSE,TAG_DONE};

static struct TagItem      ScrModeTags[]={GA_Disabled,FALSE,TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_SCRTYPE_MX      0
#define GD_PUBSCRNAME_STR  1
#define GD_PUBSCRNAME_SEL  2
#define GD_SCRMODE_BUT     3
#define GD_SCRFONT_BUT     4
#define GD_PRINTFONT_BUT   5
#define GD_USE_BUT         6
#define GD_CANCEL_BUT      7
#define GDNUM              8

static struct GadgetData   GadDat[GDNUM];
static struct Gadget      *GadList;
static struct SepData      SepD;

/* VANILLAKEYS */
#define KEY_SCRTYPE1       0
#define KEY_SCRTYPE2       1
#define KEY_PUBSCRNAME_LWR 2
#define KEY_PUBSCRNAME_UPR 3
#define KEY_SCRMODE        4
#define KEY_SCRFONT        5
#define KEY_PRINTFONT      6
#define KEY_USE            7
#define KEY_CANCEL         8
#define KEY_NULL           9
#define KEYNUM            10

static char                VanKeys[KEYNUM];

static void DisableGad(UBYTE);
static void EnableGad(UBYTE);

/* ===================================================================================== InitScrSetWin
** fordert alle wichtigen Resourcen für das ScrSetWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitScrSetWin(void)
{
  struct GadgetData *gd;
  UWORD tmp,typelabw,namelabw,modew,strw,selw,butw,fontw;
  UWORD left,fonth,gadh,yadd,top;

  DEBUG_PRINTF("\n  -- Invoking InitScrSetWin-Function --\n");
  
  /* Gadgetlabels initialisieren */
  GadDat[GD_SCRTYPE_MX].GadgetText    =NULL;
  GadDat[GD_PUBSCRNAME_STR].GadgetText="PubScreen_Name";
  GadDat[GD_PUBSCRNAME_SEL].GadgetText="Sel";
  GadDat[GD_SCRMODE_BUT].GadgetText   ="Screen_Mode";
  GadDat[GD_SCRFONT_BUT].GadgetText   ="_ScreenFont";
  GadDat[GD_PRINTFONT_BUT].GadgetText ="_PrintFont";
  GadDat[GD_USE_BUT].GadgetText       ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText    ="_Cancel";

  ScrTypeLabels[0]="Pu_blicScreen";
  ScrTypeLabels[1]="CustomScreen";
  ScrTypeLabels[2]=NULL;

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  selw=TextLength(&Screen.ps_DummyRPort,
                  GadDat[GD_PUBSCRNAME_SEL].GadgetText,
                  strlen(GadDat[GD_PUBSCRNAME_SEL].GadgetText))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* Breite der ScreenTypeMXLabels ermitteln */
  typelabw=TextLength(&Screen.ps_DummyRPort,
                      ScrTypeLabels[0],
                      strlen(ScrTypeLabels[0]));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 ScrTypeLabels[1],
                 strlen(ScrTypeLabels[1]));

  if (tmp>typelabw) typelabw=tmp;
  typelabw+=INTERWIDTH;
  DEBUG_PRINTF("  typelabw calculated\n");

  /* Breite des String-Gadgets ermitteln */
  strw=Screen.ps_ScrFont->tf_XSize*15;
  namelabw=TextLength(&Screen.ps_DummyRPort,
                      GadDat[GD_PUBSCRNAME_STR].GadgetText,
                      strlen(GadDat[GD_PUBSCRNAME_STR].GadgetText));
  DEBUG_PRINTF("  namelabw calculated\n");

  /* Breite des ScreenMode-Buttons ermitteln */
  modew=TextLength(&Screen.ps_DummyRPort,
                   GadDat[GD_SCRMODE_BUT].GadgetText,
                   strlen(GadDat[GD_SCRMODE_BUT].GadgetText));
  DEBUG_PRINTF("  modew calculated\n");

  fontw=TextLength(&Screen.ps_DummyRPort,
                   GadDat[GD_SCRFONT_BUT].GadgetText,
                   strlen(GadDat[GD_SCRFONT_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_PRINTFONT_BUT].GadgetText,
                 strlen(GadDat[GD_PRINTFONT_BUT].GadgetText));

  if (tmp>fontw) fontw=tmp;
  fontw+=INTERWIDTH;
  DEBUG_PRINTF("  fontw calculated\n");

  butw=TextLength(&Screen.ps_DummyRPort,
                  GadDat[GD_USE_BUT].GadgetText,
                  strlen(GadDat[GD_USE_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_CANCEL_BUT].GadgetText,
                 strlen(GadDat[GD_CANCEL_BUT].GadgetText));

  if (tmp>butw) butw=tmp;
  butw+=3*INTERWIDTH;
  DEBUG_PRINTF("  butw calculated\n");

  if (strw+namelabw+selw>modew)
    modew=strw+namelabw+selw;
  else
    strw=modew-namelabw-selw;

  if (2*fontw>typelabw+MX_WIDTH+modew)
  {
    modew=2*fontw-typelabw-MX_WIDTH;
    strw=modew-namelabw-selw;
  }
  else
    fontw=(typelabw+modew+MX_WIDTH)/2;

  if (butw>fontw)
  {
    fontw=butw;
    modew=2*fontw-typelabw-MX_WIDTH;
    strw=modew-namelabw-selw;
  }

  /* Größen der Gadgets berechnen */
  left =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  fonth=Screen.ps_ScrFont->tf_YSize;
  gadh =fonth+INTERHEIGHT;
  yadd =gadh+INTERHEIGHT;

  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.ScrSetWTop==~0) AGDPrefsP.ScrSetWTop=Screen.ps_Screen->BarHeight+1;
  Width =typelabw+MX_WIDTH+namelabw+strw+selw+3*INTERWIDTH;
  Height=4*yadd+2*INTERHEIGHT+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.ScrSetWLeft;
  WZoom[1]=AGDPrefsP.ScrSetWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1+INTERHEIGHT;

  /* ScrType-MX-Gadget */
  gd=&GadDat[GD_SCRTYPE_MX];
  gd->LeftEdge=left+typelabw;
  gd->TopEdge =top+INTERHEIGHT/2-1;
  gd->Width   =MX_WIDTH;
  gd->Height  =fonth;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_SCRTYPE_MX;
  gd->Type    =MX_KIND;
  gd->Tags    =ScrTypeTags;

  /* PubScrName-String-Gadget */
  gd=&GadDat[GD_PUBSCRNAME_STR];
  gd->LeftEdge=left+typelabw+MX_WIDTH+namelabw+INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_PUBSCRNAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =PubScrNameTags;

  /* PubScrName-Select-Button-Gadget */
  gd=&GadDat[GD_PUBSCRNAME_SEL];
  gd->LeftEdge=GadDat[GD_PUBSCRNAME_STR].LeftEdge+strw;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_PUBSCRNAME_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =PubScrSelTags;

  top+=yadd;

  /* ScrMode-Button-Gadget */
  gd=&GadDat[GD_SCRMODE_BUT];
  gd->LeftEdge=left+typelabw+MX_WIDTH+INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =modew;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_SCRMODE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =ScrModeTags;

  top+=yadd;

  /* ScrFont-Button-Gadget */
  gd=&GadDat[GD_SCRFONT_BUT];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =fontw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_SCRFONT_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* PrintFont-Button-Gadget */
  gd=&GadDat[GD_PRINTFONT_BUT];
  gd->LeftEdge=left+fontw+INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =fontw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_PRINTFONT_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  SepD.LeftEdge=left;
  SepD.TopEdge =top;
  SepD.Width   =typelabw+MX_WIDTH+namelabw+strw+selw+INTERWIDTH;

  top+=SEPHEIGHT+INTERHEIGHT;

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
  gd->LeftEdge=left+Width-butw-2*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_CANCEL_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_SCRTYPE1]      =FindVanillaKey(ScrTypeLabels[0]);
  VanKeys[KEY_SCRTYPE2]      =FindVanillaKey(ScrTypeLabels[1]);
  VanKeys[KEY_PUBSCRNAME_LWR]=FindVanillaKey(GadDat[GD_PUBSCRNAME_STR].GadgetText);
  VanKeys[KEY_PUBSCRNAME_UPR]=toupper(VanKeys[KEY_PUBSCRNAME_LWR]);
  VanKeys[KEY_SCRMODE]       =FindVanillaKey(GadDat[GD_SCRMODE_BUT].GadgetText);
  VanKeys[KEY_SCRFONT]       =FindVanillaKey(GadDat[GD_SCRFONT_BUT].GadgetText);
  VanKeys[KEY_PRINTFONT]     =FindVanillaKey(GadDat[GD_PRINTFONT_BUT].GadgetText);
  VanKeys[KEY_USE]           =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL]        =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]          ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== CloseScrSetWin
** schließt das ScrSettingsWindow
*/
void CloseScrSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseScrSetWin-function --\n");

  if (ScrSetWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(ScrSetWin);
    DEBUG_PRINTF("  MenuStrip at ScrSetWin cleared\n");

    /* Window schließen */
    CloseWindow(ScrSetWin);
    ScrSetWin=NULL;
    ScrSetBit=0;
    DEBUG_PRINTF("  ScrSetWin closed\n");

    FreeGadgets(GadList);
    GadList=NULL;
    DEBUG_PRINTF("  GadList freed\n");

    if (ScrFont.ta_Name) FreeVec(ScrFont.ta_Name);
    if (PrintFont.ta_Name) FreeVec(PrintFont.ta_Name);
    DEBUG_PRINTF("  ScrFont.ta_Name & PrintFont.ta_Name freed\n");
  }

  AGDPrefsP.ScrSetWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ===================================================================================== OpenScrSetWin
** öffnet das ScrSettingsWindow
*/
BOOL OpenScrSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenScrSetWin-function --\n");

  /* wenn noch nicht geöffnet (könnte mehrmals aufgerufen werden) */
  if (!ScrSetWin)
  {
    ScrFont.ta_Name =mstrdup(ScrP.ScrAttr.ta_Name);
    ScrFont.ta_YSize=ScrP.ScrAttr.ta_YSize;
    ScrFont.ta_Style=ScrP.ScrAttr.ta_Style;
    ScrFont.ta_Flags=ScrP.ScrAttr.ta_Flags;

    PrintFont.ta_Name =mstrdup(ScrP.PrintAttr.ta_Name);
    PrintFont.ta_YSize=ScrP.PrintAttr.ta_YSize;
    PrintFont.ta_Style=ScrP.PrintAttr.ta_Style;
    PrintFont.ta_Flags=ScrP.PrintAttr.ta_Flags;

    CustomScreen=ScrP.CustomScreen;
    AutoScroll  =ScrP.AutoScroll;
    DisplayID   =ScrP.DisplayID;
    ScrWidth    =ScrP.Width;
    ScrHeight   =ScrP.Height;
    ScrDepth    =ScrP.Depth;
    Overscan    =ScrP.Overscan;

    ScrTypeTags[1].ti_Data   =(ULONG)2*INTERHEIGHT;
    PubScrNameTags[0].ti_Data=(ULONG)ScrP.PubScreenName;

    if (CustomScreen)
    {
      ScrTypeTags[0].ti_Data   =(ULONG)1;
      PubScrNameTags[1].ti_Data=TRUE;
      PubScrSelTags[0].ti_Data =TRUE;
      ScrModeTags[0].ti_Data   =FALSE;
    }
    else
    {
      ScrTypeTags[0].ti_Data   =(ULONG)0;
      PubScrNameTags[1].ti_Data=FALSE;
      PubScrSelTags[0].ti_Data =FALSE;
      ScrModeTags[0].ti_Data   =TRUE;
    }

    if (GadList=CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (ScrSetWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.ScrSetWLeft,
                         WA_Top,AGDPrefsP.ScrSetWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,"Screen Settings",
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|STRINGIDCMP|MXIDCMP|IDCMP_MENUPICK|\
                                  IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  ScrSetWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(ScrSetWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at ScrSetWin\n");

        GT_RefreshWindow(ScrSetWin,NULL);
        DrawSeparators(ScrSetWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        ScrSetBit=1UL<<ScrSetWin->UserPort->mp_SigBit;
        AGDPrefsP.ScrSetWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening Screen Settings Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "Screen Settings Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseScrSetWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(ScrSetWin);
    WindowToFront(ScrSetWin);
  }

  DEBUG_PRINTF("  ScrSetWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* =================================================================================== GetScrSetWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetScrSetWinPos(void)
{
  if (ScrSetWin)
  {
    AGDPrefsP.ScrSetWLeft=ScrSetWin->LeftEdge;
    AGDPrefsP.ScrSetWTop =ScrSetWin->TopEdge;
  }
}

/* =================================================================================== UpdateScrSetWin
** setzt die Gadgets im ScrSetWin auf die Werte im ScrP
*/
void UpdateScrSetWin(void)
{
  /* wird aus anderen Modulen aufgerufen */
  if (ScrSetWin)
  {
    if (ScrFont.ta_Name) FreeVec(ScrFont.ta_Name);
    ScrFont.ta_Name   =mstrdup(ScrP.ScrAttr.ta_Name);
    ScrFont.ta_YSize  =ScrP.ScrAttr.ta_YSize;
    ScrFont.ta_Style  =ScrP.ScrAttr.ta_Style;
    ScrFont.ta_Flags  =ScrP.ScrAttr.ta_Flags;

    if (PrintFont.ta_Name) FreeVec(PrintFont.ta_Name);
    PrintFont.ta_Name =mstrdup(ScrP.PrintAttr.ta_Name);
    PrintFont.ta_YSize=ScrP.PrintAttr.ta_YSize;
    PrintFont.ta_Style=ScrP.PrintAttr.ta_Style;
    PrintFont.ta_Flags=ScrP.PrintAttr.ta_Flags;

    CustomScreen=ScrP.CustomScreen;
    AutoScroll  =ScrP.AutoScroll;
    DisplayID   =ScrP.DisplayID;
    ScrWidth    =ScrP.Width;
    ScrHeight   =ScrP.Height;
    ScrDepth    =ScrP.Depth;
    Overscan    =ScrP.Overscan;

    GT_SetGadgetAttrs(GadDat[GD_PUBSCRNAME_STR].Gadget,
                      ScrSetWin,NULL,
                      GTST_String,ScrP.PubScreenName,
                      TAG_DONE);

    if (CustomScreen)
    {
      GT_SetGadgetAttrs(GadDat[GD_SCRTYPE_MX].Gadget,
                        ScrSetWin,NULL,
                        GTMX_Active,1,
                        TAG_DONE);

      DisableGad(GD_PUBSCRNAME_STR);
      DisableGad(GD_PUBSCRNAME_SEL);
      EnableGad(GD_SCRMODE_BUT);
    }
    else
    {
      GT_SetGadgetAttrs(GadDat[GD_SCRTYPE_MX].Gadget,
                        ScrSetWin,NULL,
                        GTMX_Active,0,
                        TAG_DONE);

      EnableGad(GD_PUBSCRNAME_STR);
      EnableGad(GD_PUBSCRNAME_SEL);
      DisableGad(GD_SCRMODE_BUT);
    }
  }
}

/* ===================================================================================== CopyScrSetWin
** kopiert die Werte der Gadgets im ScrSetWin
*/
void CopyScrSetWin(void)
{
  DoStringCopy(&ScrP.PubScreenName,GadDat[GD_PUBSCRNAME_STR].Gadget);

  if (ScrP.ScrAttr.ta_Name) FreeVec(ScrP.ScrAttr.ta_Name);
  ScrP.ScrAttr.ta_Name   =mstrdup(ScrFont.ta_Name);
  ScrP.ScrAttr.ta_YSize  =ScrFont.ta_YSize;
  ScrP.ScrAttr.ta_Style  =ScrFont.ta_Style;
  ScrP.ScrAttr.ta_Flags  =ScrFont.ta_Flags;

  if (ScrP.PrintAttr.ta_Name) FreeVec(ScrP.PrintAttr.ta_Name);
  ScrP.PrintAttr.ta_Name =mstrdup(PrintFont.ta_Name);
  ScrP.PrintAttr.ta_YSize=PrintFont.ta_YSize;
  ScrP.PrintAttr.ta_Style=PrintFont.ta_Style;
  ScrP.PrintAttr.ta_Flags=PrintFont.ta_Flags;

  ScrP.CustomScreen=CustomScreen;
  ScrP.AutoScroll  =AutoScroll;
  ScrP.DisplayID   =DisplayID;
  ScrP.Width       =ScrWidth;
  ScrP.Height      =ScrHeight;
  ScrP.Depth       =ScrDepth;
  ScrP.Overscan    =Overscan;
}

/* ========================================================================================= EnableGad
** schaltet ein Gadget ein
*/
static
void EnableGad(UBYTE gdnum)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    ScrSetWin,NULL,
                    GA_Disabled,FALSE,
                    TAG_DONE);
}

/* ======================================================================================== DisableGad
** schaltet ein Gadget aus
*/
static
void DisableGad(UBYTE gdnum)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    ScrSetWin,NULL,
                    GA_Disabled,TRUE,
                    TAG_DONE);
}

/* =================================================================================== DoScrFontSelect
** Auswahl des ScreenFonts per ASL-Requester
*/
static
void DoScrFontSelect(void)
{
  FontRD.Font.ta_Name =ScrFont.ta_Name;
  FontRD.Font.ta_YSize=ScrFont.ta_YSize;
  FontRD.Font.ta_Style=ScrFont.ta_Style;
  FontRD.Font.ta_Flags=ScrFont.ta_Flags;
  FontRD.Flags        =FOF_DOSTYLE;
  FontRD.Title        ="ScreenFont wählen";

  if (OpenFontRequester())
  {
    if (ScrFont.ta_Name) FreeVec(ScrFont.ta_Name);

    ScrFont.ta_Name =FontRD.Font.ta_Name;
    ScrFont.ta_YSize=FontRD.Font.ta_YSize;
    ScrFont.ta_Style=FontRD.Font.ta_Style;
    ScrFont.ta_Flags=FontRD.Font.ta_Flags;
  }
}

/* ================================================================================= DoPrintFontSelect
** Auswahl des PrintFonts per ASL-Requester
*/
static
void DoPrintFontSelect(void)
{
  FontRD.Font.ta_Name =PrintFont.ta_Name;
  FontRD.Font.ta_YSize=PrintFont.ta_YSize;
  FontRD.Font.ta_Style=PrintFont.ta_Style;
  FontRD.Font.ta_Flags=PrintFont.ta_Flags;
  FontRD.Flags        =0;
  FontRD.Title        ="Font wählen";

  if (OpenFontRequester())
  {
    if (PrintFont.ta_Name) FreeVec(PrintFont.ta_Name);

    PrintFont.ta_Name =FontRD.Font.ta_Name;
    PrintFont.ta_YSize=FontRD.Font.ta_YSize;
    PrintFont.ta_Style=FontRD.Font.ta_Style;
    PrintFont.ta_Flags=FontRD.Font.ta_Flags;
  }
}

/* =================================================================================== DoScrModeSelect
** Auswahl des ScreenModes per ASL-Requester
*/
static
void DoScrModeSelect(void)
{
  ScreenRD.Title     ="ScreenMode wählen";
  ScreenRD.DisplayID =DisplayID;
  ScreenRD.Width     =ScrWidth;
  ScreenRD.Height    =ScrHeight;
  ScreenRD.Depth     =ScrDepth;
  ScreenRD.AutoScroll=AutoScroll;
  ScreenRD.Overscan  =Overscan;

  if (OpenScrModeRequester())
  {
    DisplayID =ScreenRD.DisplayID;
    ScrWidth  =ScreenRD.Width;
    ScrHeight =ScreenRD.Height;
    ScrDepth  =ScreenRD.Depth;
    AutoScroll=ScreenRD.AutoScroll;
    Overscan  =ScreenRD.Overscan;
  }
}

/* ============================================================================= DoPubScreenNameSelect
** die PubScreenName-Auswahl per ListReq
*/
static
void DoPubScreenNameSelect(void)
{
  struct List          *pubscrl,l;
  struct PubScreenNode *psn;
  struct Node          *ln;
  LONG                  akt=0;

  l.lh_Head=(struct Node *)&l.lh_Tail;
  l.lh_Tail=NULL;
  l.lh_TailPred=(struct Node *)&l.lh_Head;

  /* PublicScreenListe kopieren */
  if (pubscrl=LockPubScreenList())
  {
    DEBUG_PRINTF("  PubScreenList locked\n");

    psn=(struct PubScreenNode *)pubscrl->lh_Head;

    while(psn->psn_Node.ln_Succ)
    {
      if (ln=(struct Node *)
          AllocMem(sizeof(struct Node),MEMF_ANY|MEMF_PUBLIC))
      {
        if (ln->ln_Name=mstrdup(psn->psn_Node.ln_Name))
        {
          AddTail(&l,ln);
          DEBUG_PRINTF("  PubScreenNode copied\n");
        }
        else
          FreeMem(ln,sizeof(struct Node));
      }

      psn=(struct PubScreenNode *)psn->psn_Node.ln_Succ;
    }

    UnlockPubScreenList();
    DEBUG_PRINTF("  PubScreenList unlocked\n");
  }

  if (ln=FindName(&l,GetString(GadDat[GD_PUBSCRNAME_STR].Gadget)))
  {
    DEBUG_PRINTF("  old PubScreenName found in list, calculating num\n");

    while (ln->ln_Pred->ln_Pred)
    {
      akt++;
      ln=ln->ln_Pred;
    }
  }

  if ((akt=OpenListReq(&l,akt,"Select PublicScreen"))>=0)
  {
    ULONG i=0;

    DEBUG_PRINTF("  choice requested via ListReq\n");

    ln=l.lh_Head;
    while(ln->ln_Succ && i<akt)
    {
      i++;
      ln=ln->ln_Succ;
    }

    DEBUG_PRINTF("  num calculated\n");

    if (i==akt && ln->ln_Succ)
    {
      GT_SetGadgetAttrs(GadDat[GD_PUBSCRNAME_STR].Gadget,
                        ScrSetWin,NULL,
                        GTST_String,ln->ln_Name,
                        TAG_DONE);
      DEBUG_PRINTF("  GD_PUBSCRNAME_STR set\n");
    }
  }

  ln=RemTail(&l);
  while(ln)
  {
    if (ln->ln_Name) FreeVec(ln->ln_Name);
    FreeMem(ln,sizeof(struct Node));
    ln=RemTail(&l);
    DEBUG_PRINTF("  node freed\n");
  }
}

/* ============================================================================== HandleScrSetWinIDCMP
** IDCMP-Message auswerten
*/
void HandleScrSetWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleScrSetWinIDCMP-function --\n");

  /* Message auslesen */
  while (ScrSetWin && (imsg=GT_GetIMsg(ScrSetWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from ScrSetWin->UserPort\n");

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
        GT_BeginRefresh(ScrSetWin);
        DrawSeparators(ScrSetWin,&SepD,1);
        GT_EndRefresh(ScrSetWin,TRUE);
        DEBUG_PRINTF("  ScrSetWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetScrSetWinPos();
        CloseScrSetWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  ScrSetWin closed\n");

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
          case GD_PUBSCRNAME_SEL:
            DoPubScreenNameSelect();
            DEBUG_PRINTF("  GD_PUBSCRNAME_SEL processed\n");
            break;

          case GD_SCRMODE_BUT:
            DoScrModeSelect();
            DEBUG_PRINTF("  GD_SCRMODE_BUT processed\n");
            break;

          case GD_SCRFONT_BUT:
            DoScrFontSelect();
            DEBUG_PRINTF("  GD_SCRFONT_BUT processed\n");
            break;

          case GD_PRINTFONT_BUT:
            DoPrintFontSelect();
            DEBUG_PRINTF("  GD_PRINTFONT_BUT processed\n");
            break;

          case GD_USE_BUT:
            CopyScrSetWin();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          case GD_CANCEL_BUT:
            if (AGDPrefsP.ReqMode)
            {
              GetScrSetWinPos();
              CloseScrSetWin();
              SetProgMenusStates();
            }
            else
              UpdateScrSetWin();

            DEBUG_PRINTF("  GD_CANCEL_BUT processed\n");
            break;
        }

        DEBUG_PRINTF("  Gadgets processed\n");
        break;
      }

      /* MX-Gadget? */
      case IDCMP_GADGETDOWN:
        CustomScreen=code;

        if (CustomScreen)
        {
          DisableGad(GD_PUBSCRNAME_STR);
          DisableGad(GD_PUBSCRNAME_SEL);
          EnableGad(GD_SCRMODE_BUT);
        }
        else
        {
          EnableGad(GD_PUBSCRNAME_STR);
          EnableGad(GD_PUBSCRNAME_SEL);
          DisableGad(GD_SCRMODE_BUT);
        }
        DEBUG_PRINTF("  GD_SCRTYPE_MX processed\n");
        break;

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
      {
        /* welches Gadget */
        switch (MatchVanillaKey(code,&VanKeys[0]))
        {
          case KEY_SCRTYPE1:
          case KEY_SCRTYPE2:
            if (CustomScreen==1) CustomScreen=0; else CustomScreen=1;
            GT_SetGadgetAttrs(GadDat[GD_SCRTYPE_MX].Gadget,
                              ScrSetWin,NULL,
                              GTMX_Active,CustomScreen,
                              TAG_DONE);
            if (CustomScreen)
            {
              DisableGad(GD_PUBSCRNAME_STR);
              DisableGad(GD_PUBSCRNAME_SEL);
              EnableGad(GD_SCRMODE_BUT);
            }
            else
            {
              EnableGad(GD_PUBSCRNAME_STR);
              EnableGad(GD_PUBSCRNAME_SEL);
              DisableGad(GD_SCRMODE_BUT);
            }

            DEBUG_PRINTF("  KEY_SCRTYPE processed\n");
            break;

          case KEY_PUBSCRNAME_LWR:
            if (!CustomScreen)
              ActivateGadget(GadDat[GD_PUBSCRNAME_STR].Gadget,ScrSetWin,NULL);

            DEBUG_PRINTF("  KEY_PUBSCRNAME_LWR processed\n");
            break;

          case KEY_PUBSCRNAME_UPR:
            if (!CustomScreen)
              DoPubScreenNameSelect();

            DEBUG_PRINTF("  KEY_PUBSCRNAME_UPR processed\n");
            break;

          case KEY_SCRMODE:
            if (CustomScreen)
              DoScrModeSelect();
            DEBUG_PRINTF("  KEY_SCRMODE processed\n");
            break;

          case KEY_SCRFONT:
            DoScrFontSelect();
            DEBUG_PRINTF("  KEY_SCRFONT processed\n");
            break;

          case KEY_PRINTFONT:
            DoPrintFontSelect();
            DEBUG_PRINTF("  KEY_PRINTFONT processed\n");
            break;

          case KEY_USE:
            CopyScrSetWin();
            DEBUG_PRINTF("  KEY_USE processed\n");

          case KEY_CANCEL:
            if (AGDPrefsP.ReqMode)
            {
              GetScrSetWinPos();
              CloseScrSetWin();
              SetProgMenusStates();
            }
            else
              UpdateScrSetWin();

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
