/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     CommSetWin.c
** FUNKTION:  CommSetWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window      *CommSetWin=NULL;
       ULONG               CommSetBit=0;

static UWORD               Width,Height;
static WORD                WZoom[4];

static UBYTE               CommType=COMT_LINK,FGPen=COL_TEXT,BGPen=COL_BG;

static char               *CommStrs[COMT_STYLE+2];
static char               *ColStrs[COL_HIGHL+2];

static struct TagItem      TypeTags[]={GTCY_Active,0,
                                       GTCY_Labels,(ULONG)&CommStrs,
                                       TAG_DONE};

static struct TagItem      CommTags[]={GTST_String,NULL,
                                       GTST_MaxChars,STRMAXCHARS,
                                       TAG_DONE};

static struct TagItem      FGPenTags[]={GTCY_Active,0,
                                        GTCY_Labels,(ULONG)ColStrs,
                                        TAG_DONE};

static struct TagItem      BGPenTags[]={GTCY_Active,0,
                                        GTCY_Labels,(ULONG)ColStrs,
                                        TAG_DONE};

static struct TagItem      BoldTags[]={GTCB_Checked,FALSE,
                                       GTCB_Scaled,TRUE,
                                       TAG_DONE};

static struct TagItem      ItalicTags[]={GTCB_Checked,FALSE,
                                         GTCB_Scaled,TRUE,
                                         TAG_DONE};

static struct TagItem      ULineTags[]={GTCB_Checked,FALSE,
                                        GTCB_Scaled,TRUE,
                                        TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_TYPE_CYC        0
#define GD_COMM_STR        1
#define GD_FGPEN_CYC       2
#define GD_BGPEN_CYC       3
#define GD_BOLD_CKB        4
#define GD_ITALIC_CKB      5
#define GD_ULINE_CKB       6
#define GD_USE_BUT         7
#define GD_CANCEL_BUT      8
#define GDNUM              9

static struct GadgetData   GadDat[GDNUM];
static struct Gadget      *GadList;
static struct SepData      SepD;

/* VANILLAKEYS */
#define KEY_TYPE_LWR       0
#define KEY_TYPE_UPR       1
#define KEY_COMM           2
#define KEY_FGPEN_LWR      3
#define KEY_FGPEN_UPR      4
#define KEY_BGPEN_LWR      5
#define KEY_BGPEN_UPR      6
#define KEY_BOLD           7
#define KEY_ITALIC         8
#define KEY_ULINE          9
#define KEY_USE           10
#define KEY_CANCEL        11
#define KEY_NULL          12
#define KEYNUM            13

static char                VanKeys[KEYNUM];

static void SetCheckBoxGad(UBYTE,BOOL);
static void SetCycleGad(UBYTE,UBYTE);

/* ==================================================================================== InitCommSetWin
** fordert alle wichtigen Resourcen für das CommSetWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitCommSetWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,labw,strw,butw,italicw,ulinew,left,lableft,gadh,yadd,top;

  DEBUG_PRINTF("\n  -- Invoking InitCommSetWin-Function --\n");
  
  /* Gadgetlabels initialisieren */
  GadDat[GD_TYPE_CYC].GadgetText   ="Comm_Type";
  GadDat[GD_COMM_STR].GadgetText   ="Co_mmand";
  GadDat[GD_FGPEN_CYC].GadgetText  ="_Foreground";
  GadDat[GD_BGPEN_CYC].GadgetText  ="_Background";
  GadDat[GD_BOLD_CKB].GadgetText   ="B_old";
  GadDat[GD_ITALIC_CKB].GadgetText ="_Italic";
  GadDat[GD_ULINE_CKB].GadgetText  ="Under_lined";
  GadDat[GD_USE_BUT].GadgetText    ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText ="_Cancel";

  CommStrs[COMT_LINK]   ="link to node";
  CommStrs[COMT_ALINK]  ="link to node in other Window";
  CommStrs[COMT_RX]     ="execute ARexx script";
  CommStrs[COMT_RXS]    ="execute ARexx command-line";
  CommStrs[COMT_SYSTEM] ="execute DOS command-line";
  CommStrs[COMT_CLOSE]  ="close window";
  CommStrs[COMT_QUIT]   ="quit";
  CommStrs[COMT_STYLE]  ="set style and colours";
  CommStrs[COMT_STYLE+1]=NULL;

  ColStrs[COL_TEXT]    ="Text";
  ColStrs[COL_SHINE]   ="Shine";
  ColStrs[COL_SHADOW]  ="Shadow";
  ColStrs[COL_FILL]    ="Fill";
  ColStrs[COL_FILLTEXT]="Filltext";
  ColStrs[COL_BG]      ="Background";
  ColStrs[COL_HIGHL]   ="Highlight";
  ColStrs[COL_HIGHL+1] =NULL;

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Gadgetlabel-Breite der Gadgets */
  labw=0;
  for(i=GD_TYPE_CYC;i<=GD_BOLD_CKB;i++)
  {
    if (GadDat[i].GadgetText)
    {
      tmp=TextLength(&Screen.ps_DummyRPort,GadDat[i].GadgetText,strlen(GadDat[i].GadgetText));
      if (tmp>labw) labw=tmp;
    }
  }
  labw+=INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  italicw=TextLength(&Screen.ps_DummyRPort,
                     GadDat[GD_ITALIC_CKB].GadgetText,
                     strlen(GadDat[GD_ITALIC_CKB].GadgetText))+INTERWIDTH;

  ulinew=TextLength(&Screen.ps_DummyRPort,
                     GadDat[GD_ULINE_CKB].GadgetText,
                     strlen(GadDat[GD_ULINE_CKB].GadgetText))+INTERWIDTH;

  /* Breite des CommType-Cycle-Gadgets ermitteln */
  strw=Screen.ps_ScrFont->tf_XSize*15;
  for (i=COMT_LINK;i<=COMT_STYLE;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,CommStrs[i],strlen(CommStrs[i]));
    if (tmp>strw) strw=tmp;
  }

  /* Breite der #?Pen-Cycle-Gadgets ermittlen */
  for (i=COL_TEXT;i<=COL_HIGHL;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,ColStrs[i],strlen(ColStrs[i]));
    if (tmp>strw) strw=tmp;
  }
  strw+=4*INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  butw=TextLength(&Screen.ps_DummyRPort,
                  GadDat[GD_USE_BUT].GadgetText,
                  strlen(GadDat[GD_USE_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_CANCEL_BUT].GadgetText,
                 strlen(GadDat[GD_CANCEL_BUT].GadgetText));

  if (tmp>butw) butw=tmp;
  butw+=3*INTERWIDTH;

  if (italicw+ulinew+3*CHECKBOX_WIDTH+2*INTERWIDTH>strw)
    strw=italicw+ulinew+3*CHECKBOX_WIDTH+2*INTERWIDTH;

  if (2*butw+INTERWIDTH>strw+labw) strw=2*butw+INTERWIDTH-labw;

  /* Größen der Gadgets berechnen */
  left   =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  lableft=left+labw;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;

  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.CommSetWTop==~0) AGDPrefsP.CommSetWTop=Screen.ps_Screen->BarHeight+1;
  Width =strw+labw+2*INTERWIDTH;
  Height=6*yadd+2*INTERHEIGHT+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.CommSetWLeft;
  WZoom[1]=AGDPrefsP.CommSetWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1+INTERHEIGHT;

  /* Type-Cycle-Gadget */
  gd=&GadDat[GD_TYPE_CYC];
  gd->LeftEdge  =lableft;
  gd->TopEdge   =top;
  gd->Width     =strw;
  gd->Height    =gadh;
  gd->Flags     =PLACETEXT_LEFT;
  gd->GadgetID  =GD_TYPE_CYC;
  gd->Type      =CYCLE_KIND;
  gd->Tags      =TypeTags;

  top+=yadd;

  /* Comm-String-Gadget */
  gd=&GadDat[GD_COMM_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_COMM_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =CommTags;

  top+=yadd;

  /* FGPen-Cycle-Gadget */
  gd=&GadDat[GD_FGPEN_CYC];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FGPEN_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =FGPenTags;

  top+=yadd;

  /* BGPen-Cycle-Gadget */
  gd=&GadDat[GD_BGPEN_CYC];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_BGPEN_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =BGPenTags;

  top+=yadd;

  /* Bold-CheckBox-Gadget */
  gd=&GadDat[GD_BOLD_CKB];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_BOLD_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =BoldTags;

  /* Italic-CheckBox-Gadget */
  gd=&GadDat[GD_ITALIC_CKB];
  gd->LeftEdge=lableft+((italicw+INTERWIDTH+CHECKBOX_WIDTH)*strw)/(3*CHECKBOX_WIDTH+ulinew+2*INTERWIDTH+italicw);
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_ITALIC_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =ItalicTags;

  /* ULine-CheckBox-Gadget */
  gd=&GadDat[GD_ULINE_CKB];
  gd->LeftEdge=left+Width-CHECKBOX_WIDTH-2*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_ULINE_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =ULineTags;

  top+=yadd;

  SepD.LeftEdge=left;
  SepD.TopEdge =top;
  SepD.Width   =labw+strw;

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
  VanKeys[KEY_TYPE_LWR] =FindVanillaKey(GadDat[GD_TYPE_CYC].GadgetText);
  VanKeys[KEY_TYPE_UPR] =toupper(VanKeys[KEY_TYPE_LWR]);
  VanKeys[KEY_COMM]     =FindVanillaKey(GadDat[GD_COMM_STR].GadgetText);
  VanKeys[KEY_FGPEN_LWR]=FindVanillaKey(GadDat[GD_FGPEN_CYC].GadgetText);
  VanKeys[KEY_FGPEN_UPR]=toupper(VanKeys[KEY_FGPEN_LWR]);
  VanKeys[KEY_BGPEN_LWR]=FindVanillaKey(GadDat[GD_BGPEN_CYC].GadgetText);
  VanKeys[KEY_BGPEN_UPR]=toupper(VanKeys[KEY_BGPEN_LWR]);
  VanKeys[KEY_BOLD]     =FindVanillaKey(GadDat[GD_BOLD_CKB].GadgetText);
  VanKeys[KEY_ITALIC]   =FindVanillaKey(GadDat[GD_ITALIC_CKB].GadgetText);
  VanKeys[KEY_ULINE]    =FindVanillaKey(GadDat[GD_ULINE_CKB].GadgetText);
  VanKeys[KEY_USE]      =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL]   =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]     ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CloseCommSetWin
** schließt das CommSettingsWindow
*/
void CloseCommSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseCommSetWin-function --\n");

  if (CommSetWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(CommSetWin);
    DEBUG_PRINTF("  MenuStrip at CommSetWin cleared\n");

    /* Window schließen */
    CloseWindow(CommSetWin);
    CommSetWin=NULL;
    CommSetBit=0;
    DEBUG_PRINTF("  CommSetWin closed\n");

    FreeGadgets(GadList);
    GadList=NULL;
    DEBUG_PRINTF("  GadList freed\n");
  }

  AGDPrefsP.CommSetWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== OpenCommSetWin
** öffnet das CommSettingsWindow
*/
BOOL OpenCommSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenCommSetWin-function --\n");

  /* wenn noch nicht geöffnet (könnte mehrmals aufgerufen werden) */
  if (!CommSetWin)
  {
    CommType=CommP.CommType;
    FGPen=CommP.FGPen;
    BGPen=CommP.BGPen;

    TypeTags[0].ti_Data      =(ULONG)CommP.CommType;
    CommTags[0].ti_Data      =(ULONG)CommP.StrData;
    FGPenTags[0].ti_Data     =(ULONG)FGPen;
    BGPenTags[0].ti_Data     =(ULONG)BGPen;
    BoldTags[0].ti_Data      =(ULONG)CommP.Style&FSF_BOLD;
    ItalicTags[0].ti_Data    =(ULONG)CommP.Style&FSF_ITALIC;
    ULineTags[0].ti_Data     =(ULONG)CommP.Style&FSF_UNDERLINED;

    if (GadList=CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (CommSetWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.CommSetWLeft,
                         WA_Top,AGDPrefsP.CommSetWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,"Command Editor Settings",
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|STRINGIDCMP|CYCLEIDCMP|CHECKBOXIDCMP|INTEGERIDCMP|\
                                  IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|\
                                  IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  CommSetWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(CommSetWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at CommSetWin\n");

        GT_RefreshWindow(CommSetWin,NULL);
        DrawSeparators(CommSetWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        CommSetBit=1UL<<CommSetWin->UserPort->mp_SigBit;
        AGDPrefsP.CommSetWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening Command Editor Settings Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "Command Editor Settings Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseCommSetWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(CommSetWin);
    WindowToFront(CommSetWin);
  }

  DEBUG_PRINTF("  CommSetWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* ================================================================================== GetCommSetWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetCommSetWinPos(void)
{
  if (CommSetWin)
  {
    AGDPrefsP.CommSetWLeft=CommSetWin->LeftEdge;
    AGDPrefsP.CommSetWTop =CommSetWin->TopEdge;
  }
}

/* ================================================================================== UpdateCommSetWin
** setzt die Gadgets im CommSetWin auf die Werte im CommP
*/
void UpdateCommSetWin(void)
{
  /* wird aus anderen Modulen aufgerufen */
  if (CommSetWin)
  {
    CommType=CommP.CommType;
    FGPen=CommP.FGPen;
    BGPen=CommP.BGPen;

    SetCycleGad(GD_TYPE_CYC,CommType);
    GT_SetGadgetAttrs(GadDat[GD_COMM_STR].Gadget,
                      CommSetWin,NULL,
                      GTST_String,CommP.StrData,
                      TAG_DONE);
    SetCycleGad(GD_FGPEN_CYC,FGPen);
    SetCycleGad(GD_BGPEN_CYC,BGPen);
    SetCheckBoxGad(GD_BOLD_CKB,CommP.Style&FSF_BOLD);
    SetCheckBoxGad(GD_ITALIC_CKB,CommP.Style&FSF_ITALIC);
    SetCheckBoxGad(GD_ULINE_CKB,CommP.Style&FSF_UNDERLINED);
  }
}

/* ==================================================================================== CopyCommSetWin
** kopiert die Werte der Gadgets im CommSetWin
*/
void CopyCommSetWin(void)
{
  CommP.CommType=CommType;
  DoStringCopy(&CommP.StrData,GadDat[GD_COMM_STR].Gadget);
  CommP.FGPen=FGPen;
  CommP.BGPen=BGPen;

  if (GadDat[GD_BOLD_CKB].Gadget->Flags&GFLG_SELECTED)
    CommP.Style|=FSF_BOLD;
  else
    CommP.Style&=~FSF_BOLD;

  if (GadDat[GD_ITALIC_CKB].Gadget->Flags&GFLG_SELECTED)
    CommP.Style|=FSF_ITALIC;
  else
    CommP.Style&=~FSF_ITALIC;

  if (GadDat[GD_ULINE_CKB].Gadget->Flags&GFLG_SELECTED)
    CommP.Style|=FSF_UNDERLINED;
  else
    CommP.Style&=~FSF_UNDERLINED;
}

/* ==================================================================================== SetCheckBoxGad
** setzt ein CheckBox-Gadget im CommSetWin
*/
static
void SetCheckBoxGad(UBYTE gdnum,BOOL state)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    CommSetWin,NULL,
                    GTCB_Checked,state,
                    TAG_DONE);
}

/* ======================================================================================= SetCycleGad
** setzt ein Cycle-Gadget im CommSetWin
*/
static
void SetCycleGad(UBYTE gdnum,UBYTE active)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    CommSetWin,NULL,
                    GTCY_Active,active,
                    TAG_DONE);
}

/* ================================================================================ HandleCommSetWinIDCMP
** IDCMP-Message auswerten
*/
void HandleCommSetWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleCommSetWinIDCMP-function --\n");

  /* Message auslesen */
  while (CommSetWin && (imsg=GT_GetIMsg(CommSetWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from CommSetWin->UserPort\n");

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
        GT_BeginRefresh(CommSetWin);
        DrawSeparators(CommSetWin,&SepD,1);
        GT_EndRefresh(CommSetWin,TRUE);
        DEBUG_PRINTF("  CommSetWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetCommSetWinPos();
        CloseCommSetWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  CommSetWin closed\n");

        break;

      /* Menu angewählt? */
      case IDCMP_MENUPICK:
        HandleProgMenus(code);
        DEBUG_PRINTF("  Menus handled\n");
        break;

      /* Gadget angeklickt? */
      case IDCMP_GADGETUP:
      {
        /* welches Gadget */
        switch (((struct Gadget *)iaddr)->GadgetID)
        {
          case GD_TYPE_CYC:
            CommType=code;
            DEBUG_PRINTF("  GD_TYPE_CYC processed\n");
            break;

          case GD_FGPEN_CYC:
            FGPen=code;
            DEBUG_PRINTF("  GD_FGPEN_CYC processed\n");
            break;

          case GD_BGPEN_CYC:
            BGPen=code;
            DEBUG_PRINTF("  GD_BGPEN_CYC processed\n");
            break;

          case GD_USE_BUT:
            CopyCommSetWin();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          case GD_CANCEL_BUT:
            if (AGDPrefsP.ReqMode)
            {
              GetCommSetWinPos();
              CloseCommSetWin();
              SetProgMenusStates();
            }
            else
              UpdateCommSetWin();

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
          case KEY_TYPE_LWR:
            if (CommType<COMT_STYLE) CommType++; else CommType=COMT_LINK;
            SetCycleGad(GD_TYPE_CYC,CommType);
            DEBUG_PRINTF("  KEY_TYPE_LWR processed\n");
            break;

          case KEY_TYPE_UPR:
            if (CommType>COMT_LINK) CommType--; else CommType=COMT_STYLE;
            SetCycleGad(GD_TYPE_CYC,CommType);
            DEBUG_PRINTF("  KEY_TYPE_UPR processed\n");
            break;

          case KEY_COMM:
            ActivateGadget(GadDat[GD_COMM_STR].Gadget,CommSetWin,NULL);
            DEBUG_PRINTF("  KEY_COMM_LWR processed\n");
            break;

          case KEY_FGPEN_LWR:
            if (FGPen<COL_HIGHL) FGPen++; else FGPen=COL_TEXT;
            SetCycleGad(GD_FGPEN_CYC,FGPen);
            DEBUG_PRINTF("  KEY_FGPEN_LWR processed\n");
            break;

          case KEY_FGPEN_UPR:
            if (FGPen>COL_TEXT) FGPen--; else FGPen=COL_HIGHL;
            SetCycleGad(GD_FGPEN_CYC,FGPen);
            DEBUG_PRINTF("  KEY_FGPEN_UPR processed\n");
            break;

          case KEY_BGPEN_LWR:
            if (BGPen<COL_HIGHL) BGPen++; else BGPen=COL_TEXT;
            SetCycleGad(GD_BGPEN_CYC,BGPen);
            DEBUG_PRINTF("  KEY_BGPEN_LWR processed\n");
            break;

          case KEY_BGPEN_UPR:
            if (BGPen>COL_TEXT) BGPen--; else BGPen=COL_HIGHL;
            SetCycleGad(GD_BGPEN_CYC,BGPen);
            DEBUG_PRINTF("  KEY_BGPEN_UPR processed\n");
            break;

          case KEY_BOLD:
            SetCheckBoxGad(GD_BOLD_CKB,!(GadDat[GD_BOLD_CKB].Gadget->Flags&GFLG_SELECTED));
            DEBUG_PRINTF("  KEY_BOLD processed\n");
            break;

          case KEY_ITALIC:
            SetCheckBoxGad(GD_ITALIC_CKB,!(GadDat[GD_ITALIC_CKB].Gadget->Flags&GFLG_SELECTED));
            DEBUG_PRINTF("  KEY_ITALIC processed\n");
            break;

          case KEY_ULINE:
            SetCheckBoxGad(GD_ULINE_CKB,!(GadDat[GD_ULINE_CKB].Gadget->Flags&GFLG_SELECTED));
            DEBUG_PRINTF("  KEY_ULINE processed\n");
            break;

          case KEY_USE:
            CopyCommSetWin();
            DEBUG_PRINTF("  KEY_USE processed\n");

          case KEY_CANCEL:
            if (AGDPrefsP.ReqMode)
            {
              GetCommSetWinPos();
              CloseCommSetWin();
              SetProgMenusStates();
            }
            else
              UpdateCommSetWin();
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
