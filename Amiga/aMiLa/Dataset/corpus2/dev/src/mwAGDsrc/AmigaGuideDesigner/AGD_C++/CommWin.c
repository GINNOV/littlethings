/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     CommWin.c
** FUNKTION:  CommWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

       struct Window      *CommWin=NULL;
       ULONG               CommBit=0;

static UWORD               MinWidth,MinHeight;
static WORD                WZoom[4];
static ULONG               OldSecs,OldMics;

static struct List         Comms;

static char               *CommStrs[COMT_STYLE+1];
static char               *ColStrs[COL_HIGHL+2];

static struct TagItem      TypeTags[]={GTLV_Selected,0,
                                       GTLV_Top,0,
                                       GTLV_Labels,(ULONG)&Comms,
                                       GTLV_ShowSelected,NULL,
                                       TAG_DONE};

static struct TagItem      CommTags[]={GTST_String,NULL,
                                       GA_Disabled,FALSE,
                                       GTST_MaxChars,STRMAXCHARS,
                                       TAG_DONE};

static struct TagItem      CommSelTags[]={GA_Disabled,FALSE,TAG_DONE};

static struct TagItem      FGPenTags[]={GTCY_Active,0,
                                        GA_Disabled,FALSE,
                                        GTCY_Labels,(ULONG)ColStrs,
                                        TAG_DONE};

static struct TagItem      BGPenTags[]={GTCY_Active,0,
                                        GA_Disabled,FALSE,
                                        GTCY_Labels,(ULONG)ColStrs,
                                        TAG_DONE};

static struct TagItem      BoldTags[]={GTCB_Checked,FALSE,
                                       GA_Disabled,FALSE,
                                       GTCB_Scaled,TRUE,
                                       TAG_DONE};

static struct TagItem      ItalicTags[]={GTCB_Checked,FALSE,
                                         GA_Disabled,FALSE,
                                         GTCB_Scaled,TRUE,
                                         TAG_DONE};

static struct TagItem      ULineTags[]={GTCB_Checked,FALSE,
                                        GA_Disabled,FALSE,
                                        GTCB_Scaled,TRUE,
                                        TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_TYPE_LST        0
#define GD_COMM_STR        1
#define GD_COMM_SEL        2
#define GD_FGPEN_CYC       3
#define GD_BGPEN_CYC       4
#define GD_ULINE_CKB       5
#define GD_ITALIC_CKB      6
#define GD_BOLD_CKB        7
#define GDNUM              8

static struct GadgetData   GadDat[GDNUM];
static struct Gadget      *GadList,*SizeGadList;
static BOOL                GadListRemoved;

/* VANILLAKEYS */
#define KEY_TYPE_LWR       0
#define KEY_TYPE_UPR       1
#define KEY_COMM_LWR       2
#define KEY_COMM_UPR       3
#define KEY_FGPEN_LWR      4
#define KEY_FGPEN_UPR      5
#define KEY_BGPEN_LWR      6
#define KEY_BGPEN_UPR      7
#define KEY_ULINE          8
#define KEY_ITALIC         9
#define KEY_BOLD          10
#define KEY_NULL          11
#define KEYNUM            12

static char                VanKeys[KEYNUM];

static void SetCommStrGad(char *);
static void SetCheckBoxGad(UBYTE,BOOL);
static void SetCycleGad(UBYTE,UBYTE);
static void DoPathSelect(void);
static void DoDocumentSelect(void);
static void EnableGad(UBYTE);
static void DisableGad(UBYTE);

/* ===================================================================================== UnInitCommWin
** gibt alle für das CommWindow angeforderten Resourcen frei
*/
void UnInitCommWin(void)
{
  struct Node *comstr;

  DEBUG_PRINTF("\n  -- Invoking UnInitCommWin-function --\n");

  while (comstr=RemTail(&Comms)) FreeMem(comstr,sizeof(struct Node));
  DEBUG_PRINTF("  Comms-List freed\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= InitCommWin
** fordert alle wichtigen Resourcen für das CommWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
BOOL InitCommWin(void)
{
  BOOL rc=TRUE;
  struct GadgetData *gd;
  struct Node *comstr;
  ULONG i;
  UWORD tmp,labw,selw,typw,strw,left,gadh,boldw,italicw;
  char  *sel="Sel";

  DEBUG_PRINTF("\n  -- Invoking InitCommWin-Function --\n");
  
  /* Gadgetlabels initialisieren */
  GadDat[GD_TYPE_LST].GadgetText  =NULL;
  GadDat[GD_COMM_STR].GadgetText  ="_Command";
  GadDat[GD_COMM_SEL].GadgetText  =sel;
  GadDat[GD_FGPEN_CYC].GadgetText ="_Foreground";
  GadDat[GD_BGPEN_CYC].GadgetText ="_Background";
  GadDat[GD_ULINE_CKB].GadgetText ="_Underlined";
  GadDat[GD_ITALIC_CKB].GadgetText="_Italic";
  GadDat[GD_BOLD_CKB].GadgetText  ="B_old";

  CommStrs[COMT_LINK]  ="link to node";
  CommStrs[COMT_ALINK] ="link to node in other Window";
  CommStrs[COMT_RX]    ="execute ARexx script";
  CommStrs[COMT_RXS]   ="execute ARexx command-line";
  CommStrs[COMT_SYSTEM]="execute DOS command-line";
  CommStrs[COMT_CLOSE] ="close window";
  CommStrs[COMT_QUIT]  ="quit";
  CommStrs[COMT_STYLE] ="set style and colours";

  ColStrs[COL_TEXT]    ="Text";
  ColStrs[COL_SHINE]   ="Shine";
  ColStrs[COL_SHADOW]  ="Shadow";
  ColStrs[COL_FILL]    ="Fill";
  ColStrs[COL_FILLTEXT]="Filltext";
  ColStrs[COL_BG]      ="Background";
  ColStrs[COL_HIGHL]   ="Highlight";
  ColStrs[COL_HIGHL+1] =NULL;

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Breite des Select-Buttons ermitteln */
  selw=TextLength(&Screen.ps_DummyRPort,
                  sel,strlen(sel))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* Gadgetlabel-Breite des String-Gadgets */
  labw=0;
  for(i=GD_COMM_STR;i<=GD_ULINE_CKB;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,GadDat[i].GadgetText,strlen(GadDat[i].GadgetText));
    if (tmp>labw) labw=tmp;
  }
  labw+=INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  /* Breite des Italic-Gadgets */
  italicw=TextLength(&Screen.ps_DummyRPort,GadDat[GD_ITALIC_CKB].GadgetText,strlen(GadDat[GD_ITALIC_CKB].GadgetText));
  DEBUG_PRINTF("  italicw calculated\n");

  /* Breite des Italic-Gadgets */
  boldw=TextLength(&Screen.ps_DummyRPort,GadDat[GD_BOLD_CKB].GadgetText,strlen(GadDat[GD_BOLD_CKB].GadgetText));
  DEBUG_PRINTF("  boldw calculated\n");

  /* Breite des CommType-Gadgets ermitteln */
  typw=0;
  for (i=COMT_LINK;i<=COMT_STYLE;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,CommStrs[i],strlen(CommStrs[i]));
    if (tmp>typw) typw=tmp;
  }
  typw+=4*INTERWIDTH;

  strw=Screen.ps_ScrFont->tf_XSize*15;

  /* Breite der Cycle-Gadgets ermittlen */
  for (i=COL_TEXT;i<=COL_HIGHL;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,ColStrs[i],strlen(ColStrs[i]));
    if (tmp>strw) strw=tmp;
  }
  strw+=4*INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  if (strw<italicw+boldw+2*INTERWIDTH+3*CHECKBOX_WIDTH)
    strw=italicw+boldw+2*INTERWIDTH+3*CHECKBOX_WIDTH;

  if (strw+labw>typw)
    typw=strw+labw;
  else
    strw=typw-labw;

  /* Größen der Gadgets berechnen */
  left=Screen.ps_Screen->WBorLeft+INTERWIDTH;
  gadh=Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;

  DEBUG_PRINTF("  gad-variables calculated\n");

  MinWidth=typw+Screen.ps_Screen->WBorLeft+Screen.ps_Screen->WBorRight+2*INTERWIDTH;
  MinHeight=Screen.ps_WBorTop+Screen.ps_ScrFont->tf_YSize+4*gadh+7*INTERHEIGHT+Screen.ps_WBorBottom;

  /* Windowgröße */
  if (WinPosP.CommWTop==~0)    WinPosP.CommWTop=Screen.ps_Screen->BarHeight+1;
  if (WinPosP.CommWWidth==~0)  WinPosP.CommWWidth=MinWidth;
  if (WinPosP.CommWHeight==~0) WinPosP.CommWHeight=MinHeight+3*Screen.ps_ScrFont->tf_YSize;

  if (WinPosP.CommWWidth<MinWidth) WinPosP.CommWWidth=MinWidth;
  if (WinPosP.CommWHeight<MinHeight) WinPosP.CommWHeight=MinHeight;

  /* alternative Windowgröße */
  WZoom[0]=WinPosP.CommWLeft;
  WZoom[1]=WinPosP.CommWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_WBorTop;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  /* Type-ListView-Gadget */
  gd=&GadDat[GD_TYPE_LST];
  gd->LeftEdge  =left;
  gd->TopEdge   =Screen.ps_WBorTop+INTERHEIGHT;
  gd->Flags     =PLACETEXT_ABOVE;
  gd->GadgetID  =GD_TYPE_LST;
  gd->Type      =LISTVIEW_KIND;
  gd->Tags      =TypeTags;

  /* Comm-String-Gadget */
  gd=&GadDat[GD_COMM_STR];
  gd->LeftEdge=left+labw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_COMM_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =CommTags;

  /* Comm-Sel-Gadget */
  gd=&GadDat[GD_COMM_SEL];
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_COMM_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =CommSelTags;

  /* FGPen-Cycle-Gadget */
  gd=&GadDat[GD_FGPEN_CYC];
  gd->LeftEdge=left+labw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FGPEN_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =FGPenTags;

  /* BGPen-Cycle-Gadget */
  gd=&GadDat[GD_BGPEN_CYC];
  gd->LeftEdge=left+labw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_BGPEN_CYC;
  gd->Type    =CYCLE_KIND;
  gd->Tags    =BGPenTags;

  /* ULine-CheckBox-Gadget */
  gd=&GadDat[GD_ULINE_CKB];
  gd->LeftEdge=left+labw;
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_ULINE_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =ULineTags;

  /* Italic-CheckBox-Gadget */
  gd=&GadDat[GD_ITALIC_CKB];
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_ITALIC_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =ItalicTags;

  /* Bold-CheckBox-Gadget */
  gd=&GadDat[GD_BOLD_CKB];
  gd->Width   =CHECKBOX_WIDTH;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_BOLD_CKB;
  gd->Type    =CHECKBOX_KIND;
  gd->Tags    =BoldTags;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_TYPE_LWR] =FindVanillaKey(GadDat[GD_TYPE_LST].GadgetText);
  VanKeys[KEY_TYPE_UPR] =toupper(VanKeys[KEY_TYPE_LWR]);
  VanKeys[KEY_COMM_LWR] =FindVanillaKey(GadDat[GD_COMM_STR].GadgetText);
  VanKeys[KEY_COMM_UPR] =toupper(VanKeys[KEY_COMM_LWR]);
  VanKeys[KEY_FGPEN_LWR]=FindVanillaKey(GadDat[GD_FGPEN_CYC].GadgetText);
  VanKeys[KEY_FGPEN_UPR]=toupper(VanKeys[KEY_FGPEN_LWR]);
  VanKeys[KEY_BGPEN_LWR]=FindVanillaKey(GadDat[GD_BGPEN_CYC].GadgetText);
  VanKeys[KEY_BGPEN_UPR]=toupper(VanKeys[KEY_BGPEN_LWR]);
  VanKeys[KEY_ULINE]    =FindVanillaKey(GadDat[GD_ULINE_CKB].GadgetText);
  VanKeys[KEY_ITALIC]   =FindVanillaKey(GadDat[GD_ITALIC_CKB].GadgetText);
  VanKeys[KEY_BOLD]     =FindVanillaKey(GadDat[GD_BOLD_CKB].GadgetText);
  VanKeys[KEY_NULL]     ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");

  NewList(&Comms);

  for (i=COMT_LINK;i<=COMT_STYLE;i++)
  {
    if (comstr=(struct Node *)
        AllocMem(sizeof(struct Node),MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
    {
      comstr->ln_Name=CommStrs[i];
      AddTail(&Comms,comstr);
    }
    else
    {
      rc=FALSE;
      break;
    }
  }

  if (!rc)
  {
    DEBUG_PRINTF("  error! freeing everything\n");
    UnInitCommWin();
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(rc);
}

/* ============================================================================== CreateCommWinGadList
** kreiert die Gadgets des CommWin größensensitiv
*/
struct Gadget *CreateCommWinGadList(void)
{
  struct GadgetData *gd;
  struct Gadget     *gadlist;
  UWORD gadw=CommWin->Width-GadDat[GD_COMM_STR].LeftEdge-CommWin->BorderRight-INTERWIDTH;
  UWORD top =Screen.ps_WBorTop+INTERHEIGHT;
  UWORD yadd=Screen.ps_ScrFont->tf_YSize+2*INTERHEIGHT;
  UWORD italicw=TextLength(&Screen.ps_DummyRPort,GadDat[GD_ITALIC_CKB].GadgetText,strlen(GadDat[GD_ITALIC_CKB].GadgetText));
  UWORD boldw =TextLength(&Screen.ps_DummyRPort,GadDat[GD_BOLD_CKB].GadgetText,strlen(GadDat[GD_BOLD_CKB].GadgetText));

  /* Type-ListView-Gadget */
  gd=&GadDat[GD_TYPE_LST];
  gd->Width   =gadw+GadDat[GD_COMM_STR].LeftEdge-gd->LeftEdge;
  gd->Height  =CommWin->Height-CommWin->BorderTop-CommWin->BorderBottom-4*yadd-2*INTERHEIGHT;

  top+=gd->Height+INTERHEIGHT;

  /* Comm-String-Gadget */
  gd=&GadDat[GD_COMM_STR];
  gd->TopEdge =top;
  gd->Width   =gadw-GadDat[GD_COMM_SEL].Width;

  /* Comm-Sel-Gadget */
  gd=&GadDat[GD_COMM_SEL];
  gd->LeftEdge=GadDat[GD_COMM_STR].LeftEdge+GadDat[GD_COMM_STR].Width;
  gd->TopEdge =top;

  top+=yadd;

  /* FGPen-Cycle-Gadget */
  gd=&GadDat[GD_FGPEN_CYC];
  gd->TopEdge =top;
  gd->Width   =gadw;

  top+=yadd;

  /* BGPen-Cycle-Gadget */
  gd=&GadDat[GD_BGPEN_CYC];
  gd->TopEdge =top;
  gd->Width   =gadw;

  top+=yadd;

  /* ULine-CheckBox-Gadget */
  gd=&GadDat[GD_ULINE_CKB];
  gd->TopEdge =top;

  /* Italic-CheckBox-Gadget */
  gd=&GadDat[GD_ITALIC_CKB];
  gd->LeftEdge=GadDat[GD_ULINE_CKB].LeftEdge+((italicw+INTERWIDTH+CHECKBOX_WIDTH)*gadw)/(3*CHECKBOX_WIDTH+boldw+2*INTERWIDTH+italicw);
  gd->TopEdge =top;

  /* Bold-CheckBox-Gadget */
  gd=&GadDat[GD_BOLD_CKB];
  gd->LeftEdge=GadDat[GD_ULINE_CKB].LeftEdge+gadw-CHECKBOX_WIDTH;
  gd->TopEdge =top;

  TypeTags[0].ti_Data   =~0;
  CommTags[1].ti_Data   =TRUE;
  CommSelTags[0].ti_Data=TRUE;
  FGPenTags[1].ti_Data  =TRUE;
  BGPenTags[1].ti_Data  =TRUE;
  BoldTags[1].ti_Data   =TRUE;
  ItalicTags[1].ti_Data =TRUE;
  ULineTags[1].ti_Data  =TRUE;

  if (AGuide.gt_CurDoc->doc_CurComm && AGuide.gt_CurDoc->doc_CurComm->com_Type<=COMT_SYSTEM)
  {
    TypeTags[0].ti_Data   =
    TypeTags[1].ti_Data   =(ULONG)AGuide.gt_CurDoc->doc_CurComm->com_Type;
    CommTags[0].ti_Data   =(ULONG)AGuide.gt_CurDoc->doc_CurComm->com_StrData;
    CommTags[1].ti_Data   =FALSE;
    CommSelTags[0].ti_Data=FALSE;
  }

  if (AGuide.gt_CurDoc->doc_CurComm && AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_STYLE)
  {
    TypeTags[0].ti_Data   =
    TypeTags[1].ti_Data   =(ULONG)AGuide.gt_CurDoc->doc_CurComm->com_Type;
    CommTags[0].ti_Data   =NULL;
    FGPenTags[0].ti_Data  =AGuide.gt_CurDoc->doc_CurComm->com_FGPen;
    FGPenTags[1].ti_Data  =FALSE;
    BGPenTags[0].ti_Data  =AGuide.gt_CurDoc->doc_CurComm->com_BGPen;
    BGPenTags[1].ti_Data  =FALSE;
    BoldTags[0].ti_Data   =AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_BOLD;
    BoldTags[1].ti_Data   =FALSE;
    ItalicTags[0].ti_Data =AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_ITALIC;
    ItalicTags[1].ti_Data =FALSE;
    ULineTags[0].ti_Data  =AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_UNDERLINED;
    ULineTags[1].ti_Data  =FALSE;
  }

  gadlist=CreateGadgetList(GadDat,GDNUM);

  return(gadlist);
}

/* ====================================================================================== CloseCommWin
** schließt das Comm-Fenster
*/
void CloseCommWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseCommWin-function --\n");

  if (CommWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(CommWin);
    DEBUG_PRINTF("  MenuStrip at CommWin cleared\n");

    /* Window schließen */
    CloseWindow(CommWin);
    CommWin=NULL;
    CommBit=0;
    DEBUG_PRINTF("  CommWin closed\n");

    FreeGadgets(GadList);
    GadList=NULL;
    GadListRemoved=TRUE;
    DEBUG_PRINTF("  GadList freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= OpenCommWin
** öffnet das Commect-Fenster
*/
BOOL OpenCommWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenCommWin-function --\n");

  /* wenn noch nicht geöffnet (könnte mehrmals aufgerufen werden) */
  if (!CommWin)
  {
    /* Window öffnen */
    if (CommWin=
        OpenWindowTags(NULL,
                       WA_Left,WinPosP.CommWLeft,
                       WA_Top,WinPosP.CommWTop,
                       WA_Width,WinPosP.CommWWidth,
                       WA_Height,WinPosP.CommWHeight,
                       WA_MinWidth,MinWidth,
                       WA_MinHeight,MinHeight,
                       WA_MaxWidth,~0,
                       WA_MaxHeight,~0,
                       WA_Title,"Command Editor",
                       WA_ScreenTitle,Screen.ps_Title,
                       WA_IDCMP,BUTTONIDCMP|STRINGIDCMP|LISTVIEWIDCMP|CYCLEIDCMP|\
                                CHECKBOXIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|\
                                IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY|IDCMP_RAWKEY|\
                                IDCMP_NEWSIZE|IDCMP_SIZEVERIFY,
                       WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                WFLG_SIZEGADGET|WFLG_SIZEBBOTTOM|\
                                WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                       WA_AutoAdjust,TRUE,
                       WA_Zoom,WZoom,
                       WA_PubScreen,Screen.ps_Screen,
                       TAG_DONE))
    {
      DEBUG_PRINTF("  CommWin opened\n");

      if (GadList=CreateCommWinGadList())
      {
        DEBUG_PRINTF("  GadList created\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(CommWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at CommWin\n");

        AddGList(CommWin,GadList,~0,~0,NULL);
        GadListRemoved=FALSE;
        DEBUG_PRINTF("  GadList added to CommWin\n");

        /* Window neu aufbauen */
        RefreshGList(GadList,CommWin,NULL,~0);
        GT_RefreshWindow(CommWin,NULL);
        DEBUG_PRINTF("  GadList refreshed\n");

        OldSecs=0;
        OldMics=0;

        CommBit=1UL<<CommWin->UserPort->mp_SigBit;
        WinPosP.CommWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on creating gadgets for\n"
                           "Command Editor Window",
                           "Ok");
    }
    else
      EasyRequestAllWins("Error on opening Command Editor Window",
                         "Ok");

    DEBUG_PRINTF("  Error\n");
    CloseCommWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(CommWin);
    WindowToFront(CommWin);
  }

  DEBUG_PRINTF("  CommWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* ===================================================================================== GetCommWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetCommWinPos(void)
{
  if (CommWin)
  {
    WinPosP.CommWLeft  =CommWin->LeftEdge;
    WinPosP.CommWTop   =CommWin->TopEdge;
    WinPosP.CommWWidth =CommWin->Width;
    WinPosP.CommWHeight=CommWin->Height;
  }
}

/* ===================================================================================== UpdateCommWin
** setzt die Gadgets im CommWin auf die Werte im AGuide.gt_CurDoc->doc_CurComm
*/
void UpdateCommWin(void)
{
  /* wird aus anderen Modulen aufgerufen */
  if (CommWin)
  {
    static LONG  type =~0;
    static UBYTE style=0,fgpen=0,bgpen=0;
    static struct Command *com=NULL;

    if (AGuide.gt_CurDoc->doc_CurComm)
    {
      /*  bei entsprechenden Änderungen EditWin refreshen */
      if (com==AGuide.gt_CurDoc->doc_CurComm &&
          ((AGuide.gt_CurDoc->doc_CurComm->com_Type<COMT_STYLE && type==COMT_STYLE) ||
           (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_STYLE && type<COMT_STYLE) ||
            style!=AGuide.gt_CurDoc->doc_CurComm->com_Style ||
            fgpen!=AGuide.gt_CurDoc->doc_CurComm->com_FGPen ||
            bgpen!=AGuide.gt_CurDoc->doc_CurComm->com_BGPen))
        UpdateEditWin();

      if (AGuide.gt_CurDoc->doc_CurComm->com_Type<=COMT_SYSTEM)
      {
        if (type!=AGuide.gt_CurDoc->doc_CurComm->com_Type &&
            (type>=COMT_CLOSE || type<COMT_LINK))
        {
          DisableGad(GD_FGPEN_CYC);
          DisableGad(GD_BGPEN_CYC);
          DisableGad(GD_BOLD_CKB);
          DisableGad(GD_ITALIC_CKB);
          DisableGad(GD_ULINE_CKB);
          EnableGad(GD_COMM_STR);
          EnableGad(GD_COMM_SEL);
        }

        type=AGuide.gt_CurDoc->doc_CurComm->com_Type;
        SetCommStrGad(AGuide.gt_CurDoc->doc_CurComm->com_StrData);
      }

      if (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_STYLE)
      {
        if (type!=AGuide.gt_CurDoc->doc_CurComm->com_Type)
        {
          EnableGad(GD_FGPEN_CYC);
          EnableGad(GD_BGPEN_CYC);
          EnableGad(GD_BOLD_CKB);
          EnableGad(GD_ITALIC_CKB);
          EnableGad(GD_ULINE_CKB);
          DisableGad(GD_COMM_STR);
          DisableGad(GD_COMM_SEL);
        }

        type=AGuide.gt_CurDoc->doc_CurComm->com_Type;
        SetCycleGad(GD_FGPEN_CYC,AGuide.gt_CurDoc->doc_CurComm->com_FGPen);
        SetCycleGad(GD_BGPEN_CYC,AGuide.gt_CurDoc->doc_CurComm->com_BGPen);
        SetCheckBoxGad(GD_BOLD_CKB,AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_BOLD);
        SetCheckBoxGad(GD_ITALIC_CKB,AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_ITALIC);
        SetCheckBoxGad(GD_ULINE_CKB,AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_UNDERLINED);
      }

      if (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_CLOSE ||
          AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_QUIT)
      {
        if (type!=AGuide.gt_CurDoc->doc_CurComm->com_Type &&
            type!=COMT_CLOSE && type!=COMT_QUIT)
        {
          DisableGad(GD_FGPEN_CYC);
          DisableGad(GD_BGPEN_CYC);
          DisableGad(GD_BOLD_CKB);
          DisableGad(GD_ITALIC_CKB);
          DisableGad(GD_ULINE_CKB);
          DisableGad(GD_COMM_STR);
          DisableGad(GD_COMM_SEL);
        }

        type=AGuide.gt_CurDoc->doc_CurComm->com_Type;
      }
    }
    else
    {
      if (type!=~0)
      {
        DisableGad(GD_FGPEN_CYC);
        DisableGad(GD_BGPEN_CYC);
        DisableGad(GD_BOLD_CKB);
        DisableGad(GD_ITALIC_CKB);
        DisableGad(GD_ULINE_CKB);
        DisableGad(GD_COMM_STR);
        DisableGad(GD_COMM_SEL);
      }

      type=~0;
    }

    com=AGuide.gt_CurDoc->doc_CurComm;
    style=AGuide.gt_CurDoc->doc_CurComm->com_Style;
    fgpen=AGuide.gt_CurDoc->doc_CurComm->com_FGPen;
    bgpen=AGuide.gt_CurDoc->doc_CurComm->com_BGPen;

    GT_SetGadgetAttrs(GadDat[GD_TYPE_LST].Gadget,CommWin,NULL,
                      GTLV_Labels,&Comms,
                      GTLV_Selected,type,
                      GTLV_Top,type!=~0?type:0,
                      TAG_DONE);
  }
}

/* ===================================================================================== SetCommStrGad
** setzt ein String-Gadget im CommWin
*/
static
void SetCommStrGad(char *str)
{
  GT_SetGadgetAttrs(GadDat[GD_COMM_STR].Gadget,
                    CommWin,NULL,
                    GTST_String,str,
                    TAG_DONE);
}

/* ==================================================================================== SetCheckBoxGad
** setzt ein CheckBox-Gadget im CommWin
*/
static
void SetCheckBoxGad(UBYTE gdnum,BOOL state)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    CommWin,NULL,
                    GTCB_Checked,state,
                    TAG_DONE);
}

/* ======================================================================================= SetCycleGad
** setzt ein Cycle-Gadget im CommWin
*/
static
void SetCycleGad(UBYTE gdnum,UBYTE active)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    CommWin,NULL,
                    GTCY_Active,active,
                    TAG_DONE);
}


/* ====================================================================================== DoPathSelect
** Pfad-Auswahl per ASL-Requester und autom. Setzen des Windows
*/
static
void DoPathSelect(void)
{
  FileRD.Path     =AGuide.gt_CurDoc->doc_CurComm->com_StrData;
  FileRD.Title    ="Pfad wählen";
  FileRD.Flags1   =FRF_DOPATTERNS;
  FileRD.Flags2   =0;

  /* FileRequester öffnen */
  if (OpenFileRequester())
  {
    if (AGuide.gt_CurDoc->doc_CurComm->com_StrData) FreeVec(AGuide.gt_CurDoc->doc_CurComm->com_StrData);
    AGuide.gt_CurDoc->doc_CurComm->com_StrData=FileRD.Path;
  }
} 

/* ================================================================================== DoDocumentSelect
** Auswahl eines Documents
*/
static
void DoDocumentSelect(void)
{
  static LONG cursel2=0;

  LONG akt=OpenListReq(&AGuide.gt_Docs,
                       cursel2,
                       "Select Document");

  if (akt>=0)
  {
    cursel2=akt;
    if (AGuide.gt_CurDoc->doc_CurComm->com_StrData) FreeVec(AGuide.gt_CurDoc->doc_CurComm->com_StrData);
    AGuide.gt_CurDoc->doc_CurComm->com_StrData=mstrdup(GetDocAddr(akt)->doc_Node.ln_Name);
  }
}
  
/* ========================================================================================= EnableGad
** schaltet ein Gadget ein
*/
static
void EnableGad(UBYTE gdnum)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    CommWin,NULL,
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
                    CommWin,NULL,
                    GA_Disabled,TRUE,
                    TAG_DONE);
}

/* ================================================================================ HandleCommWinIDCMP
** IDCMP-Message auswerten
*/
void HandleCommWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code,qual;
  APTR  iaddr;
  ULONG secs,mics;

  DEBUG_PRINTF("\n  -- Invoking HandleCommWinIDCMP-function --\n");

  /* Message auslesen */
  while (CommWin && (imsg=GT_GetIMsg(CommWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from CommWin->UserPort\n");

    class=imsg->Class;
    code =imsg->Code;
    qual =imsg->Qualifier;
    iaddr=imsg->IAddress;
    secs =imsg->Seconds;
    mics =imsg->Micros;

    switch(class)
    {
      case IDCMP_SIZEVERIFY:
        if (!GadListRemoved)
        {
          RemoveGList(CommWin,GadList,~0);
          GadListRemoved=TRUE;
          DEBUG_PRINTF("  GadList removed from CommWin\n");
        }

        DEBUG_PRINTF("  IDCMP_SIZEVERIFY processed\n");
        break;

      case IDCMP_NEWSIZE:
      {
        if (!GadListRemoved) RemoveGList(CommWin,GadList,~0);

        SetAPen(CommWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
        RectFill(CommWin->RPort,
                 CommWin->BorderLeft,CommWin->BorderTop,
                 CommWin->Width-CommWin->BorderRight-1,CommWin->Height-CommWin->BorderBottom-1);
        DEBUG_PRINTF("  CommWin cleared\n");

        FreeGadgets(GadList);
        DEBUG_PRINTF("  GadList freed\n");

        /* Gadgets kreieren */
        if (GadList=CreateCommWinGadList())
        {
          DEBUG_PRINTF("  GadList created\n");

          /* Gadgetlist anhängen */
          AddGList(CommWin,GadList,~0,~0,NULL);
          GadListRemoved=FALSE;
          DEBUG_PRINTF("  GadList added to CommWin\n");

          /* Window neu aufbauen */
          RefreshGList(GadList,CommWin,NULL,~0);
          GT_RefreshWindow(CommWin,NULL);
          DEBUG_PRINTF("  CommWin and GadList refreshed\n");
        }
        else
          BeepProgScreen();

        DEBUG_PRINTF("  IDCMP_NEWSIZE processed\n");
        break;
      }
    }

    /* antworten */
    GT_ReplyIMsg(imsg);
    DEBUG_PRINTF("  Message replyed\n");

    /* Welche Art Event? */
    switch (class)
    {
      /* muß Window neu gezeichnet werden ? */
      case IDCMP_REFRESHWINDOW:
        GT_BeginRefresh(CommWin);
        GT_EndRefresh(CommWin,TRUE);
        DEBUG_PRINTF("  CommWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetCommWinPos();
        CloseCommWin();
        WinPosP.CommWin=FALSE;
        SetProgMenusStates();
        DEBUG_PRINTF("  CommWin closed\n");

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

        /* Liste vom ListView abhängen */
        GT_SetGadgetAttrs(GadDat[GD_TYPE_LST].Gadget,CommWin,NULL,
                          GTLV_Labels,~0,
                          TAG_DONE);

        if (AGuide.gt_CurDoc->doc_CurComm)
        {
          /* welches Gadget */
          switch (gad->GadgetID)
          {
            case GD_COMM_STR:
              DoStringCopy(&AGuide.gt_CurDoc->doc_CurComm->com_StrData,GadDat[GD_COMM_STR].Gadget);

              DEBUG_PRINTF("  GD_COMM_STR processed\n");
              break;

            case GD_COMM_SEL:
              if (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_LINK ||
                  AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_ALINK)
                DoDocumentSelect();

              if (AGuide.gt_CurDoc->doc_CurComm->com_Type>=COMT_RX &&
                  AGuide.gt_CurDoc->doc_CurComm->com_Type<=COMT_SYSTEM)
                DoPathSelect();

              DEBUG_PRINTF("  GD_COMM_SEL processed\n");
              break;

            case GD_FGPEN_CYC:
              AGuide.gt_CurDoc->doc_CurComm->com_FGPen=code;

              DEBUG_PRINTF("  GD_FGPEN_CYC processed\n");
              break;

            case GD_BGPEN_CYC:
              AGuide.gt_CurDoc->doc_CurComm->com_BGPen=code;

              DEBUG_PRINTF("  GD_BGPEN_CYC processed\n");
              break;

            case GD_BOLD_CKB:
              if (gad->Flags&GFLG_SELECTED)
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_BOLD;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_BOLD;

              DEBUG_PRINTF("  GD_BOLD_CKB processed\n");
              break;

            case GD_ITALIC_CKB:
              if (gad->Flags&GFLG_SELECTED)
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_ITALIC;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_ITALIC;

              DEBUG_PRINTF("  GD_BOLD_CKB processed\n");
              break;

            case GD_ULINE_CKB:
              if (gad->Flags&GFLG_SELECTED)
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_UNDERLINED;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_UNDERLINED;

              DEBUG_PRINTF("  GD_BOLD_CKB processed\n");
              break;

            case GD_TYPE_LST:
              if (DoubleClick(OldSecs,OldMics,secs,mics) && AGuide.gt_CurDoc->doc_CurComm->com_Type==code)
              {
                if (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_LINK ||
                    AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_ALINK)
                  DoDocumentSelect();

                if (AGuide.gt_CurDoc->doc_CurComm->com_Type>=COMT_RX &&
                    AGuide.gt_CurDoc->doc_CurComm->com_Type<=COMT_SYSTEM)
                  DoPathSelect();
              }

              OldSecs=secs;
              OldMics=mics;

              AGuide.gt_CurDoc->doc_CurComm->com_Type=code;

              DEBUG_PRINTF("  GD_TYPE_LST processed\n");
              break;
          }
        }

        UpdateCommWin();

        DEBUG_PRINTF("  Gadgets processed\n");
        break;
      }

      /* RawKey? */
      case IDCMP_RAWKEY:
      {
        /* Liste vom ListView abhängen */
        GT_SetGadgetAttrs(GadDat[GD_TYPE_LST].Gadget,CommWin,NULL,
                          GTLV_Labels,~0,
                          TAG_DONE);

        if (AGuide.gt_CurDoc->doc_CurComm)
        {
          if (qual&(IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
          {
            switch (code)
            {
              case  CURSORDOWN:
                AGuide.gt_CurDoc->doc_CurComm->com_Type=COMT_STYLE;
                DEBUG_PRINTF("  CURSORDOWN processed\n");
                break;

              case CURSORUP:
                AGuide.gt_CurDoc->doc_CurComm->com_Type=COMT_LINK;

                DEBUG_PRINTF("  CURSORUP processed\n");
                break;
            }
          }
          else
          {
            switch (code)
            {
              case CURSORDOWN:
                if (AGuide.gt_CurDoc->doc_CurComm->com_Type<COMT_STYLE)
                  AGuide.gt_CurDoc->doc_CurComm->com_Type++;

                DEBUG_PRINTF("  CURSORDOWN processed\n");
                break;

              case CURSORUP:
                if (AGuide.gt_CurDoc->doc_CurComm->com_Type>COMT_LINK)
                  AGuide.gt_CurDoc->doc_CurComm->com_Type--;

                DEBUG_PRINTF("  CURSORUP processed\n");
                break;
            }
          }
        }

        UpdateCommWin();

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
      }

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
      {
        /* Liste vom ListView abhängen */
        GT_SetGadgetAttrs(GadDat[GD_TYPE_LST].Gadget,CommWin,NULL,
                          GTLV_Labels,~0,
                          TAG_DONE);

        if (AGuide.gt_CurDoc->doc_CurComm)
        {
          /* welches Gadget */
          switch (MatchVanillaKey(code,&VanKeys[0]))
          {
            case KEY_COMM_LWR:
              ActivateGadget(GadDat[GD_COMM_STR].Gadget,CommWin,NULL);
              DEBUG_PRINTF("  KEY_COMM_LWR processed\n");
              break;

            case KEY_COMM_UPR:
              if (AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_LINK ||
                  AGuide.gt_CurDoc->doc_CurComm->com_Type==COMT_ALINK)
                DoDocumentSelect();

              if (AGuide.gt_CurDoc->doc_CurComm->com_Type>=COMT_RX &&
                  AGuide.gt_CurDoc->doc_CurComm->com_Type<=COMT_SYSTEM)
                DoPathSelect();

              DEBUG_PRINTF("  KEY_COMM_UPR processed\n");
              break;

            case KEY_FGPEN_LWR:
              if (AGuide.gt_CurDoc->doc_CurComm->com_FGPen<COL_HIGHL)
                AGuide.gt_CurDoc->doc_CurComm->com_FGPen++;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_FGPen=COL_TEXT;

              DEBUG_PRINTF("  KEY_FGPEN_LWR processed\n");
              break;

            case KEY_FGPEN_UPR:
              if (AGuide.gt_CurDoc->doc_CurComm->com_FGPen>COL_TEXT)
                AGuide.gt_CurDoc->doc_CurComm->com_FGPen--;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_FGPen=COL_HIGHL;

              DEBUG_PRINTF("  KEY_FGPEN_UPR processed\n");
              break;

            case KEY_BGPEN_LWR:
              if (AGuide.gt_CurDoc->doc_CurComm->com_BGPen<COL_HIGHL)
                AGuide.gt_CurDoc->doc_CurComm->com_BGPen++;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_BGPen=COL_TEXT;

              DEBUG_PRINTF("  KEY_BGPEN_LWR processed\n");
              break;

            case KEY_BGPEN_UPR:
              if (AGuide.gt_CurDoc->doc_CurComm->com_BGPen>COL_TEXT)
                AGuide.gt_CurDoc->doc_CurComm->com_BGPen--;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_BGPen=COL_HIGHL;

              DEBUG_PRINTF("  KEY_BGPEN_UPR processed\n");
              break;

            case KEY_BOLD:
              if (AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_BOLD)
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_BOLD;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_BOLD;

              DEBUG_PRINTF("  KEY_BOLD processed\n");
              break;

            case KEY_ITALIC:
              if (AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_ITALIC)
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_ITALIC;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_ITALIC;

              DEBUG_PRINTF("  KEY_ITALIC processed\n");
              break;

            case KEY_ULINE:
              if (AGuide.gt_CurDoc->doc_CurComm->com_Style&FSF_UNDERLINED)
                AGuide.gt_CurDoc->doc_CurComm->com_Style&=~FSF_UNDERLINED;
              else
                AGuide.gt_CurDoc->doc_CurComm->com_Style|=FSF_UNDERLINED;

              DEBUG_PRINTF("  KEY_ULINE processed\n");
              break;
          }
        }

        UpdateCommWin();

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
