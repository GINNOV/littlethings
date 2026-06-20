/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     DocsWin.c
** FUNKTION:  DocsWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

       struct Window    *DocsWin=NULL;
       ULONG             DocsBit=0;

static UWORD             Width,MinHeight;
static WORD              WZoom[4];
static ULONG             OldMics,OldSecs;

static struct TagItem      NodeNameTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      WinTitleTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      NextNodeTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      PrevNodeTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      TOCNodeTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem      FileNameTags[]={GTST_String,NULL,
                                           GTST_MaxChars,STRMAXCHARS,
                                           TAG_DONE};

static struct TagItem      DocsTags[]={GTLV_Labels,NULL,
                                       GTLV_Selected,0,
                                       GTLV_Top,0,
                                       GTLV_ShowSelected,NULL,
                                       TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_NEW_BUT         0
#define GD_DEL_BUT         1
#define GD_COPY_BUT        2
#define GD_CLEAR_BUT       3
#define GD_FIRST_BUT       4
#define GD_LAST_BUT        5
#define GD_UP_BUT          6
#define GD_DOWN_BUT        7
#define GD_BYMODE_BUT      8
#define GD_NODENAME_STR    9
#define GD_WINTITLE_STR   10
#define GD_NEXTNODE_STR   11
#define GD_NEXTNODE_SEL   12
#define GD_PREVNODE_STR   13
#define GD_PREVNODE_SEL   14
#define GD_TOCNODE_STR    15
#define GD_TOCNODE_SEL    16
#define GD_FILENAME_STR   17
#define GD_FILENAME_SEL   18
#define GD_DOCS_LST       19
#define GD_EDITCOMMS_BUT  20
#define GDNUM             21

static struct GadgetData  GadDat[GDNUM];
static struct Gadget     *GadList;
static struct Gadget     *SizeGadList;
static BOOL               SizeGadListRemoved=TRUE;

/* SEPERATORS */
#define SEP1               0
#define SEP2               1
#define SEP3               2
#define SEP4               3
#define SEPNUM             4

static struct SepData     SepDat[SEPNUM];

/* VANILLAKEYS */
#define KEY_NEW            0
#define KEY_DEL            1
#define KEY_COPY           2
#define KEY_CLEAR          3
#define KEY_FIRST          4
#define KEY_LAST           5
#define KEY_UP             6
#define KEY_DOWN           7
#define KEY_BYMODE         8
#define KEY_NODENAME       9
#define KEY_WINTITLE      10
#define KEY_NEXTNODE_LWR  11
#define KEY_NEXTNODE_UPR  12
#define KEY_PREVNODE_LWR  13
#define KEY_PREVNODE_UPR  14
#define KEY_TOCNODE_LWR   15
#define KEY_TOCNODE_UPR   16
#define KEY_FILENAME_LWR  17
#define KEY_FILENAME_UPR  18
#define KEY_EDITCOMMS     19
#define KEY_NULL          20
#define KEYNUM            21

static char               VanKeys[KEYNUM];

static void DoPathSelect(UBYTE,char **);
static void DoDocumentSelect(UBYTE,char **);
static void ActGad(UBYTE);
static void SetStrGad(UBYTE,char *);

/* ======================================================================================= InitDocsWin
** fordert alle wichtigen Resourcen für das DocsWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitDocsWin(void)
{
  struct GadgetData *gd;
  struct SepData    *sd;
  ULONG i;
  UWORD tmp,selw,labw,butw,comedw,strw,selstrw;
  UWORD borleft,left;
  UWORD top,gadh,yadd;
  char  *sel="Sel";

  DEBUG_PRINTF("\n  -- Invoking InitDocsWin-Function --\n");

  /* Gadgetlabels initialisieren */
  GadDat[GD_NEW_BUT].GadgetText        ="_New";
  GadDat[GD_DEL_BUT].GadgetText        ="_Delete";
  GadDat[GD_CLEAR_BUT].GadgetText      ="Clea_r";
  GadDat[GD_COPY_BUT].GadgetText       ="_Copy";
  GadDat[GD_UP_BUT].GadgetText         ="_Up";
  GadDat[GD_DOWN_BUT].GadgetText       ="Do_wn";
  GadDat[GD_FIRST_BUT].GadgetText      ="First";
  GadDat[GD_LAST_BUT].GadgetText       ="Last";
  GadDat[GD_BYMODE_BUT].GadgetText     ="_Set by Modes";
  GadDat[GD_NODENAME_STR].GadgetText   ="N_odeName";
  GadDat[GD_WINTITLE_STR].GadgetText   ="W_inTitle";
  GadDat[GD_NEXTNODE_STR].GadgetText   ="Ne_xtNode";
  GadDat[GD_PREVNODE_STR].GadgetText   ="_PrevNode";
  GadDat[GD_TOCNODE_STR].GadgetText    ="_TOCNode";
  GadDat[GD_FILENAME_STR].GadgetText   ="_Filename";

  GadDat[GD_NEXTNODE_SEL].GadgetText   =sel;
  GadDat[GD_PREVNODE_SEL].GadgetText   =sel;
  GadDat[GD_TOCNODE_SEL].GadgetText    =sel;
  GadDat[GD_FILENAME_SEL].GadgetText   =sel;

  GadDat[GD_EDITCOMMS_BUT].GadgetText  ="_Edit Commands...";
  GadDat[GD_DOCS_LST].GadgetText       =NULL;

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Breite des Select-Buttons ermitteln */
  selw=TextLength(&Screen.ps_DummyRPort,
                  sel,strlen(sel))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* breitestes Gadgetlabel ermitteln */
  labw=0;
  for (i=GD_NODENAME_STR;i<=GD_TOCNODE_STR;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (labw<tmp) labw=tmp;
  }
  labw+=INTERWIDTH;
  DEBUG_PRINTF("  labw calculated\n");

  /* breitestes Buttonlabel ermitteln */
  butw=0;
  for (i=GD_NEW_BUT;i<=GD_LAST_BUT;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (butw<tmp) butw=tmp;
  }
  butw+=INTERWIDTH;
  DEBUG_PRINTF("  butw calculated\n");

  /* Breite des Edit-Commands-Buttons ermitteln */
  comedw=TextLength(&Screen.ps_DummyRPort,
                    GadDat[GD_EDITCOMMS_BUT].GadgetText,
                    strlen(GadDat[GD_EDITCOMMS_BUT].GadgetText));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 GadDat[GD_BYMODE_BUT].GadgetText,
                 strlen(GadDat[GD_BYMODE_BUT].GadgetText));

  if (tmp>comedw) comedw=tmp;
  comedw+=INTERWIDTH;
  DEBUG_PRINTF("  comedw calculated\n");

  /* Größen der Gadgets berechnen */
  strw=Screen.ps_ScrFont->tf_XSize*20;

  if (4*butw+3*INTERWIDTH>labw+2*strw+INTERWIDTH)
    strw=(4*butw+4*INTERWIDTH-labw)/2;
  else
    butw=(labw+2*strw-2*INTERWIDTH)/4;

  if (strw+labw>comedw)
    comedw=strw+labw;
  else
  {
    strw=comedw-labw;
    butw=(comedw+strw-2*INTERWIDTH)/4;
  }

  selstrw=strw-selw;
  borleft=Screen.ps_Screen->WBorLeft+INTERWIDTH;
  left   =0;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (WinPosP.DocsWTop==~0) WinPosP.DocsWTop=Screen.ps_Screen->BarHeight+1;
  Width    =4*butw+5*INTERWIDTH;
  MinHeight=Screen.ps_WBorTop+INTERHEIGHT+10*yadd+4*(SEPHEIGHT+INTERHEIGHT)+Screen.ps_WBorBottom;

  /* alternative Windowgröße */
  WZoom[0]=WinPosP.DocsWLeft;
  WZoom[1]=WinPosP.DocsWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_WBorTop;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_WBorTop+INTERHEIGHT;

  /* New-Button-Gadget */
  gd=&GadDat[GD_NEW_BUT];
  gd->LeftEdge=borleft;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_NEW_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Del-Button-Gadget */
  gd=&GadDat[GD_DEL_BUT];
  gd->LeftEdge=borleft+butw+INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_DEL_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Copy-Button-Gadget */
  gd=&GadDat[GD_COPY_BUT];
  gd->LeftEdge=borleft+2*butw+2*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_COPY_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Clear-Button-Gadget */
  gd=&GadDat[GD_CLEAR_BUT];
  gd->LeftEdge=borleft+3*butw+3*INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_CLEAR_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* First-Button-Gadget */
  gd=&GadDat[GD_FIRST_BUT];
  gd->LeftEdge=GadDat[GD_NEW_BUT].LeftEdge;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_FIRST_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Last-Button-Gadget */
  gd=&GadDat[GD_LAST_BUT];
  gd->LeftEdge=GadDat[GD_DEL_BUT].LeftEdge;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_LAST_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Up-Button-Gadget */
  gd=&GadDat[GD_UP_BUT];
  gd->LeftEdge=GadDat[GD_COPY_BUT].LeftEdge;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_UP_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Down-Button-Gadget */
  gd=&GadDat[GD_DOWN_BUT];
  gd->LeftEdge=GadDat[GD_CLEAR_BUT].LeftEdge;
  gd->TopEdge =top;
  gd->Width   =butw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_DOWN_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Separator 1 berechnen */
  sd=&SepDat[SEP1];
  sd->LeftEdge=borleft;
  sd->TopEdge =top;
  sd->Width   =4*butw+3*INTERWIDTH;

  top=sd->TopEdge+SEPHEIGHT+INTERHEIGHT;

  gd=&GadDat[GD_DOCS_LST];
  gd->LeftEdge=borleft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Flags   =0;
  gd->GadgetID=GD_DOCS_LST;
  gd->Type    =LISTVIEW_KIND;
  gd->Tags    =DocsTags;

  borleft+=strw+INTERWIDTH;
  left=borleft+labw;

  /* ByMode-Button-Gadget */
  gd=&GadDat[GD_BYMODE_BUT];
  gd->LeftEdge=borleft;
  gd->TopEdge =top;
  gd->Width   =comedw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_BYMODE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Separator 2 berechnen */
  sd=&SepDat[SEP2];
  sd->LeftEdge=borleft;
  sd->TopEdge =top;
  sd->Width   =labw+strw;

  top=sd->TopEdge+SEPHEIGHT+INTERHEIGHT;

  /* NodeName-String-Gadget */
  gd=&GadDat[GD_NODENAME_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_NODENAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =NodeNameTags;

  top+=yadd;

  /* WinTitle-String-Gadget */
  gd=&GadDat[GD_WINTITLE_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_WINTITLE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =WinTitleTags;

  top+=yadd;

  /* NextNode-String-Gadget */
  gd=&GadDat[GD_NEXTNODE_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->GadgetID=GD_NEXTNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =NextNodeTags;

  /* NextNode-Sel-Gadget */
  gd=&GadDat[GD_NEXTNODE_SEL];
  gd->LeftEdge=left+GadDat[GD_NEXTNODE_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_NEXTNODE_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* PrevNode-String-Gadget */
  gd=&GadDat[GD_PREVNODE_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_PREVNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =PrevNodeTags;

  /* PrevNode-Sel-Gadget */
  gd=&GadDat[GD_PREVNODE_SEL];
  gd->LeftEdge=left+GadDat[GD_PREVNODE_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_PREVNODE_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* TOCNode-String-Gadget */
  gd=&GadDat[GD_TOCNODE_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_TOCNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =TOCNodeTags;

  /* TOCNode-Sel-Gadget */
  gd=&GadDat[GD_TOCNODE_SEL];
  gd->LeftEdge=left+GadDat[GD_TOCNODE_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_TOCNODE_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;

  /* Separator 3 berechnen */
  sd=&SepDat[SEP3];
  sd->LeftEdge=borleft;
  sd->TopEdge =top;
  sd->Width   =labw+strw;

  top=sd->TopEdge+SEPHEIGHT+INTERHEIGHT;

  /* FileName-String-Gadget */
  gd=&GadDat[GD_FILENAME_STR];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FILENAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =FileNameTags;

  /* FileName-Sel-Gadget */
  gd=&GadDat[GD_FILENAME_SEL];
  gd->LeftEdge=left+GadDat[GD_FILENAME_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_FILENAME_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  top+=yadd;
             
  /* Separator 4 berechnen */
  sd=&SepDat[SEP4];
  sd->LeftEdge=borleft;
  sd->TopEdge =top;
  sd->Width   =labw+strw;

  gd=&GadDat[GD_EDITCOMMS_BUT];
  gd->LeftEdge=borleft;
  gd->Width   =comedw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_EDITCOMMS_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_NEW]         =FindVanillaKey(GadDat[GD_NEW_BUT].GadgetText);
  VanKeys[KEY_DEL]         =FindVanillaKey(GadDat[GD_DEL_BUT].GadgetText);
  VanKeys[KEY_COPY]        =FindVanillaKey(GadDat[GD_COPY_BUT].GadgetText);
  VanKeys[KEY_CLEAR]       =FindVanillaKey(GadDat[GD_CLEAR_BUT].GadgetText);
  VanKeys[KEY_FIRST]       =FindVanillaKey(GadDat[GD_FIRST_BUT].GadgetText);
  VanKeys[KEY_LAST]        =FindVanillaKey(GadDat[GD_LAST_BUT].GadgetText);
  VanKeys[KEY_UP]          =FindVanillaKey(GadDat[GD_UP_BUT].GadgetText);
  VanKeys[KEY_DOWN]        =FindVanillaKey(GadDat[GD_DOWN_BUT].GadgetText);
  VanKeys[KEY_BYMODE]      =FindVanillaKey(GadDat[GD_BYMODE_BUT].GadgetText);
  VanKeys[KEY_NODENAME]    =FindVanillaKey(GadDat[GD_NODENAME_STR].GadgetText);
  VanKeys[KEY_WINTITLE]    =FindVanillaKey(GadDat[GD_WINTITLE_STR].GadgetText);
  VanKeys[KEY_NEXTNODE_LWR]=FindVanillaKey(GadDat[GD_NEXTNODE_STR].GadgetText);
  VanKeys[KEY_NEXTNODE_UPR]=toupper(VanKeys[KEY_NEXTNODE_LWR]);
  VanKeys[KEY_PREVNODE_LWR]=FindVanillaKey(GadDat[GD_PREVNODE_STR].GadgetText);
  VanKeys[KEY_PREVNODE_UPR]=toupper(VanKeys[KEY_PREVNODE_LWR]);
  VanKeys[KEY_TOCNODE_LWR] =FindVanillaKey(GadDat[GD_TOCNODE_STR].GadgetText);
  VanKeys[KEY_TOCNODE_UPR] =toupper(VanKeys[KEY_TOCNODE_LWR]);
  VanKeys[KEY_FILENAME_LWR]=FindVanillaKey(GadDat[GD_FILENAME_STR].GadgetText);
  VanKeys[KEY_FILENAME_UPR]=toupper(VanKeys[KEY_FILENAME_LWR]);
  VanKeys[KEY_EDITCOMMS]   =FindVanillaKey(GadDat[GD_EDITCOMMS_BUT].GadgetText);
  VanKeys[KEY_NULL]='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ====================================================================================== CloseDocsWin
** schließt das Documents-Fenster
*/
void CloseDocsWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseDocsWin-function --\n");

  if (DocsWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(DocsWin);
    DEBUG_PRINTF("  MenuStrip at DocsWin cleared\n");

    if (SizeGadList)
    {
      RemoveGList(DocsWin,SizeGadList,~0);
      SizeGadListRemoved=TRUE;
      DEBUG_PRINTF("  SizeGadList removed from DocsWin\n");

      FreeGadgets(SizeGadList);
      DEBUG_PRINTF("  SizeGadList freed\n");
    }

    /* Window schließen */
    CloseWindow(DocsWin);
    DocsWin=NULL;
    DocsBit=0;
    DEBUG_PRINTF("  DocsWin closed\n");

    FreeGadgets(GadList);
    DEBUG_PRINTF("  GadList freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= OpenDocsWin
** öffnet das Documents-Fenster
*/
BOOL OpenDocsWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenDocsWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!DocsWin)
  {
    NodeNameTags[0].ti_Data=(ULONG)AGuide.gt_CurDoc->doc_Node.ln_Name;
    WinTitleTags[0].ti_Data=(ULONG)AGuide.gt_CurDoc->doc_WinTitle;
    NextNodeTags[0].ti_Data=(ULONG)AGuide.gt_CurDoc->doc_NextNode;
    PrevNodeTags[0].ti_Data=(ULONG)AGuide.gt_CurDoc->doc_PrevNode;
    TOCNodeTags[0].ti_Data =(ULONG)AGuide.gt_CurDoc->doc_TOCNode;
    FileNameTags[0].ti_Data=(ULONG)AGuide.gt_CurDoc->doc_FileName;
    DocsTags[0].ti_Data    =(ULONG)&AGuide.gt_Docs;
    DocsTags[1].ti_Data    =
    DocsTags[2].ti_Data    =(ULONG)AGuide.gt_CurSel;

    if (GadList=CreateGadgetList(GadDat,GDNUM-2))
    {
      DEBUG_PRINTF("  GadList created\n");

      if (WinPosP.DocsWHeight<MinHeight) WinPosP.DocsWHeight=MinHeight;

      /* Window öffnen */
      if (DocsWin=
          OpenWindowTags(NULL,
                         WA_Left,WinPosP.DocsWLeft,
                         WA_Top,WinPosP.DocsWTop,
                         WA_InnerWidth,Width,
                         WA_Height,WinPosP.DocsWHeight,
                         WA_MinHeight,MinHeight,
                         WA_MaxHeight,~0,
                         WA_Title,"Documents Editor",
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,LISTVIEWIDCMP|INTEGERIDCMP|STRINGIDCMP|IDCMP_MENUPICK|\
                                  IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY|\
                                  IDCMP_RAWKEY|IDCMP_SIZEVERIFY|IDCMP_NEWSIZE,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE|WFLG_SIZEBBOTTOM|
                                  WFLG_SIZEGADGET|WFLG_SIMPLE_REFRESH,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  DocsWin opened\n");

        GadDat[GD_DOCS_LST].Height=DocsWin->Height-GadDat[GD_DOCS_LST].TopEdge-INTERHEIGHT-DocsWin->BorderBottom;
        GadDat[GD_EDITCOMMS_BUT].TopEdge=DocsWin->Height-DocsWin->BorderBottom-INTERHEIGHT-GadDat[GD_EDITCOMMS_BUT].Height;

        if (SizeGadList=CreateGadgetList(&GadDat[GD_DOCS_LST],2))
        {
          /* MenuStrip ans Window anhängen */
          SetMenuStrip(DocsWin,Menus);
          DEBUG_PRINTF("  MenuStrip set at DocsWin\n");

          AddGList(DocsWin,SizeGadList,~0,~0,NULL);
          SizeGadListRemoved=FALSE;
          DEBUG_PRINTF("  SizeGadList added to DocsWin\n");

          /* Window neu aufbauen */
          DrawSeparators(DocsWin,SepDat,SEPNUM);
          RefreshGList(SizeGadList,DocsWin,NULL,~0);
          GT_RefreshWindow(DocsWin,NULL);
          DEBUG_PRINTF("  GadList refreshed\n");

          OldSecs=0;
          OldMics=0;

          /* Liste an ListView anhängen */
          DocsBit=1UL<<DocsWin->UserPort->mp_SigBit;
          WinPosP.DocsWin=TRUE;

          ProgScreenToFront();

          /* Ok zurückgeben */
          DEBUG_PRINTF("  -- returning --\n\n");
          return(TRUE);
        }
        else
          EasyRequestAllWins("Error on opening the Documents Editor Window",
                             "Ok");
      }
      else
        EasyRequestAllWins("Error on creating the size variable\n"
                           "gadgets for the Documents Editor Window",
                           "Ok");
    }
    else
      EasyRequestAllWins("Error on creating the gadgets for\n"
                         "the Documents Editor Window",
                         "Ok");

    DEBUG_PRINTF("  Error\n");
    CloseDocsWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(DocsWin);
    WindowToFront(DocsWin);
  }

  DEBUG_PRINTF("  DocsWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* ===================================================================================== UpdateDocsWin
** updatet das DocsWin
*/
void UpdateDocsWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking UpdateDocsWin-function --\n");

  if (DocsWin)
  {
    SetStrGad(GD_NODENAME_STR,AGuide.gt_CurDoc->doc_Node.ln_Name);
    SetStrGad(GD_WINTITLE_STR,AGuide.gt_CurDoc->doc_WinTitle);
    SetStrGad(GD_NEXTNODE_STR,AGuide.gt_CurDoc->doc_NextNode);
    SetStrGad(GD_PREVNODE_STR,AGuide.gt_CurDoc->doc_PrevNode);
    SetStrGad(GD_TOCNODE_STR,AGuide.gt_CurDoc->doc_TOCNode);
    SetStrGad(GD_FILENAME_STR,AGuide.gt_CurDoc->doc_FileName);
    GT_SetGadgetAttrs(GadDat[GD_DOCS_LST].Gadget,
                      DocsWin,NULL,
                      GTLV_Labels,&AGuide.gt_Docs,
                      GTLV_Selected,AGuide.gt_CurSel,
                      GTLV_Top,AGuide.gt_CurSel,
                      TAG_DONE);
    DEBUG_PRINTF("  Gadgets set\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ===================================================================================== GetDocsWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetDocsWinSize(void)
{
  if (DocsWin)
  {
    WinPosP.DocsWLeft  =DocsWin->LeftEdge;
    WinPosP.DocsWTop   =DocsWin->TopEdge;
    WinPosP.DocsWHeight=DocsWin->Height;
  }
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

/* ================================================================================== DoDocumentSelect
** Auswahl eines Documents
*/
static
void DoDocumentSelect(UBYTE gdnum,char **str)
{
  static LONG cursel2=0;

  LONG akt=OpenListReq(&AGuide.gt_Docs,
                       cursel2,
                       "Select Document");

  if (akt>=0)
  {
    cursel2=akt;
    if (*str) FreeVec(*str);
    *str=mstrdup(GetDocAddr(akt)->doc_Node.ln_Name);
    SetStrGad(gdnum,*str);
  }
}

/* ============================================================================================ ActGad
** aktiviert ein String-Gadget im DocsWin
*/
static
void ActGad(UBYTE gdnum)
{
  ActivateGadget(GadDat[gdnum].Gadget,DocsWin,NULL);
}

/* ========================================================================================= SetStrGad
** setzt ein String-Gadget im DocsWin
*/
static
void SetStrGad(UBYTE gdnum,char *str)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    DocsWin,NULL,
                    GTST_String,str,
                    TAG_DONE);
}

/* ========================================================================================== DoNewDoc
** fügt ein neues Document ein
*/
static
void DoNewDoc(void)
{
  struct Document *doc;

  if (doc=InsertDoc(AGuide.gt_CurDoc))
  {
    /* neues Doc setzen */
    AGuide.gt_CurDoc=doc;
    AGuide.gt_CurSel++;

    UpdateDocsWin();
    UpdateEditWin();
  }
  else
    EasyRequestAllWins("Error on inserting the new Document",
                       "Ok");
}

/* ======================================================================================= DoDeleteDoc
** löscht ein Document
*/
static
void DoDeleteDoc(void)
{
  if (AGuide.gt_CurDoc->doc_Node.ln_Succ->ln_Succ)
  {
    AGuide.gt_CurDoc=DeleteDoc(AGuide.gt_CurDoc);
  }
  else
  {
    if (AGuide.gt_CurDoc->doc_Node.ln_Pred->ln_Pred)
    {
      AGuide.gt_CurDoc=DeleteDoc(AGuide.gt_CurDoc);
      AGuide.gt_CurDoc=(struct Document *)AGuide.gt_CurDoc->doc_Node.ln_Pred;
      AGuide.gt_CurSel--;
    }
    else
      AGuide.gt_CurDoc=ClearDoc(AGuide.gt_CurDoc);
  }

  UpdateDocsWin();
  UpdateEditWin();
}

/* ========================================================================================= DoCopyDoc
** kopiert ein Document
*/
static
void DoCopyDoc(void)
{
  struct Document *doc;

  if (doc=CopyDoc(AGuide.gt_CurDoc))
  {
    /* kopierte Node setzen */
    AGuide.gt_CurDoc=doc;
    AGuide.gt_CurSel++;

    UpdateDocsWin();
    UpdateEditWin();
  }
  else
    EasyRequestAllWins("Error on copying the Document",
                       "Ok");
}

/* ================================================================================ HandleDocsWinIDCMP
** IDCMP-Message auswerten
*/
void HandleDocsWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  ULONG class,secs,mics;
  UWORD code,qual;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleDocsWinIDCMP-function --\n");

  /* Message auslesen */
  while (DocsWin && (imsg=GT_GetIMsg(DocsWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from DocsWin->UserPort\n");

    class=imsg->Class;
    code =imsg->Code;
    qual =imsg->Qualifier;
    iaddr=imsg->IAddress;
    secs =imsg->Seconds;
    mics =imsg->Micros;

    /* warum doppelter class-swicth? - siehe EditWin.c */
    switch(class)
    {
      case IDCMP_SIZEVERIFY:
        if (!SizeGadListRemoved)
        {
          RemoveGList(DocsWin,SizeGadList,~0);
          SizeGadListRemoved=TRUE;
          DEBUG_PRINTF("  SizeGadList removed from DocsWin\n");
        }

        DEBUG_PRINTF("  SizeVerify processed\n");
        break;

      case IDCMP_NEWSIZE:
      {
        if (!SizeGadListRemoved) RemoveGList(DocsWin,SizeGadList,~0);

        SetAPen(DocsWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
        RectFill(DocsWin->RPort,
                 GadDat[GD_DOCS_LST].Gadget->LeftEdge,
                 GadDat[GD_DOCS_LST].Gadget->TopEdge,
                 GadDat[GD_DOCS_LST].Gadget->LeftEdge+GadDat[GD_DOCS_LST].Gadget->Width-1,
                 DocsWin->Height-DocsWin->BorderBottom-1);

        RectFill(DocsWin->RPort,
                 GadDat[GD_EDITCOMMS_BUT].Gadget->LeftEdge,
                 SepDat[SEP4].TopEdge+SEPHEIGHT,
                 GadDat[GD_EDITCOMMS_BUT].Gadget->LeftEdge+GadDat[GD_EDITCOMMS_BUT].Gadget->Width-1,
                 DocsWin->Height-DocsWin->BorderBottom-1);

        DEBUG_PRINTF("  old Gadgets cleared\n");

        FreeGadgets(SizeGadList);
        DEBUG_PRINTF("  SizeGadList freed\n");

        GadDat[GD_DOCS_LST].Height=DocsWin->Height-GadDat[GD_DOCS_LST].TopEdge-INTERHEIGHT-DocsWin->BorderBottom;
        GadDat[GD_EDITCOMMS_BUT].TopEdge=DocsWin->Height-DocsWin->BorderBottom-INTERHEIGHT-GadDat[GD_EDITCOMMS_BUT].Height;

        DocsTags[0].ti_Data=(ULONG)&AGuide.gt_Docs;
        DocsTags[1].ti_Data=
        DocsTags[2].ti_Data=(ULONG)AGuide.gt_CurSel;

        /* Gadgets kreieren */
        if (SizeGadList=CreateGadgetList(&GadDat[GD_DOCS_LST],2))
        {
          DEBUG_PRINTF("  SizeGadList created\n");

          /* Gadgetlist anhängen */
          AddGList(DocsWin,SizeGadList,~0,~0,NULL);
          SizeGadListRemoved=FALSE;
          DEBUG_PRINTF("  SizeGadList added to DocsWin\n");

          /* Window neu aufbauen */
          RefreshGList(SizeGadList,DocsWin,NULL,~0);
          GT_RefreshWindow(DocsWin,NULL);
          DEBUG_PRINTF("  DocsWin and SizeGadList refreshed\n");
        }
        else
          BeepProgScreen();

        DEBUG_PRINTF("  NewSize processed\n");
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
        GT_BeginRefresh(DocsWin);
        DrawSeparators(DocsWin,SepDat,SEPNUM);
        GT_EndRefresh(DocsWin,TRUE);
        DEBUG_PRINTF("  DocsWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetDocsWinSize();
        CloseDocsWin();
        WinPosP.DocsWin=FALSE;
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
        struct Gadget *gad=(struct Gadget *)iaddr;

        /* Liste vom ListView abhängen */
        GT_SetGadgetAttrs(GadDat[GD_DOCS_LST].Gadget,
                          DocsWin,NULL,
                          GTLV_Labels,~0,
                          TAG_DONE);

        /* welches Gadget */
        switch (gad->GadgetID)
        {
          /* New */
          case GD_NEW_BUT:
            DoNewDoc();
            DEBUG_PRINTF("  GD_NEW_BUT processed\n");
            break;

          /* Delete */
          case GD_DEL_BUT:
            DoDeleteDoc();
            DEBUG_PRINTF("  GD_DEL_BUT processed\n");
            break;

          /* Clear */
          case GD_CLEAR_BUT:
            AGuide.gt_CurDoc=ClearDoc(AGuide.gt_CurDoc);
            UpdateDocsWin();
            DEBUG_PRINTF("  GD_CLEAR_BUT processed\n");
            break;

          /* Copy */
          case GD_COPY_BUT:
            DoCopyDoc();
            DEBUG_PRINTF("  GD_COPY_BUT processed\n");
            break;

          /* First */
          case GD_FIRST_BUT:
            MoveDocFirst(AGuide.gt_CurDoc);
            AGuide.gt_CurSel=0;
            DEBUG_PRINTF("  GD_FIRST_BUT processed\n");
            break;

          /* Last */
          case GD_LAST_BUT:
            MoveDocLast(AGuide.gt_CurDoc);
            AGuide.gt_CurSel=GetDocNum(AGuide.gt_CurDoc);
            DEBUG_PRINTF("  GD_LAST_BUT processed\n");
            break;

          /* Up */
          case GD_UP_BUT:
            if (MoveDocUp(AGuide.gt_CurDoc))
              AGuide.gt_CurSel--;

            DEBUG_PRINTF("  GD_UP_BUT processed\n");
            break;

          /* Down */
          case GD_DOWN_BUT:
            if (MoveDocDown(AGuide.gt_CurDoc))
              AGuide.gt_CurSel++;

            DEBUG_PRINTF("  GD_DOWN_BUT processed\n");
            break;

          /* ByMode */
          case GD_BYMODE_BUT:
            FormatDocsPrefsStrings(AGuide.gt_CurDoc);
            UpdateDocsWin();
            DEBUG_PRINTF("  GD_BYMODE_BUT processed\n");
            break;

          /* NodeName */
          case GD_NODENAME_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_Node.ln_Name,GadDat[GD_NODENAME_STR].Gadget);
            DEBUG_PRINTF("  GD_NODENAME_STR processed\n");
            break;

          /* WinTitle */
          case GD_WINTITLE_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_WinTitle,GadDat[GD_WINTITLE_STR].Gadget);
            DEBUG_PRINTF("  GD_WINTITLE_STR processed\n");
            break;

          /* NextNode */
          case GD_NEXTNODE_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_NextNode,GadDat[GD_NEXTNODE_STR].Gadget);
            DEBUG_PRINTF("  GD_NEXTNODE_STR processed\n");
            break;

          case GD_NEXTNODE_SEL:
            DoDocumentSelect(GD_NEXTNODE_STR,&AGuide.gt_CurDoc->doc_NextNode);
            DEBUG_PRINTF("  GD_NEXTNODE_SEL processed\n");
            break;

          /* PrevNode */
          case GD_PREVNODE_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_PrevNode,GadDat[GD_PREVNODE_STR].Gadget);
            DEBUG_PRINTF("  GD_PREVNODE_STR processed\n");
            break;

          case GD_PREVNODE_SEL:
            DoDocumentSelect(GD_PREVNODE_STR,&AGuide.gt_CurDoc->doc_PrevNode);
            DEBUG_PRINTF("  GD_PREVNODE_SEL processed\n");
            break;

          /* TOCNode */
          case GD_TOCNODE_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_TOCNode,GadDat[GD_TOCNODE_STR].Gadget);
            DEBUG_PRINTF("  GD_TOCNODE_STR processed\n");
            break;

          case GD_TOCNODE_SEL:
            DoDocumentSelect(GD_TOCNODE_STR,&AGuide.gt_CurDoc->doc_TOCNode);
            DEBUG_PRINTF("  GD_TOCNODE_SEL processed\n");
            break;

          /* FileName */
          case GD_FILENAME_STR:
            DoStringCopy(&AGuide.gt_CurDoc->doc_FileName,GadDat[GD_FILENAME_STR].Gadget);
            DEBUG_PRINTF("  GD_FILENAME_STR processed\n");
            break;

          case GD_FILENAME_SEL:
            DoPathSelect(GD_FILENAME_STR,&AGuide.gt_CurDoc->doc_FileName);
            DEBUG_PRINTF("  GD_FILENAME_SEL processed\n");
            break;

          /* EditComms */
          case GD_EDITCOMMS_BUT:
            OpenEditWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_EDITCOMMS_BUT processed\n");
            break;

          /* Documents */
          case GD_DOCS_LST:
            if (DoubleClick(OldSecs,OldMics,secs,mics) && code==AGuide.gt_CurSel)
              OpenEditWin();

            OldSecs=secs;
            OldMics=mics;
                        
            AGuide.gt_CurDoc=GetDocAddr(code);
            AGuide.gt_CurSel=code;

            UpdateDocsWin();
            UpdateEditWin();

            DEBUG_PRINTF("  GD_DOCS_LST processed\n");
            break;
        }

        /* Liste wieder anhängen */
        GT_SetGadgetAttrs(GadDat[GD_DOCS_LST].Gadget,
                          DocsWin,NULL,
                          GTLV_Labels,&AGuide.gt_Docs,
                          GTLV_Selected,AGuide.gt_CurSel,
                          GTLV_Top,AGuide.gt_CurSel,
                          TAG_DONE);

        DEBUG_PRINTF("  Gadgets processed\n");
        break;
      }

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
      {
        /* Liste vom ListView abhängen */
        GT_SetGadgetAttrs(GadDat[GD_DOCS_LST].Gadget,
                          DocsWin,NULL,
                          GTLV_Labels,~0,
                          TAG_DONE);

        /* welches Gadget */
        switch (MatchVanillaKey(code,&VanKeys[0]))
        {
          /* New */
          case KEY_NEW:
            DoNewDoc();
            DEBUG_PRINTF("  KEY_NEW processed\n");
            break;

          /* Delete */
          case KEY_DEL:
            DoDeleteDoc();
            DEBUG_PRINTF("  KEY_DEL processed\n");
            break;

          /* Clear */
          case KEY_CLEAR:
            AGuide.gt_CurDoc=ClearDoc(AGuide.gt_CurDoc);
            UpdateDocsWin();
            DEBUG_PRINTF("  KEY_CLEAR processed\n");
            break;

          /* Copy */
          case KEY_COPY:
            DoCopyDoc();
            DEBUG_PRINTF("  KEY_COPY processed\n");
            break;

          /* First */
          case KEY_FIRST:
            MoveDocFirst(AGuide.gt_CurDoc);
            AGuide.gt_CurSel=0;
            DEBUG_PRINTF("  KEY_FIRST processed\n");
            break;

          /* Last */
          case KEY_LAST:
            MoveDocLast(AGuide.gt_CurDoc);
            AGuide.gt_CurSel=GetDocNum(AGuide.gt_CurDoc);
            DEBUG_PRINTF("  KEY_LAST processed\n");
            break;

          /* Up */
          case KEY_UP:
            if (MoveDocUp(AGuide.gt_CurDoc))
              AGuide.gt_CurSel--;

            DEBUG_PRINTF("  KEY_UP processed\n");
            break;

          /* Down */
          case KEY_DOWN:
            if (MoveDocDown(AGuide.gt_CurDoc))
              AGuide.gt_CurSel++;

            DEBUG_PRINTF("  KEY_DOWN processed\n");
            break;

          /* ByMode */
          case KEY_BYMODE:
            FormatDocsPrefsStrings(AGuide.gt_CurDoc);
            UpdateDocsWin();
            DEBUG_PRINTF("  KEY_BYMODE processed\n");
            break;

          /* NodeName */
          case KEY_NODENAME:
            ActGad(GD_NODENAME_STR);
            DEBUG_PRINTF("  KEY_NODENAME processed\n");
            break;

          /* WinTitle */
          case KEY_WINTITLE:
            ActGad(GD_WINTITLE_STR);
            DEBUG_PRINTF("  KEY_WINTITLE processed\n");
            break;

          /* NextNode */
          case KEY_NEXTNODE_LWR:
            ActGad(GD_NEXTNODE_STR);
            DEBUG_PRINTF("  KEY_NEXTNODE_LWR processed\n");
            break;

          case KEY_NEXTNODE_UPR:
            DoDocumentSelect(GD_NEXTNODE_STR,&AGuide.gt_CurDoc->doc_NextNode);
            DEBUG_PRINTF("  KEY_NEXTNODE_UPR processed\n");
            break;

          /* PrevNode */
          case KEY_PREVNODE_LWR:
            ActGad(GD_PREVNODE_STR);
            DEBUG_PRINTF("  KEY_PREVNODE_LWR processed\n");
            break;

          case KEY_PREVNODE_UPR:
            DoDocumentSelect(GD_PREVNODE_STR,&AGuide.gt_CurDoc->doc_PrevNode);
            DEBUG_PRINTF("  KEY_PREVNODE_UPR processed\n");
            break;

          /* TOCNode */
          case KEY_TOCNODE_LWR:
            ActGad(GD_TOCNODE_STR);
            DEBUG_PRINTF("  KEY_TOCNODE_LWR processed\n");
            break;

          case KEY_TOCNODE_UPR:
            DoDocumentSelect(GD_TOCNODE_STR,&AGuide.gt_CurDoc->doc_TOCNode);
            DEBUG_PRINTF("  KEY_TOCNODE_UPR processed\n");
            break;

          /* FileName */
          case KEY_FILENAME_LWR:
            ActGad(GD_FILENAME_STR);
            DEBUG_PRINTF("  KEY_FILENAME_LWR processed\n");
            break;

          case KEY_FILENAME_UPR:
            DoPathSelect(GD_FILENAME_STR,&AGuide.gt_CurDoc->doc_FileName);
            DEBUG_PRINTF("  KEY_FILENAME_UPR processed\n");
            break;

          /* EditCommands */
          case KEY_EDITCOMMS:
            OpenEditWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_EDITCOMMS processed\n");
            break;
        }

        /* Liste wieder anhängen */
        GT_SetGadgetAttrs(GadDat[GD_DOCS_LST].Gadget,
                          DocsWin,NULL,
                          GTLV_Labels,&AGuide.gt_Docs,
                          GTLV_Selected,AGuide.gt_CurSel,
                          GTLV_Top,AGuide.gt_CurSel,
                          TAG_DONE);

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
      }

      case IDCMP_RAWKEY:
      {
        if (qual&(IEQUALIFIER_RSHIFT|IEQUALIFIER_LSHIFT))
        {
          switch (code)
          {
            case CURSORDOWN:
              AGuide.gt_CurDoc=(struct Document *)AGuide.gt_Docs.lh_TailPred;
              AGuide.gt_CurSel=GetDocNum(AGuide.gt_CurDoc);

              UpdateDocsWin();
              UpdateEditWin();

              DEBUG_PRINTF("  CURSORDOWN processed\n");
              break;

            case CURSORUP:
              AGuide.gt_CurDoc=(struct Document *)AGuide.gt_Docs.lh_Head;
              AGuide.gt_CurSel=0;

              UpdateDocsWin();
              UpdateEditWin();

              DEBUG_PRINTF("  CURSORUP processed\n");
              break;
          }
        }
        else
        {
          switch (code)
          {
            case CURSORDOWN:
              if (AGuide.gt_CurDoc->doc_Node.ln_Succ->ln_Succ)
              {
                AGuide.gt_CurDoc=(struct Document *)AGuide.gt_CurDoc->doc_Node.ln_Succ;
                AGuide.gt_CurSel++;

                UpdateDocsWin();
                UpdateEditWin();
              }

              DEBUG_PRINTF("  CURSORDOWN processed\n");
              break;

            case CURSORUP:
              if (AGuide.gt_CurDoc->doc_Node.ln_Pred->ln_Pred)
              {
                AGuide.gt_CurDoc=(struct Document *)AGuide.gt_CurDoc->doc_Node.ln_Pred;
                AGuide.gt_CurSel--;

                UpdateDocsWin();
                UpdateEditWin();
              }

              DEBUG_PRINTF("  CURSORUP processed\n");
              break;
          }
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
