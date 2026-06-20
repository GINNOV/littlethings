/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     EditWin.c
** FUNKTION:  EditWindow-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

       struct Window     *EditWin=NULL;
       ULONG              EditBit=0;

static UWORD              ButW,ButH;
static UWORD              MinWidth,MinHeight;
static ULONG              OldSecs,OldMics;

#define PRINTIWIDTH    2
#define PRINTIHEIGHT   2
#define PRINTSPACING   2
#define BUTTONSPACING  2
#define SCROLLBORDER   5

static LONG               PrintX;
static LONG               PrintY;
static LONG               PrintHeight;
static LONG               VertScroll,HorizScroll;

static LONG               VisX;
static LONG               VisY;
static LONG               VisLn;
static LONG               AktLn;
static LONG               AktCol;
static LONG               OldLn;
static LONG               OldCol;

static BYTE               Mark;
static LONG               MarkLn;
static LONG               MarkCr;
static LONG               MarkCr2;

#define GD_DOWN_BUT       0
#define GD_UP_BUT         1
#define GD_VERT_SCR       2
#define GD_RIGHT_BUT      3
#define GD_LEFT_BUT       4
#define GD_HORI_SCR       5
#define GDNUM             6

#define GD_NEW_BUT        6
#define GD_DEL_BUT        7
#define GD_EDITCOMM_BUT   8
#define GD_EDITTEXT_BUT   9
#define GD_LOADTEXT_BUT  10
#define GD_FLUSHTEXT_BUT 11

static struct Image      *BorImags[GDNUM];
static struct Gadget     *BorList[GDNUM];
static struct Gadget     *GadList=NULL;
static BOOL               GadListRemoved;

#define KEY_NEW           0
#define KEY_DEL           1
#define KEY_EDITCOMM      2
#define KEY_EDITTEXT      3
#define KEY_LOADTEXT      4
#define KEY_FLUSHTEXT     5
#define KEY_NULL          6
#define KEYNUM            7

static char               VanKeys[KEYNUM];
static struct SepData     SepDat;

static void UpdateEditWinGads(void);
static void CalcEditWinVisible(void);
static void CalcMaxCol(void);
static void DrawMarkedText(void);
static void ClearEditWinGads(void);
static void ClearEditWinText(void);
static void PrintTextUD(void);
static void PrintTextL(void);
static void PrintTextR(void);

static struct TagItem IDCMPCodeMap[]={PGA_Top,ICSPECIAL_CODE,TAG_DONE};

/* ===================================================================================== UnInitEditWin
** gibt alle Recourcen für das EditWin frei
*/
void UnInitEditWin(void)
{
  ULONG i;

  DEBUG_PRINTF("\n    -- Invoking UnInitEditWin-function --\n");

  for (i=GD_DOWN_BUT;i<=GD_HORI_SCR;i++)
  {
    if (BorList[i]) DisposeObject(BorList[i]);
    if (BorImags[i]) DisposeObject(BorImags[i]);
  }

  DEBUG_PRINTF("  BorList and BorImags freed\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= InitEditWin
** kreiert alle Resourcen des MainWin
*/
BOOL InitEditWin(void)
{
  BOOL  rc=TRUE;

  DEBUG_PRINTF("\n  -- Invoking InitEditWin-Function --\n");

  if (rc)
  {
    /* Down-Image anfordern */
    if (BorImags[GD_DOWN_BUT]=(struct Image *)
        NewObject(NULL,SYSICLASS,
                  SYSIA_Which,DOWNIMAGE,
                  SYSIA_DrawInfo,Screen.ps_DrawInfo,
                  TAG_DONE))
    {
      DEBUG_PRINTF("  GD_DOWN_BUT-Image created\n");

      /* Down-Button anfordern */
      if (!(BorList[GD_DOWN_BUT]=(struct Gadget *)
            NewObject(NULL,BUTTONGCLASS,
                      GA_ID,GD_DOWN_BUT,
                      GA_Image,BorImags[GD_DOWN_BUT],
                      GA_RightBorder,TRUE,
                      GA_RelRight,-Screen.ps_WBorRight+1,
                      GA_RelBottom,-Screen.ps_WBorBottom-BorImags[GD_DOWN_BUT]->Height+1,
                      GA_Width,Screen.ps_WBorRight,
                      ICA_TARGET,ICTARGET_IDCMP,
                      TAG_DONE)))
      {
        rc=FALSE;
      }
    }
    else
      rc=FALSE;
  }

  /* vertikaler Up-Arrow */
  if (rc)
  {
    /* Up-Image anfordern */
    if (BorImags[GD_UP_BUT]=(struct Image *)
        NewObject(NULL,SYSICLASS,
                  SYSIA_Which,UPIMAGE,
                  SYSIA_DrawInfo,Screen.ps_DrawInfo,
                  TAG_DONE))
    {
      DEBUG_PRINTF("  GD_UP_BUT-Image created\n");

      /* Up-Button anfordern */
      if (!(BorList[GD_UP_BUT]=(struct Gadget *)
            NewObject(NULL,BUTTONGCLASS,
                      GA_ID,GD_UP_BUT,
                      GA_Previous,BorList[GD_DOWN_BUT],
                      GA_Image,BorImags[GD_UP_BUT],
                      GA_RightBorder,TRUE,
                      GA_RelRight,-Screen.ps_WBorRight+1,
                      GA_RelBottom,BorList[GD_DOWN_BUT]->TopEdge-BorImags[GD_UP_BUT]->Height,
                      GA_Width,Screen.ps_WBorRight,
                      ICA_TARGET,ICTARGET_IDCMP,
                      TAG_DONE)))
      {
        rc=FALSE;
      }
    }
    else
      rc=FALSE;
  }

  /* vertikales PropGadget */
  if (rc)
  {
    BorImags[GD_VERT_SCR]=NULL;

    /* Object anfordern */
    if (!(BorList[GD_VERT_SCR]=(struct Gadget *)
          NewObject(NULL,PROPGCLASS,
                    GA_ID,GD_VERT_SCR,
                    GA_Previous,BorList[GD_UP_BUT],
                    GA_RightBorder,TRUE,
                    GA_Top,Screen.ps_WBorTop+1,
                    GA_RelRight,-Screen.ps_WBorRight+5,
                    GA_RelHeight,-Screen.ps_WBorTop+BorList[GD_UP_BUT]->TopEdge-3,
                    GA_Width,Screen.ps_WBorRight-8,
                    PGA_Freedom,FREEVERT,
                    PGA_Total,0,
                    PGA_Top,0,
                    PGA_Visible,0,
                    PGA_NewLook,TRUE,
                    PGA_Borderless,TRUE,
                    ICA_TARGET,ICTARGET_IDCMP,
                    TAG_DONE)))
    {
      rc=FALSE;
    }
  }

  /* horizontaler Right-Arrow */
  if (rc)
  {
    /* Right-Image anfordern */
    if (BorImags[GD_RIGHT_BUT]=(struct Image *)
        NewObject(NULL,SYSICLASS,
                  SYSIA_Which,RIGHTIMAGE,
                  SYSIA_DrawInfo,Screen.ps_DrawInfo,
                  TAG_DONE))
    {
      DEBUG_PRINTF("  GD_RIGHT_BUT-Image created\n");

      /* Right-Button anfordern */
      if (!(BorList[GD_RIGHT_BUT]=(struct Gadget *)
            NewObject(NULL,BUTTONGCLASS,
                      GA_ID,GD_RIGHT_BUT,
                      GA_Previous,BorList[GD_VERT_SCR],
                      GA_Image,BorImags[GD_RIGHT_BUT],
                      GA_BottomBorder,TRUE,
                      GA_RelRight,-Screen.ps_WBorRight-BorImags[GD_RIGHT_BUT]->Width+1,
                      GA_RelBottom,-Screen.ps_WBorBottom+1,
                      GA_Height,Screen.ps_WBorBottom,
                      ICA_TARGET,ICTARGET_IDCMP,
                      TAG_DONE)))
      {
        rc=FALSE;
      }
    }
    else
      rc=FALSE;
  }

  /* horizontaler Left-Arrow */
  if (rc)
  {
    /* Left-Image anfordern */
    if (BorImags[GD_LEFT_BUT]=(struct Image *)
        NewObject(NULL,SYSICLASS,
                  SYSIA_Which,LEFTIMAGE,
                  SYSIA_DrawInfo,Screen.ps_DrawInfo,
                  TAG_DONE
                 ))
    {
      DEBUG_PRINTF("  GD_LEFT_BUT-Image created\n");

      /* Left-Button anfordern */
      if (!(BorList[GD_LEFT_BUT]=(struct Gadget *)
            NewObject(NULL,BUTTONGCLASS,
                      GA_ID,GD_LEFT_BUT,
                      GA_Previous,BorList[GD_RIGHT_BUT],
                      GA_Image,BorImags[GD_LEFT_BUT],
                      GA_BottomBorder,TRUE,
                      GA_RelRight,BorList[GD_RIGHT_BUT]->LeftEdge-BorImags[GD_LEFT_BUT]->Width,
                      GA_RelBottom,-Screen.ps_WBorBottom+1,
                      GA_Height,Screen.ps_WBorBottom,
                      ICA_TARGET,ICTARGET_IDCMP,
                      TAG_DONE
                     )))
      {
        rc=FALSE;
      }
    }
    else
      rc=FALSE;
  }

  /* horizontales PropGadget */
  if (rc)
  {
    BorImags[GD_HORI_SCR]=NULL;

    /* Object anfordern */
    if (!(BorList[GD_HORI_SCR]=(struct Gadget *)
          NewObject(NULL,PROPGCLASS,
                    GA_ID,GD_HORI_SCR,
                    GA_Previous,BorList[GD_LEFT_BUT],
                    GA_BottomBorder,TRUE,
                    GA_Left,3,
                    GA_RelBottom,-Screen.ps_WBorBottom+3,
                    GA_RelWidth,BorList[GD_LEFT_BUT]->LeftEdge-6,
                    GA_Height,Screen.ps_WBorBottom-4,
                    PGA_Freedom,FREEHORIZ,
                    PGA_Total,0,
                    PGA_Top,0,
                    PGA_Visible,0,
                    PGA_NewLook,TRUE,
                    PGA_Borderless,TRUE,
                    ICA_TARGET,ICTARGET_IDCMP,
                    ICA_MAP,IDCMPCodeMap,
                    TAG_DONE
                   )))
    {
      rc=FALSE;
    }
  }

  if (!rc)
    EasyRequestAllWins("Error on creating the border\n"
                       "gadgets for the Editor Window",
                       "Ok");

  if (rc)
  {
    ULONG i;
    UWORD w[6];

    w[0]=TextLength(&Screen.ps_DummyRPort,"_New Comm",strlen("_New Comm"));
    w[1]=TextLength(&Screen.ps_DummyRPort,"_Delete Comm",strlen("_Delete Comm"));
    w[2]=TextLength(&Screen.ps_DummyRPort,"_Edit Comm",strlen("_Edit Comm"));
    w[3]=TextLength(&Screen.ps_DummyRPort,"Edit _Text",strlen("Edit _Text"));
    w[4]=TextLength(&Screen.ps_DummyRPort,"_Load Text",strlen("_Load Text"));
    w[5]=TextLength(&Screen.ps_DummyRPort,"Fl_ush Text",strlen("Fl_ush Text"));

    for (i=0,ButW=0;i<=5;i++)
      if (ButW<w[i]) ButW=w[i];

    DEBUG_PRINTF("  LabWidth calculated\n");

    ButW     +=INTERWIDTH;
    ButH     =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
    MinWidth =Screen.ps_Screen->WBorLeft+2*INTERWIDTH+ButW+Screen.ps_WBorRight;
    MinHeight=Screen.ps_WBorTop+6*ButH+7*INTERHEIGHT+SEPHEIGHT+2*PRINTIHEIGHT+3*PRINTSPACING+Screen.ps_PrintFont->tf_YSize+Screen.ps_WBorBottom;

    DEBUG_PRINTF("  MinWidth & MinHeight calculated\n");

    VanKeys[KEY_NEW]      =FindVanillaKey("_New Comm");
    VanKeys[KEY_DEL]      =FindVanillaKey("_Delete Comm");
    VanKeys[KEY_EDITCOMM] =FindVanillaKey("_Edit Comm");
    VanKeys[KEY_EDITTEXT] =FindVanillaKey("Edit _Text");
    VanKeys[KEY_LOADTEXT] =FindVanillaKey("_Load Text");
    VanKeys[KEY_FLUSHTEXT]=FindVanillaKey("Fl_ush Text");
    VanKeys[KEY_NULL]     ='\0';
    DEBUG_PRINTF("  VanillaKeys calculated\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(rc);
}

/* ============================================================================== CreateEditWinGadList
** kreiert die EditWinGadToolsGadgets
*/
struct Gadget *CreateEditWinGadList(void)
{
  UWORD ewinw=EditWin->Width-EditWin->BorderLeft-EditWin->BorderRight-2*INTERWIDTH;
  UWORD left=EditWin->BorderLeft+INTERWIDTH;
  UWORD top=EditWin->BorderTop+INTERHEIGHT;
  struct Gadget *gad;
  struct NewGadget ng;

  DEBUG_PRINTF("\n  -- Invoking CreateEditWinGadList-function --\n");

  gad=CreateContext(&GadList);

  /* NewComm-Button */
  ng.ng_LeftEdge  =left;
  ng.ng_TopEdge   =top;
  ng.ng_Width     =ButW;
  ng.ng_Height    =ButH;
  ng.ng_GadgetText="_New Comm";
  ng.ng_TextAttr  =&ScrP.ScrAttr;
  ng.ng_GadgetID  =GD_NEW_BUT;
  ng.ng_Flags     =PLACETEXT_IN;
  ng.ng_VisualInfo=Screen.ps_VisualInfo;
  ng.ng_UserData  =0;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* DeleteComm-Button */
  if (ewinw>=2*ButW+INTERWIDTH)
  {
    ng.ng_LeftEdge=left+ButW+INTERWIDTH;
    ng.ng_TopEdge=top;
  }
  else
  {
    ng.ng_LeftEdge=left;
    ng.ng_TopEdge=top+ButH+INTERHEIGHT;
  }

  ng.ng_GadgetText="_Delete Comm";
  ng.ng_GadgetID  =GD_DEL_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* EditComm-Button */
  if (ewinw>=3*ButW+2*INTERWIDTH)
  {
    ng.ng_LeftEdge=left+2*ButW+2*INTERWIDTH;
    ng.ng_TopEdge=top;
  }
  else
    if (ewinw>=2*ButW+INTERWIDTH)
    {
      ng.ng_LeftEdge=left;
      ng.ng_TopEdge=top+ButH+INTERHEIGHT;
    }
    else
    {
      ng.ng_LeftEdge=left;
      ng.ng_TopEdge=top+2*ButH+2*INTERHEIGHT;
    }

  ng.ng_GadgetText="_Edit Comm";
  ng.ng_GadgetID  =GD_EDITCOMM_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* EditText-Button */
  if (ewinw>=4*ButW+3*INTERWIDTH)
  {
    ng.ng_LeftEdge=left+3*ButW+3*INTERWIDTH;
    ng.ng_TopEdge=top;
  }
  else
    if (ewinw>=3*ButW+2*INTERWIDTH)
    {
      ng.ng_LeftEdge=left;
      ng.ng_TopEdge=top+ButH+INTERHEIGHT;
    }
    else
      if (ewinw>=2*ButW+INTERWIDTH)
      {
        ng.ng_LeftEdge=left+ButW+INTERWIDTH;
        ng.ng_TopEdge=top+ButH+INTERHEIGHT;
      }
      else
      {
        ng.ng_LeftEdge=left;
        ng.ng_TopEdge=top+3*ButH+3*INTERHEIGHT;
      }

  ng.ng_GadgetText="Edit _Text";
  ng.ng_GadgetID  =GD_EDITTEXT_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* LoadText-Button */
  if (ewinw>=5*ButW+4*INTERWIDTH)
  {
    ng.ng_LeftEdge=left+4*ButW+4*INTERWIDTH;
    ng.ng_TopEdge=top;
  }
  else
    if (ewinw>=4*ButW+3*INTERWIDTH)
    {
      ng.ng_LeftEdge=left;
      ng.ng_TopEdge=top+ButH+INTERHEIGHT;
    }
    else
      if (ewinw>=3*ButW+2*INTERWIDTH)
      {
        ng.ng_LeftEdge=left+ButW+INTERWIDTH;
        ng.ng_TopEdge=top+ButH+INTERHEIGHT;
      }
      else
        if (ewinw>=2*ButW+INTERWIDTH)
        {
          ng.ng_LeftEdge=left;
          ng.ng_TopEdge=top+2*ButH+2*INTERHEIGHT;
        }
        else
        {
          ng.ng_LeftEdge=left;
          ng.ng_TopEdge=top+4*ButH+4*INTERHEIGHT;
        }

  ng.ng_GadgetText="_Load Text";
  ng.ng_GadgetID  =GD_LOADTEXT_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* FlushText-Button */
  if (ewinw>=6*ButW+5*INTERWIDTH)
  {
    ng.ng_LeftEdge=left+5*ButW+5*INTERWIDTH;
    ng.ng_TopEdge=top;
  }
  else
    if (ewinw>=5*ButW+4*INTERWIDTH)
    {
      ng.ng_LeftEdge=left;
      ng.ng_TopEdge=top+ButH+INTERHEIGHT;
    }
    else
      if (ewinw>=4*ButW+3*INTERWIDTH)
      {
        ng.ng_LeftEdge=left+ButW+INTERWIDTH;
        ng.ng_TopEdge=top+ButH+INTERHEIGHT;
      }
      else
        if (ewinw>=3*ButW+2*INTERWIDTH)
        {
          ng.ng_LeftEdge=left+2*ButW+2*INTERWIDTH;
          ng.ng_TopEdge=top+ButH+INTERHEIGHT;
        }
        else
          if (ewinw>=2*ButW+INTERWIDTH)
          {
            ng.ng_LeftEdge=left+ButW+INTERWIDTH;
            ng.ng_TopEdge=top+2*ButH+2*INTERHEIGHT;
          }
          else
          {
            ng.ng_LeftEdge=left;
            ng.ng_TopEdge=top+5*ButH+5*INTERHEIGHT;
          }

  ng.ng_GadgetText="Fl_ush Text";
  ng.ng_GadgetID  =GD_FLUSHTEXT_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  SepDat.TopEdge=ng.ng_TopEdge+ButH+INTERHEIGHT;

  if (!gad)
  {
    DEBUG_PRINTF("    error - freeing everything\n");
    FreeGadgets(GadList);
    GadList=NULL;
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(gad);
}

/* ====================================================================================== CloseEditWin
** schließt das EditWin
*/
void CloseEditWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseEditWin-function --\n");

  if (EditWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(EditWin);
    DEBUG_PRINTF("  MenuStrip at EditWin cleared\n");

    if (GadList)
    {
      RemoveGList(EditWin,GadList,~0);
      DEBUG_PRINTF("  GadList removed from EditWin\n");

      /* Gadget freigeben */
      FreeGadgets(GadList);
      GadList=NULL;
      DEBUG_PRINTF("  GadList freed\n");
    }

    /* Window schließen */
    CloseWindow(EditWin);
    EditWin=NULL;
    EditBit=0;
    DEBUG_PRINTF("  EditWin closed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= OpenEditWin
** öffnet das EditWin
*/
BOOL OpenEditWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenEditWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!EditWin)
  {
    if (MinWidth>WinPosP.EditWWidth) WinPosP.EditWWidth=MinWidth;
    if (MinHeight>WinPosP.EditWHeight)WinPosP.EditWHeight=MinHeight;

    DEBUG_PRINTF("  MinWidth & MinHeight calculated\n");

    /* Window öffnen */
    if (EditWin=
        OpenWindowTags(NULL,
                       WA_Left,WinPosP.EditWLeft,
                       WA_Top,WinPosP.EditWTop,
                       WA_Width,WinPosP.EditWWidth,
                       WA_Height,WinPosP.EditWHeight,
                       WA_MinWidth,MinWidth,
                       WA_MinHeight,MinHeight,
                       WA_MaxWidth,~0,
                       WA_MaxHeight,~0,
                       WA_Title,"Text Editor",
                       WA_ScreenTitle,Screen.ps_Title,
                       WA_Gadgets,BorList[0],
                       WA_IDCMP,IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_NEWSIZE|\
                                IDCMP_GADGETUP|IDCMP_MOUSEBUTTONS|IDCMP_INTUITICKS|\
                                IDCMP_REFRESHWINDOW|IDCMP_IDCMPUPDATE|IDCMP_SIZEVERIFY|\
                                IDCMP_VANILLAKEY|IDCMP_RAWKEY,
                       WA_Flags,WFLG_SIMPLE_REFRESH|WFLG_DRAGBAR|WFLG_DEPTHGADGET|\
                                WFLG_CLOSEGADGET|WFLG_SIZEGADGET|WFLG_SIZEBBOTTOM|\
                                WFLG_SIZEBRIGHT|WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                       WA_AutoAdjust,TRUE,
                       WA_PubScreen,Screen.ps_Screen,
                       TAG_DONE))
    {
      DEBUG_PRINTF("  EditWin opened\n");

      if (CreateEditWinGadList())
      {
        DEBUG_PRINTF("  GadList created\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(EditWin,Menus);
        DEBUG_PRINTF("  Menus set at EditWin\n");

        /* Gadgetlist anhängen */
        AddGList(EditWin,GadList,~0,~0,NULL);
        GadListRemoved=FALSE;
        DEBUG_PRINTF("  GadList added to EditWin\n");

        /* Window neu aufbauen */
        RefreshGList(GadList,EditWin,NULL,~0);
        GT_RefreshWindow(EditWin,NULL);
        DEBUG_PRINTF("  GadList refreshed\n");

        SepDat.Width   =EditWin->Width-EditWin->BorderLeft-EditWin->BorderRight-2*INTERWIDTH;
        SepDat.LeftEdge=EditWin->BorderLeft+INTERWIDTH;
        DrawSeparators(EditWin,&SepDat,1);

        PrintX     =EditWin->BorderLeft+PRINTIWIDTH;
        PrintY     =SepDat.TopEdge+SEPHEIGHT+PRINTIHEIGHT+PRINTSPACING;
        PrintHeight=Screen.ps_PrintFont->tf_YSize+PRINTSPACING;
        VertScroll =2*Screen.ps_PrintFont->tf_YSize+PRINTSPACING;
        HorizScroll=2*Screen.ps_PrintFont->tf_XSize;

        SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
        SetFont(EditWin->RPort,Screen.ps_PrintFont);
        CalcEditWinVisible();

        CalcMaxCol();

        if (AktLn>AGuide.gt_CurDoc->doc_NumLn-VisLn)
        {
          AktLn=AGuide.gt_CurDoc->doc_NumLn-VisLn;
          if (AktLn<0) AktLn=0;
        }

        if (AktCol>AGuide.gt_CurDoc->doc_MaxCol-VisX)
        {
          AktCol=AGuide.gt_CurDoc->doc_MaxCol-VisX;
          if (AktCol<0) AktCol=0;
        }

        UpdateEditWinGads();

        OldLn=AktLn;
        OldCol=AktCol;
        PrintTextUD();

        OldSecs=0;
        OldMics=0;

        /* SigBit setzen */
        EditBit=1UL<<EditWin->UserPort->mp_SigBit;
        WinPosP.EditWin=TRUE;

        ProgScreenToFront();

        /* OK */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on creating the gadgets\n"
                           "for the Text Editor Window",
                           "Ok");
    }
    else
      EasyRequestAllWins("Error on opening the Text Editor Window",
                         "Ok");

    DEBUG_PRINTF("  error - freeing everything\n");
    CloseEditWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(EditWin);
    WindowToFront(EditWin);
  }

  DEBUG_PRINTF("  EditWin already opened\n  -- returning --\n\n");
  return(TRUE);
}

/* ==================================================================================== GetEditWinSize
** speichert die aktuelle Windowposition und -größe in der WinPosP-Struktur ab
*/
void GetEditWinSize(void)
{
  if (EditWin)
  {
    WinPosP.EditWLeft  =EditWin->LeftEdge;
    WinPosP.EditWTop   =EditWin->TopEdge;
    WinPosP.EditWWidth =EditWin->Width;
    WinPosP.EditWHeight=EditWin->Height;
  }
}

/* =================================================================================== DoEditASCIIText
** /**/setzt den BlockReq im EditWin und ruft dann EditASCIIText auf
*/
static
void DoEditASCIIText(void)
{
  struct Requester req;
  struct Gadget    gad;
  struct IntuiText gaditext;
  struct Border    gbshine,gbshadow,gbshine2,gbshadow2,rbshine,rbshadow;
  UWORD gbshinexy[10],gbshadowxy[10],rbshinexy[10],rbshadowxy[10];
  UWORD gadw,gadh;
  UWORD reqx=EditWin->BorderLeft+2;
  UWORD reqy=EditWin->BorderTop+1;
  UWORD reqw=EditWin->Width-EditWin->BorderRight-2-reqx;
  UWORD reqh=EditWin->Height-EditWin->BorderBottom-1-reqy;

  DEBUG_PRINTF("\n    -- Invoking UpdateEditWinGads-function --\n");

  gaditext.FrontPen =Screen.ps_DrawInfo->dri_Pens[TEXTPEN];
  gaditext.BackPen  =Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN];
  gaditext.DrawMode =JAM2;
  gaditext.LeftEdge =INTERWIDTH;
  gaditext.TopEdge  =INTERHEIGHT;
  gaditext.ITextFont=&ScrP.ScrAttr;
  gaditext.IText    ="Abort text editing";
  gaditext.NextText =NULL;

  gadw=IntuiTextLength(&gaditext)+2*INTERWIDTH;
  gadh=Screen.ps_ScrFont->tf_YSize+2*INTERHEIGHT;

  gbshinexy[0]=gadw-2;
  gbshinexy[1]=0;
  gbshinexy[2]=0;
  gbshinexy[3]=0;
  gbshinexy[4]=0;
  gbshinexy[5]=gadh-1;
  gbshinexy[6]=1;
  gbshinexy[7]=gadh-2;
  gbshinexy[8]=1;
  gbshinexy[9]=1;

  gbshadowxy[0]=1;
  gbshadowxy[1]=gadh-1;
  gbshadowxy[2]=gadw-1;
  gbshadowxy[3]=gadh-1;
  gbshadowxy[4]=gadw-1;
  gbshadowxy[5]=0;
  gbshadowxy[6]=gadw-2;
  gbshadowxy[7]=1;
  gbshadowxy[8]=gadw-2;
  gbshadowxy[9]=gadh-2;
   
  gbshine.LeftEdge=gbshadow.LeftEdge=gbshine2.LeftEdge=gbshadow2.LeftEdge=0;
  gbshine.TopEdge =gbshadow.TopEdge =gbshine2.TopEdge =gbshadow2.TopEdge =0;
  gbshine.BackPen =gbshadow.BackPen =gbshine2.BackPen =gbshadow2.BackPen =0;
  gbshine.DrawMode=gbshadow.DrawMode=gbshine2.DrawMode=gbshadow2.DrawMode=JAM1;
  gbshine.Count   =gbshadow.Count   =gbshine2.Count   =gbshadow2.Count   =5;

  gbshine.FrontPen  =Screen.ps_DrawInfo->dri_Pens[SHINEPEN];
  gbshine.XY        =gbshinexy;
  gbshine.NextBorder=&gbshadow;

  gbshadow.FrontPen  =Screen.ps_DrawInfo->dri_Pens[SHADOWPEN];
  gbshadow.XY        =gbshadowxy;
  gbshadow.NextBorder=NULL;
     
  gbshine2.FrontPen  =gbshine.FrontPen;
  gbshine2.XY        =gbshadowxy;
  gbshine2.NextBorder=&gbshadow2;

  gbshadow2.FrontPen  =gbshadow.FrontPen;
  gbshadow2.XY        =gbshinexy;
  gbshadow2.NextBorder=NULL;
     
  gad.NextGadget   =NULL;
  gad.Width        =gadw;
  gad.Height       =gadh;
  gad.LeftEdge     =(reqw-gad.Width)/2;
  gad.TopEdge      =(reqh-gad.Height)/2;
  gad.Flags        =GFLG_GADGHIMAGE;
  gad.Activation   =GACT_RELVERIFY;
  gad.GadgetType   =GTYP_BOOLGADGET|GTYP_REQGADGET;
  gad.GadgetRender =&gbshine;
  gad.SelectRender =&gbshine2;
  gad.GadgetText   =&gaditext;
  gad.MutualExclude=0;
  gad.SpecialInfo  =NULL;
  gad.GadgetID     =0;
  gad.UserData     =NULL;

  rbshinexy[0]=reqw-2;
  rbshinexy[1]=0;
  rbshinexy[2]=0;
  rbshinexy[3]=0;
  rbshinexy[4]=0;
  rbshinexy[5]=reqh-1;
  rbshinexy[6]=1;
  rbshinexy[7]=reqh-2;
  rbshinexy[8]=1;
  rbshinexy[9]=1;

  rbshadowxy[0]=1;
  rbshadowxy[1]=reqh-1;
  rbshadowxy[2]=reqw-1;
  rbshadowxy[3]=reqh-1;
  rbshadowxy[4]=reqw-1;
  rbshadowxy[5]=0;
  rbshadowxy[6]=reqw-2;
  rbshadowxy[7]=1;
  rbshadowxy[8]=reqw-2;
  rbshadowxy[9]=reqh-2;
   
  rbshine.LeftEdge=rbshadow.LeftEdge=0;
  rbshine.TopEdge =rbshadow.TopEdge =0;
  rbshine.BackPen =rbshadow.BackPen =0;
  rbshine.DrawMode=rbshadow.DrawMode=JAM1;
  rbshine.Count   =rbshadow.Count   =5;

  rbshine.FrontPen  =Screen.ps_DrawInfo->dri_Pens[SHINEPEN];
  rbshine.XY        =rbshinexy;
  rbshine.NextBorder=&rbshadow;

  rbshadow.FrontPen  =Screen.ps_DrawInfo->dri_Pens[SHADOWPEN];
  rbshadow.XY        =rbshadowxy;
  rbshadow.NextBorder=NULL;
 
  req.OlderRequest=NULL;
  req.LeftEdge    =reqx;
  req.TopEdge     =reqy;
  req.Width       =reqw;
  req.Height      =reqh;
  req.ReqGadget   =&gad;
  req.ReqBorder   =&rbshine;
  req.ReqText     =NULL;
  req.Flags       =0;
  req.BackFill    =Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN];

  DisableAllWindows();
  ModifyIDCMP(EditWin,IDCMP_REFRESHWINDOW|IDCMP_GADGETUP);

  if (Request(&req,EditWin))
  {
    WindowLimits(EditWin,EditWin->Width,EditWin->Height,
                 EditWin->Width,EditWin->Height);

    EditASCIIText(AGuide.gt_CurDoc,EditWin->UserPort);

    WindowLimits(EditWin,MinWidth,MinHeight,~0,~0);
    EndRequest(&req,EditWin);

    /* da sich die NumLn verkleinert haben könnte */
    if (AktLn>AGuide.gt_CurDoc->doc_NumLn) AktLn=AGuide.gt_CurDoc->doc_NumLn;
    UpdateEditWin();
  }

  EnableAllWindows();
            
  DEBUG_PRINTF("    -- returning --\n\n");
}
/**/

/* ================================================================================= UpdateEditWinGads
** updated die Gadgets im EditWin
*/
static
void UpdateEditWinGads(void)
{
  SetGadgetAttrs(BorList[GD_VERT_SCR],EditWin,NULL,
                 PGA_Visible,VisLn,
                 PGA_Total,AGuide.gt_CurDoc->doc_NumLn,
                 PGA_Top,AktLn,
                 TAG_DONE);

  SetGadgetAttrs(BorList[GD_HORI_SCR],EditWin,NULL,
                 PGA_Visible,VisX,
                 PGA_Total,AGuide.gt_CurDoc->doc_MaxCol,
                 PGA_Top,AktCol,
                 TAG_DONE);
}

/* ===================================================================================== UpdateEditWin
** updated die Gadgets im EditWin und printet den Text neu
*/
void UpdateEditWin(void)
{
  DEBUG_PRINTF("\n    -- Invoking UpdateEditWin-function --\n");

  /* diese Funktion wird auch aus anderen Modulen aufgerufen */
  if (EditWin)
  {
    UpdateEditWinGads();
    DEBUG_PRINTF("    gadgets set\n");

    ClearEditWinText();

    DrawSeparators(EditWin,&SepDat,1);
    DEBUG_PRINTF("    separators drawn\n");

    OldLn=AktLn;
    OldCol=AktCol;
    PrintTextUD();
    DEBUG_PRINTF("    text printed\n");
  }

  DEBUG_PRINTF("    -- returning --\n\n");
}

/* ================================================================================ CalcEditWinVisible
** /**/berechnet aus Window-Höhe und -Breite die sichtbaren Linien und Spalten
*/
static
void CalcEditWinVisible(void)
{
  VisLn=(EditWin->Height-PrintY-EditWin->BorderBottom-PRINTIHEIGHT)/PrintHeight;

  VisX=EditWin->Width-PrintX-EditWin->BorderRight-PRINTIWIDTH;
  VisY=VisLn*PrintHeight;
}
/**/

/* ======================================================================================== CalcMaxCol
** /**/berechnet den pixelmäßig längsten Satz
*/
static
void CalcMaxCol(void)
{
  if (AGuide.gt_CurDoc)
  {
    ULONG ln;
    LONG tmp;

    AGuide.gt_CurDoc->doc_MaxCol=0;
    for (ln=0;ln<AGuide.gt_CurDoc->doc_NumLn;ln++)
    {
      tmp=TextLength(EditWin->RPort,AGuide.gt_CurDoc->doc_Lines[ln].al_Line,AGuide.gt_CurDoc->doc_Lines[ln].al_Len);

      if (AGuide.gt_CurDoc->doc_MaxCol<tmp)
        AGuide.gt_CurDoc->doc_MaxCol=tmp;
    }
  }
}
/**/

/* ==================================================================================== DrawMarkedText
** /**/zeichnet den markierten Textbereich
*/
static
void DrawMarkedText(void)
{
  WORD cr,cr2,i;
  LONG x,x2,y;
  struct Command *com;

  if (MarkCr>MarkCr2)
  {
    cr=MarkCr2;
    cr2=MarkCr;
  }
  else
  {
    cr=MarkCr;
    cr2=MarkCr2;
  }

  i=0;
  x=PrintX-AktCol;

  com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
  if (com->com_Node.mln_Succ && com->com_Char==0) x+=BUTTONSPACING;

  while(i<cr)
  {
    x+=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Line[i],1);
    i++;

    if (com->com_Node.mln_Pred && com->com_Node.mln_Succ)
    {
      if (com->com_Char+com->com_Len==i)
      {
        x+=BUTTONSPACING;
        com=(struct Command *)com->com_Node.mln_Succ;
      }

      if (com->com_Char==i) x+=BUTTONSPACING;
    }
  }

  x2=x;

  while(i<cr2)
  {
    x2+=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Line[i],1);
    i++;
  }

  y=PrintY+(MarkLn-AktLn)*PrintHeight;

  if (x<PrintX) x=PrintX;
  if (x2>PrintX+VisX) x2=PrintX+VisX;

  if (x2-x>0)
  {
    SetDrMd(EditWin->RPort,COMPLEMENT);
    RectFill(EditWin->RPort,x,y,x2-1,y+Screen.ps_PrintFont->tf_YSize-1);
    SetDrMd(EditWin->RPort,JAM2);
  }
}
/**/

/* ================================================================================== ClearEditWinGads
** löscht die Gadgets
*/
static
void ClearEditWinGads(void)
{
  SetDrMd(EditWin->RPort,JAM2);
  SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
  RectFill(EditWin->RPort,
           EditWin->BorderLeft,
           EditWin->BorderTop,
           EditWin->Width-EditWin->BorderRight-1,
           SepDat.TopEdge-1);
}

/* ================================================================================== ClearEditWinText
** löscht das Textfeld + Separator
*/
static
void ClearEditWinText(void)
{
  SetDrMd(EditWin->RPort,JAM2);
  SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
  RectFill(EditWin->RPort,
           EditWin->BorderLeft,
           SepDat.TopEdge,
           EditWin->Width-EditWin->BorderRight-1,
           EditWin->Height-EditWin->BorderBottom-1);
}

/* ========================================================================================= GetDRIPen
** /**/ermittelt aus der Array-Nummer die Nummer des wirklichen DRIPens
*/
static
UBYTE GetDRIPen(UBYTE pen)
{
  switch(pen)
  {
    case COL_TEXT:     pen=TEXTPEN; break;
    case COL_SHINE:    pen=SHINEPEN; break;
    case COL_SHADOW:   pen=SHADOWPEN; break;
    case COL_FILL:     pen=FILLPEN; break;
    case COL_FILLTEXT: pen=FILLTEXTPEN; break;
    case COL_BG:       pen=BACKGROUNDPEN; break;
    case COL_HIGHL:    pen=HIGHLIGHTTEXTPEN; break;
  }

  return(pen);
}
/**/

/* ======================================================================================= PrintTextUD
** /**/gibt den Text im EditWin aus, scrolling nach oben oder unten
*/
static
void PrintTextUD(void)
{
  if (AGuide.gt_CurDoc->doc_Buf)
  {
    LONG lstcol;
    WORD printpos,printlen;
    LONG fstln,lstln,i;
    LONG x,y,dy,butx,buty,butw,buth;
    BYTE pen;
    struct Command *com;

    dy=(AktLn-OldLn)*PrintHeight;

    if (dy<-VisY) dy=-VisY;
    if (dy>VisY) dy=VisY;

    /* PrintPositon berechnen */
    if (OldLn>AktLn)
    {
      fstln=AktLn;
      lstln=OldLn;
      y=PrintY;

      if (lstln>AktLn+VisLn) lstln=AktLn+VisLn;
    }

    if (OldLn==AktLn)
    {
      fstln=AktLn;
      lstln=AktLn+VisLn;
      y=PrintY;
    }

    if (OldLn<AktLn)
    {
      fstln=OldLn+VisLn;
      lstln=AktLn+VisLn;
      y=PrintY+VisY-dy;

      if (fstln<AktLn) fstln=AktLn;
    }

    if (lstln>=AGuide.gt_CurDoc->doc_NumLn) lstln=AGuide.gt_CurDoc->doc_NumLn-1;

    lstcol=AktCol+VisX;

    SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[TEXTPEN]);
    SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
    SetDrMd(EditWin->RPort,JAM2);
    SetSoftStyle(EditWin->RPort,FS_NORMAL,FSF_BOLD|FSF_ITALIC|FSF_UNDERLINED);

    /* Text scrollen */
    ScrollRaster(EditWin->RPort,
                 0,dy,
                 PrintX,
                 PrintY-PRINTSPACING,
                 PrintX+VisX-1,
                 PrintY+VisY-1);

    com=NULL;

    for (i=fstln;i>0;i--)
    {
      com=GetCommVecLnTail(AGuide.gt_CurDoc,i);

      while(com->com_Node.mln_Pred)
      {
        if (com->com_Type==COMT_STYLE)
        {
          if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
            SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

          if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
            SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

          if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
            SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

          if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
            SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

          if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
            SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

          if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
            SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

          SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
          SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);

          break;
        }

        com=(struct Command *)com->com_Node.mln_Pred;
      }
    }

    y+=Screen.ps_PrintFont->tf_Baseline;

    /* Text printen */
    while (fstln<lstln)
    {
      printpos=0;
      i=0;

      if (fstln==MarkLn) DrawMarkedText();

      com=GetCommVecLnHead(AGuide.gt_CurDoc,fstln);

      if (com->com_Node.mln_Succ && com->com_Char==0 && i<AktCol)
        i+=BUTTONSPACING;

      while(printpos<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len-1 && i<AktCol)
      {
        i+=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],1);
        printpos++;

        if (com->com_Node.mln_Pred && com->com_Node.mln_Succ)
        {
          if (com->com_Char+com->com_Len==printpos && i<AktCol)
          {
            i+=BUTTONSPACING;
            com=(struct Command *)com->com_Node.mln_Succ;
          }

          if (com->com_Char==printpos && i<AktCol) i+=BUTTONSPACING;
        }
      }

      printlen=0;
      x=i-AktCol+PrintX;

      while(i<lstcol && com->com_Node.mln_Succ)
      {
        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>0)
        {
          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);
        }

        if (printpos+printlen==com->com_Char)
          i+=BUTTONSPACING;

        x=i-AktCol+PrintX;
        printpos+=printlen;
        printlen=0;

        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char+com->com_Len)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>=0)
        {
          if (printpos>=com->com_Char && printpos<=com->com_Char+com->com_Len)
          {
            if (com->com_Type==COMT_STYLE)
            {
              if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
                SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

              if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
                SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

              if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
                SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

              if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
                SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

              if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
                SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

              if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
                SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

              SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
              SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);
            }
            else
            {
              butx=x-BUTTONSPACING;
              if (butx<PrintX) butx=PrintX;

              butw=i-AktCol+PrintX-butx+BUTTONSPACING-1;
              if (butx+butw>PrintX+VisX) butw=PrintX+VisX-butx;

              buty=y-Screen.ps_PrintFont->tf_Baseline-1;
              buth=Screen.ps_PrintFont->tf_YSize+1;

              if (butw>1)
              {
                pen=EditWin->RPort->FgPen;
                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHINEPEN]);

                Move(EditWin->RPort,butx,buty);
                Draw(EditWin->RPort,butx+butw-1,buty);

                if (printpos==com->com_Char)
                {
                  Move(EditWin->RPort,butx,buty);
                  Draw(EditWin->RPort,butx,buty+buth);

                  Move(EditWin->RPort,butx+1,buty);
                  Draw(EditWin->RPort,butx+1,buty+buth-1);
                }

                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHADOWPEN]);

                Move(EditWin->RPort,butx+1,buty+buth);
                Draw(EditWin->RPort,butx+butw-1,buty+buth);

                if (printpos+printlen==com->com_Char+com->com_Len)
                {
                  Move(EditWin->RPort,butx+butw,buty);
                  Draw(EditWin->RPort,butx+butw,buty+buth);

                  Move(EditWin->RPort,butx+butw-1,buty+1);
                  Draw(EditWin->RPort,butx+butw-1,buty+buth);
                }

                SetAPen(EditWin->RPort,pen);
              }
            }
          }

          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);

        }

        i+=BUTTONSPACING;
        com=(struct Command *)com->com_Node.mln_Succ;

        x=i-AktCol+PrintX;
        printpos+=printlen;
        printlen=0;
      }

      while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol)
      {
        i+=TextLength(EditWin->RPort,
                      &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
        printlen++;
      }

      if (i>AktCol+VisX) printlen--;

      if (x>=PrintX && printlen>0)
      {
        Move(EditWin->RPort,x,y);
        Text(EditWin->RPort,
             &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
             printlen);
      }

      if (fstln==MarkLn) DrawMarkedText();

      fstln++;
      y+=PrintHeight;
    }
  }
}
/**/

/* ======================================================================================== PrintTextL
** /**/gibt den Text im EditWin aus, scrolling nach links
*/
static
void PrintTextL(void)
{
  if (AGuide.gt_CurDoc->doc_Buf)
  {
    LONG fstcol,lstcol;
    WORD printpos,printlen;
    LONG fstln,lstln,i;
    LONG x,y,ix,dx,butx,buty,butw,buth;
    BYTE pen;
    struct Command *com;

    fstln=AktLn;
    lstln=AktLn+VisLn;
    y=PrintY;

    if (lstln>=AGuide.gt_CurDoc->doc_NumLn) lstln=AGuide.gt_CurDoc->doc_NumLn-1;

    dx=AktCol-OldCol;

    if (dx<-VisX) dx=-VisX;

    fstcol=AktCol;
    lstcol=OldCol;
    ix=PrintX;

    if (lstcol>AktCol+VisX) lstcol=AktCol+VisX;

    SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[TEXTPEN]);
    SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
    SetDrMd(EditWin->RPort,JAM2);
    SetSoftStyle(EditWin->RPort,FS_NORMAL,FSF_BOLD|FSF_ITALIC|FSF_UNDERLINED);

    /* Text scrollen */
    ScrollRaster(EditWin->RPort,
                 dx,0,
                 PrintX,
                 PrintY-PRINTSPACING,
                 PrintX+VisX-1,
                 PrintY+VisY-1);

    com=NULL;

    for (i=fstln;i>0;i--)
    {
      com=GetCommVecLnTail(AGuide.gt_CurDoc,i);

      while(com->com_Node.mln_Pred)
      {
        if (com->com_Type==COMT_STYLE)
        {
          if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
            SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

          if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
            SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

          if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
            SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

          if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
            SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

          if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
            SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

          if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
            SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

          SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
          SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);

          break;
        }

        com=(struct Command *)com->com_Node.mln_Pred;
      }
    }

    y+=Screen.ps_PrintFont->tf_Baseline;

    /* Text printen */
    while (fstln<lstln)
    {
      printpos=0;
      i=0;

      if (fstln==MarkLn) DrawMarkedText();

      com=GetCommVecLnHead(AGuide.gt_CurDoc,fstln);

      if (com->com_Node.mln_Succ && com->com_Char==0 && i<AktCol)
        i+=BUTTONSPACING;

      while(printpos<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len-1 && i<fstcol)
      {
        i+=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],1);
        printpos++;

        if (com->com_Node.mln_Pred && com->com_Node.mln_Succ)
        {
          if (com->com_Char+com->com_Len==printpos && i<AktCol)
          {
            i+=BUTTONSPACING;
            com=(struct Command *)com->com_Node.mln_Succ;
          }

          if (com->com_Char==printpos && i<AktCol) i+=BUTTONSPACING;
        }
      }

      printlen=0;
      x=i-fstcol+ix;

      while(i<lstcol && com->com_Node.mln_Succ)
      {
        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>0)
        {
          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);
        }

        if (printpos+printlen==com->com_Char)
          i+=BUTTONSPACING;

        x=i-fstcol+ix;
        printpos+=printlen;
        printlen=0;

        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char+com->com_Len)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>=0)
        {
          if (printpos>=com->com_Char && printpos<=com->com_Char+com->com_Len)
          {
            if (com->com_Type==COMT_STYLE)
            {
              if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
                SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

              if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
                SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

              if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
                SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

              if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
                SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

              if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
                SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

              if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
                SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

              SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
              SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);
            }
            else
            {
              butx=x-BUTTONSPACING;
              if (butx<PrintX) butx=PrintX;

              butw=i-fstcol+ix-butx+BUTTONSPACING-1;
              if (butx+butw>PrintX+VisX) butw=PrintX+VisX-butx;

              buty=y-Screen.ps_PrintFont->tf_Baseline-1;
              buth=Screen.ps_PrintFont->tf_YSize+1;

              if (butw>1)
              {
                pen=EditWin->RPort->FgPen;
                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHINEPEN]);

                Move(EditWin->RPort,butx,buty);
                Draw(EditWin->RPort,butx+butw-1,buty);

                if (printpos==com->com_Char)
                {
                  Move(EditWin->RPort,butx,buty);
                  Draw(EditWin->RPort,butx,buty+buth);

                  Move(EditWin->RPort,butx+1,buty);
                  Draw(EditWin->RPort,butx+1,buty+buth-1);
                }

                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHADOWPEN]);

                Move(EditWin->RPort,butx+1,buty+buth);
                Draw(EditWin->RPort,butx+butw-1,buty+buth);

                if (printpos+printlen==com->com_Char+com->com_Len)
                {
                  Move(EditWin->RPort,butx+butw,buty);
                  Draw(EditWin->RPort,butx+butw,buty+buth);

                  Move(EditWin->RPort,butx+butw-1,buty+1);
                  Draw(EditWin->RPort,butx+butw-1,buty+buth);
                }

                SetAPen(EditWin->RPort,pen);
              }
            }
          }

          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);

        }

        i+=BUTTONSPACING;
        com=(struct Command *)com->com_Node.mln_Succ;

        x=i-fstcol+ix;
        printpos+=printlen;
        printlen=0;
      }

      while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol)
      {
        i+=TextLength(EditWin->RPort,
                      &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
        printlen++;
      }

      if (i>AktCol+VisX) printlen--;

      if (x>=PrintX && printlen>0)
      {
        Move(EditWin->RPort,x,y);
        Text(EditWin->RPort,
             &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
             printlen);
      }

      if (fstln==MarkLn) DrawMarkedText();

      fstln++;
      y+=PrintHeight;
    }
  }
}
/**/

/* ======================================================================================== PrintTextR
** /**/gibt den Text im EditWin aus, scrolling nach rechts
*/
static
void PrintTextR(void)
{
  if (AGuide.gt_CurDoc->doc_Buf)
  {
    LONG fstcol,lstcol;
    WORD printpos,printlen;
    LONG fstln,lstln,i,j;
    LONG x,y,ix,dx,butx,buty,butw,buth;
    BYTE pen;
    struct Command *com;

    fstln=AktLn;
    lstln=AktLn+VisLn;
    y=PrintY;

    if (lstln>=AGuide.gt_CurDoc->doc_NumLn) lstln=AGuide.gt_CurDoc->doc_NumLn-1;

    dx=AktCol-OldCol;

    if (dx>VisX) dx=VisX;

    fstcol=OldCol+VisX;
    lstcol=AktCol+VisX;
    ix=PrintX+VisX-dx;

    if (fstcol<AktCol) fstcol=AktCol;
    if (lstcol>AGuide.gt_CurDoc->doc_MaxCol) lstcol=AGuide.gt_CurDoc->doc_MaxCol;

    SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[TEXTPEN]);
    SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[BACKGROUNDPEN]);
    SetDrMd(EditWin->RPort,JAM2);
    SetSoftStyle(EditWin->RPort,FS_NORMAL,FSF_BOLD|FSF_ITALIC|FSF_UNDERLINED);

    /* Text scrollen */
    ScrollRaster(EditWin->RPort,
                 dx,0,
                 PrintX,
                 PrintY-PRINTSPACING,
                 PrintX+VisX-1,
                 PrintY+VisY-1);

    com=NULL;

    for (i=fstln;i>0;i--)
    {
      com=GetCommVecLnTail(AGuide.gt_CurDoc,i);

      while(com->com_Node.mln_Pred)
      {
        if (com->com_Type==COMT_STYLE)
        {
          if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
            SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

          if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
            SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

          if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
            SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

          if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
            SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

          if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
            SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

          if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
            SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

          SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
          SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);

          break;
        }

        com=(struct Command *)com->com_Node.mln_Pred;
      }
    }

    y+=Screen.ps_PrintFont->tf_Baseline;

    /* Text printen */
    while (fstln<lstln)
    {
      printpos=0;
      i=0;

      if (fstln==MarkLn) DrawMarkedText();

      com=GetCommVecLnHead(AGuide.gt_CurDoc,fstln);

      if (com->com_Node.mln_Succ && com->com_Char==0 && i<fstcol)
        i+=BUTTONSPACING;

      j=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],1);

      while(printpos<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len-1 && i<fstcol-j)
      {
        i+=j;
        printpos++;
        j=TextLength(EditWin->RPort,&AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],1);

        if (com->com_Node.mln_Pred && com->com_Node.mln_Succ)
        {
          if (com->com_Char+com->com_Len==printpos && i<fstcol-j)
          {
            i+=BUTTONSPACING;
            com=(struct Command *)com->com_Node.mln_Succ;
          }

          if (com->com_Char==printpos && i<fstcol-j) i+=BUTTONSPACING;
        }
      }

      printlen=0;
      x=i-fstcol+ix;

      while(i<lstcol && com->com_Node.mln_Succ)
      {
        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>0)
        {
          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);
        }

        if (printpos+printlen==com->com_Char)
          i+=BUTTONSPACING;

        x=i-fstcol+ix;
        printpos+=printlen;
        printlen=0;

        while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol && printpos+printlen<com->com_Char+com->com_Len)
        {
          i+=TextLength(EditWin->RPort,
                        &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
          printlen++;
        }

        if (i>AktCol+VisX) printlen--;

        if (x>=PrintX && printlen>=0)
        {
          if (printpos>=com->com_Char && printpos<=com->com_Char+com->com_Len)
          {
            if (com->com_Type==COMT_STYLE)
            {
              if (com->com_Style&FSF_BOLD && !(EditWin->RPort->AlgoStyle&FSF_BOLD))
                SetSoftStyle(EditWin->RPort,FSF_BOLD,FSF_BOLD);

              if (!(com->com_Style&FSF_BOLD) && EditWin->RPort->AlgoStyle&FSF_BOLD)
                SetSoftStyle(EditWin->RPort,0,FSF_BOLD);

              if (com->com_Style&FSF_ITALIC && !(EditWin->RPort->AlgoStyle&FSF_ITALIC))
                SetSoftStyle(EditWin->RPort,FSF_ITALIC,FSF_ITALIC);

              if (!(com->com_Style&FSF_ITALIC) && EditWin->RPort->AlgoStyle&FSF_ITALIC)
                SetSoftStyle(EditWin->RPort,0,FSF_ITALIC);

              if (com->com_Style&FSF_UNDERLINED && !(EditWin->RPort->AlgoStyle&FSF_UNDERLINED))
                SetSoftStyle(EditWin->RPort,FSF_UNDERLINED,FSF_UNDERLINED);

              if (!(com->com_Style&FSF_UNDERLINED) && EditWin->RPort->AlgoStyle&FSF_UNDERLINED)
                SetSoftStyle(EditWin->RPort,0,FSF_UNDERLINED);

              SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_FGPen)]);
              SetBPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[GetDRIPen(com->com_BGPen)]);
            }
            else
            {
              butx=x-BUTTONSPACING;
              if (butx<PrintX) butx=PrintX;

              butw=i-fstcol+ix-butx+BUTTONSPACING-1;
              if (butx+butw>=PrintX+VisX) butw=PrintX+VisX-butx-1;

              buty=y-Screen.ps_PrintFont->tf_Baseline-1;
              buth=Screen.ps_PrintFont->tf_YSize+1;

              if (butw>1)
              {
                pen=EditWin->RPort->FgPen;
                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHINEPEN]);

                Move(EditWin->RPort,butx,buty);
                Draw(EditWin->RPort,butx+butw-1,buty);

                if (printpos==com->com_Char)
                {
                  Move(EditWin->RPort,butx,buty);
                  Draw(EditWin->RPort,butx,buty+buth);

                  Move(EditWin->RPort,butx+1,buty);
                  Draw(EditWin->RPort,butx+1,buty+buth-1);
                }

                SetAPen(EditWin->RPort,Screen.ps_DrawInfo->dri_Pens[SHADOWPEN]);

                Move(EditWin->RPort,butx+1,buty+buth);
                Draw(EditWin->RPort,butx+butw-1,buty+buth);

                if (printpos+printlen==com->com_Char+com->com_Len)
                {
                  Move(EditWin->RPort,butx+butw,buty);
                  Draw(EditWin->RPort,butx+butw,buty+buth);

                  Move(EditWin->RPort,butx+butw-1,buty+1);
                  Draw(EditWin->RPort,butx+butw-1,buty+buth);
                }

                SetAPen(EditWin->RPort,pen);
              }
            }
          }

          Move(EditWin->RPort,x,y);
          Text(EditWin->RPort,
               &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
               printlen);

        }

        i+=BUTTONSPACING;
        com=(struct Command *)com->com_Node.mln_Succ;

        x=i-fstcol+ix;
        printpos+=printlen;
        printlen=0;
      }

      while(printpos+printlen<AGuide.gt_CurDoc->doc_Lines[fstln].al_Len && i<lstcol)
      {
        i+=TextLength(EditWin->RPort,
                      &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos+printlen],1);
        printlen++;
      }

      if (i>AktCol+VisX) printlen--;

      if (x>=PrintX && printlen>0)
      {
        Move(EditWin->RPort,x,y);
        Text(EditWin->RPort,
             &AGuide.gt_CurDoc->doc_Lines[fstln].al_Line[printpos],
             printlen);
      }

      if (fstln==MarkLn) DrawMarkedText();

      fstln++;
      y+=PrintHeight;
    }
  }
}
/**/

/* ========================================================================================= DoNewComm
** /**/legt einen neuen Comm an
*/
static
void DoNewComm(void)
{
  if (AGuide.gt_CurDoc->doc_Comms &&
      !AGuide.gt_CurDoc->doc_CurComm &&
      MarkCr!=MarkCr2)
  {
    WORD cr,cr2;
    struct Command *newcom;

    if (MarkCr2>MarkCr)
    {
      cr2=MarkCr2;
      cr=MarkCr;
    }
    else
    {
      cr2=MarkCr;
      cr=MarkCr2;
    }

    if (newcom=InsertComm(AGuide.gt_CurDoc,MarkLn,cr,cr2-cr))
    {
      AGuide.gt_CurDoc->doc_CurComm=newcom;

      OldLn=AktLn;
      OldCol=AktCol;
      PrintTextUD();

      UpdateCommWin();
    }
    else
      EasyRequestAllWins("Error on inserting the new Command",
                         "Ok");
  }
  else
    BeepProgScreen();
}
/**/

/* ========================================================================================= DoDelComm
** /**/legt einen neuen Comm an
*/
static
void DoDelComm(void)
{
  if (AGuide.gt_CurDoc->doc_Comms && AGuide.gt_CurDoc->doc_CurComm)
  {
    if (AGuide.gt_CurDoc->doc_CurComm->com_Node.mln_Succ->mln_Succ)
    {
      AGuide.gt_CurDoc->doc_CurComm=DeleteComm(AGuide.gt_CurDoc->doc_CurComm);

      MarkCr=AGuide.gt_CurDoc->doc_CurComm->com_Char;
      MarkCr2=AGuide.gt_CurDoc->doc_CurComm->com_Char+AGuide.gt_CurDoc->doc_CurComm->com_Len;

      OldLn=AktLn;
      OldCol=AktCol;
      PrintTextUD();
    }
    else
    {
      if (AGuide.gt_CurDoc->doc_CurComm->com_Node.mln_Pred)
      {
        AGuide.gt_CurDoc->doc_CurComm=DeleteComm(AGuide.gt_CurDoc->doc_CurComm);
        AGuide.gt_CurDoc->doc_CurComm=(struct Command *)AGuide.gt_CurDoc->doc_CurComm->com_Node.mln_Pred;

        if (!AGuide.gt_CurDoc->doc_CurComm->com_Node.mln_Pred)
          AGuide.gt_CurDoc->doc_CurComm=NULL;
        else
        {
          MarkCr=AGuide.gt_CurDoc->doc_CurComm->com_Char;
          MarkCr2=AGuide.gt_CurDoc->doc_CurComm->com_Char+AGuide.gt_CurDoc->doc_CurComm->com_Len;
        }

        OldLn=AktLn;
        OldCol=AktCol;
        PrintTextUD();
      }
      else
      {
        AGuide.gt_CurDoc->doc_CurComm=NULL;
        BeepProgScreen();
      }
    }

    UpdateCommWin();
  }
  else
    BeepProgScreen();
}
/**/

/* ================================================================================ HandleEditWinIDCMP
** IDCMP-Message auswerten
*/
void HandleEditWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  LONG  tmp;
  ULONG class,mics,secs;
  UWORD code,qual,mx,my;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleEditWinIDCMP-function --\n");

  /* Message auslesen */
  while (EditWin && (imsg=GT_GetIMsg(EditWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from UserPort\n");

    class=imsg->Class;
    code =imsg->Code;
    qual =imsg->Qualifier;
    mx   =imsg->MouseX;
    my   =imsg->MouseY;
    iaddr=imsg->IAddress;
    mics =imsg->Micros;
    secs =imsg->Seconds;

    switch (class)
    {
      /* muß Window neu gezeichnet werden ? */
      case IDCMP_REFRESHWINDOW:
        GT_BeginRefresh(EditWin);

        SepDat.Width  =EditWin->Width-EditWin->BorderLeft-EditWin->BorderRight-2*INTERWIDTH;
        DrawSeparators(EditWin,&SepDat,1);

        OldLn=AktLn;
        OldCol=AktCol;
        PrintTextUD();

        GT_EndRefresh(EditWin,TRUE);

        DEBUG_PRINTF("  RefreshWindow processed\n");
        break;

      case IDCMP_SIZEVERIFY:
        /* Gadgetliste abhängen */
        RemoveGList(EditWin,GadList,~0);
        GadListRemoved=TRUE;
        DEBUG_PRINTF("  GadList removed from EditWin\n");
        DEBUG_PRINTF("  SizeVerify processed\n");
        break;

      case IDCMP_NEWSIZE:
        if (!GadListRemoved)
        {
          /* Gadgetliste abhängen */
          RemoveGList(EditWin,GadList,~0);
          GadListRemoved=TRUE;
          DEBUG_PRINTF("  GadList removed from EditWin\n");
        }

        /* GadList freigeben */
        FreeGadgets(GadList);
        DEBUG_PRINTF("  GadList freed\n");

        ClearEditWinGads();
        ClearEditWinText();
        DEBUG_PRINTF("  EditWin cleared\n");

        /* Gadgets kreieren */
        if (CreateEditWinGadList())
        {
          DEBUG_PRINTF("  GadList created\n");

          if (AktLn>AGuide.gt_CurDoc->doc_NumLn-VisLn)
          {
            AktLn=AGuide.gt_CurDoc->doc_NumLn-VisLn;
            if (AktLn<0) AktLn=0;
          }

          if (AktCol>AGuide.gt_CurDoc->doc_MaxCol-VisX)
          {
            AktCol=AGuide.gt_CurDoc->doc_MaxCol-VisX;
            if (AktCol<0) AktCol=0;
          }

          SepDat.Width  =EditWin->Width-EditWin->BorderLeft-EditWin->BorderRight-2*INTERWIDTH;
          DrawSeparators(EditWin,&SepDat,1);
          DEBUG_PRINTF("    separators drawn\n");

          PrintX=EditWin->BorderLeft+PRINTIWIDTH;
          PrintY=SepDat.TopEdge+SEPHEIGHT+PRINTIHEIGHT;

          CalcEditWinVisible();

          OldLn=AktLn;
          OldCol=AktCol;
          PrintTextUD();
          DEBUG_PRINTF("    text printed\n");

          UpdateEditWinGads();
          DEBUG_PRINTF("    gadgets set\n");

          /* Gadgetlist anhängen */
          AddGList(EditWin,GadList,~0,~0,NULL);
          GadListRemoved=FALSE;
          DEBUG_PRINTF("  GadList added to EditWin\n");

          /* Window neu aufbauen */
          RefreshGList(GadList,EditWin,NULL,~0);
          GT_RefreshWindow(EditWin,NULL);
          DEBUG_PRINTF("  EditWin and GadList refreshed\n");
        }
        else
          BeepProgScreen();

        DEBUG_PRINTF("  NewSize processed\n");
        break;

      case IDCMP_MOUSEBUTTONS:
        switch (code)
        {
          case SELECTDOWN:
            if (AGuide.gt_CurDoc->doc_Lines &&
                mx>=PrintX && my>=PrintY && mx<=PrintX+VisX && (my-PrintY)/PrintHeight<VisLn)
            {
              struct Command *com,*tstcom;
              LONG i=0;
              WORD j=0;

              MarkLn=AktLn+(my-PrintY)/PrintHeight;
              tmp=AktCol+mx-PrintX;

              com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
              if (com->com_Node.mln_Succ && com->com_Char==0) i+=BUTTONSPACING;

              while(i<tmp && j<=AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Len)
              {
                i+=TextLength(EditWin->RPort,
                              &AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Line[j],1);
                j++;

                if (com->com_Node.mln_Succ)
                {
                  if (com->com_Char+com->com_Len==j)
                  {
                    i+=BUTTONSPACING;
                    com=(struct Command *)com->com_Node.mln_Succ;
                  }

                  if (com->com_Char==j) i+=BUTTONSPACING;
                }
              }

              j--;
              if (j<0) j=0;

              com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
              tstcom=NULL;

              while (com->com_Node.mln_Succ)
              {
                if (j>=com->com_Char && j<com->com_Char+com->com_Len)
                {
                  tstcom=com;
                  break;
                }

                com=(struct Command *)com->com_Node.mln_Succ;
              }

              if (tstcom)
              {
                if (DoubleClick(OldSecs,OldMics,secs,mics) && AGuide.gt_CurDoc->doc_CurComm==tstcom)
                  OpenCommWin();

                AGuide.gt_CurDoc->doc_CurComm=tstcom;

                OldSecs=secs;
                OldMics=mics;

                MarkCr=com->com_Char;
                MarkCr2=com->com_Char+com->com_Len;

                OldLn=AktLn;
                OldCol=AktCol;
                PrintTextUD();
                UpdateCommWin();
              }
              else
              {
                Mark=TRUE;
                MarkCr=j;
                MarkCr2=MarkCr;

                AGuide.gt_CurDoc->doc_CurComm=NULL;
                OldLn=AktLn;
                OldCol=AktCol;
                PrintTextUD();
                UpdateCommWin();
              }
            }

            DEBUG_PRINTF("  SELECTDOWN processed\n");
            break;

          case SELECTUP:
            Mark=FALSE;
            DEBUG_PRINTF("  SELECTUP processed\n");
            break;
        }

        DEBUG_PRINTF("  MouseButtons processed\n");
        break;

      case IDCMP_INTUITICKS:
        if (Mark)
        {
          tmp=mx-PrintX;

          if (tmp>=0 && tmp<=VisX)
          {
            LONG i=0;
            WORD j=0;
            struct Command *com;

            tmp+=AktCol;

            com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
            if (com->com_Node.mln_Succ && com->com_Char==0) i+=BUTTONSPACING;

            while(i<tmp && j<=AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Len)
            {
              i+=TextLength(EditWin->RPort,
                            &AGuide.gt_CurDoc->doc_Lines[MarkLn].al_Line[j],1);
              j++;

              if (com->com_Node.mln_Succ)
              {
                if (com->com_Char+com->com_Len==j)
                {
                  i+=BUTTONSPACING;
                  com=(struct Command *)com->com_Node.mln_Succ;
                }

                if (com->com_Char==j) i+=BUTTONSPACING;
              }
            }

            j--;
            if (j<0) j=0;

            if (MarkCr>j)
            {
              com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
              while (com->com_Node.mln_Succ)
              {
                if (j<com->com_Char+com->com_Len && MarkCr>=com->com_Char+com->com_Len)
                {
                  j=com->com_Char+com->com_Len;
                  break;
                }

                com=(struct Command *)com->com_Node.mln_Succ;
              }
            }
            else
            {
              com=GetCommVecLnHead(AGuide.gt_CurDoc,MarkLn);
              while (com->com_Node.mln_Succ)
              {
                if (MarkCr<com->com_Char && j>com->com_Char)
                {
                  j=com->com_Char;
                  break;
                }

                com=(struct Command *)com->com_Node.mln_Succ;
              }
            }

            if (j!=MarkCr2)
            {
              DrawMarkedText();
              MarkCr2=j;
              DrawMarkedText();
            }
          }
        }

        DEBUG_PRINTF("  Intuiticks processed\n");
        break;

      case IDCMP_IDCMPUPDATE:
      {
        struct TagItem *tag;

        if (tag=FindTagItem(GA_ID,iaddr))
        {
          UBYTE gadnum=tag->ti_Data;

          switch(gadnum)
          {
            case GD_DOWN_BUT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn +=VertScroll;
              if (AktLn>AGuide.gt_CurDoc->doc_NumLn-VisLn) AktLn=AGuide.gt_CurDoc->doc_NumLn-VisLn;
              if (AktLn<0) AktLn=0; /* für NumLn-VisLn<0 */

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case GD_UP_BUT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn -=VertScroll;
              if (AktLn<0) AktLn=0;

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case GD_VERT_SCR:
              /* anders, als bei GD_HORI_SCR muß hier die Funktion
              ** FindTagItem benutzt werden, um PGA_Top zu finden, da
              ** das Code-Field der imsg nur UWORD`s aufnehmen kann, die
              ** Zeilen aber mit ULONG`s verwaltet werden. Bei GD_HORI_SCR
              ** stellt das kein Problem dar, da die Cols bloß als UWORD`s
              ** behandelt werden */
              if (tag=FindTagItem(PGA_Top,iaddr))
              {
                if (tag->ti_Data!=AktLn)
                {
                  OldLn =AktLn;
                  OldCol=AktCol;
                  AktLn =tag->ti_Data;

                  PrintTextUD();
                }
              }

              break;

            case GD_RIGHT_BUT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol+=HorizScroll;
              if (AktCol>AGuide.gt_CurDoc->doc_MaxCol-VisX) AktCol=AGuide.gt_CurDoc->doc_MaxCol-VisX;
              if (AktCol<0) AktCol=0; /* für MaxCol-VisX<0 */

              PrintTextR();
              UpdateEditWinGads();

              break;

            case GD_LEFT_BUT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol-=HorizScroll;

              if (AktCol<0) AktCol=0;

              PrintTextL();
              UpdateEditWinGads();

              break;

            case GD_HORI_SCR:
              if (code!=AktCol)
              {
                OldLn =AktLn;
                OldCol=AktCol;
                AktCol=code;

                if (OldCol>AktCol)
                  PrintTextL();
                else
                  PrintTextR();
              }

              break;
          }
        }

        DEBUG_PRINTF("  IDCMPUpdates processed\n");
        break;

      case IDCMP_RAWKEY:
        if (qual&(IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
        {
          switch(code)
          {
            case CURSORDOWN:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn=AGuide.gt_CurDoc->doc_NumLn-VisLn;
              if (AktLn<0) AktLn=0; /* für NumLn-VisLn<0 */

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case CURSORUP:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn =0;

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case CURSORRIGHT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol=AGuide.gt_CurDoc->doc_MaxCol-VisX;
              if (AktCol<0) AktCol=0; /* für MaxCol-VisX<0 */

              PrintTextR();
              UpdateEditWinGads();

              break;

            case CURSORLEFT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol=0;

              PrintTextL();
              UpdateEditWinGads();

              break;
          }
        }
        else
        {
          switch(code)
          {
            case CURSORDOWN:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn +=VertScroll;
              if (AktLn>AGuide.gt_CurDoc->doc_NumLn-VisLn) AktLn=AGuide.gt_CurDoc->doc_NumLn-VisLn;
              if (AktLn<0) AktLn=0; /* für NumLn-VisLn<0 */

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case CURSORUP:
              OldLn =AktLn;
              OldCol=AktCol;
              AktLn -=VertScroll;
              if (AktLn<0) AktLn=0;

              PrintTextUD();
              UpdateEditWinGads();

              break;

            case CURSORRIGHT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol+=HorizScroll;
              if (AktCol>AGuide.gt_CurDoc->doc_MaxCol-VisX) AktCol=AGuide.gt_CurDoc->doc_MaxCol-VisX;
              if (AktCol<0) AktCol=0; /* für MaxCol-VisX<0 */

              PrintTextR();
              UpdateEditWinGads();

              break;

            case CURSORLEFT:
              OldLn =AktLn;
              OldCol=AktCol;
              AktCol-=HorizScroll;

              if (AktCol<0) AktCol=0;

              PrintTextL();
              UpdateEditWinGads();

              break;
          }
        }

        DEBUG_PRINTF("  RewKeys processed\n");
        break;
      }
    }

    /* antworten */
    GT_ReplyIMsg(imsg);
    DEBUG_PRINTF("  Message replyed\n");

    /* SizeVerify und NewSize _müssen_ noch vor dem Reply bearbeitet werden, damit das Rendering
    ** der Gadgets schnell genug erfolgen kann.
    ** Die anderen Events _müssen_ jedoch erst nach dem Reply abgearbeitet werden, da z.b. bei
    ** CloseEditWin das Window freigegeben wird und deshalb das Reply an einen Port ginge, der
    ** gar nicht mehr existiert! */
    switch (class)
    {
      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetEditWinSize();
        CloseEditWin();
        WinPosP.EditWin=FALSE;
        SetProgMenusStates();
        DEBUG_PRINTF("  EditWin closed\n");

        break;

      /* Menu angewählt? */
      case IDCMP_MENUPICK:
        HandleProgMenus(code);
        DEBUG_PRINTF("  Menus handled\n");
        break;

      case IDCMP_GADGETUP:
        switch (((struct Gadget *)iaddr)->GadgetID)
        {
          case GD_NEW_BUT:
            DoNewComm();
            DEBUG_PRINTF("  GD_NEW_BUT processed\n");
            break;

          case GD_DEL_BUT:
            DoDelComm();
            DEBUG_PRINTF("  GD_DEL_BUT processed\n");
            break;

          case GD_EDITCOMM_BUT:
            OpenCommWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_EDITCOMM_BUT processed\n");
            break;

          case GD_EDITTEXT_BUT:
            DoEditASCIIText();
            DEBUG_PRINTF("  GD_EDITTEXT_BUT processed\n");
            break;

          case GD_LOADTEXT_BUT:
            if (LoadASCIIText(AGuide.gt_CurDoc,AGuide.gt_CurDoc->doc_FileName))
            {
              CalcMaxCol();
              UpdateEditWin();
            }

            DEBUG_PRINTF("  GD_LOADTEXT_BUT processed\n");
            break;

          case GD_FLUSHTEXT_BUT:
            FreeASCIIText(AGuide.gt_CurDoc);
            UpdateEditWin();
            DEBUG_PRINTF("  GD_FLUSHTEXT_BUT processed\n");
            break;
        }

        DEBUG_PRINTF("  GadgetUps processed\n");
        break;

      /* VanillaKey? */
      case IDCMP_VANILLAKEY:
        switch(MatchVanillaKey(code,VanKeys))
        {
          case KEY_NEW:
            DoNewComm();
            DEBUG_PRINTF("  KEY_NEW processed\n");
            break;

          case KEY_DEL:
            DoDelComm();
            DEBUG_PRINTF("  KEY_DEL processed\n");
            break;

          case KEY_EDITCOMM:
            OpenCommWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_EDITCOMM processed\n");
            break;

          case KEY_EDITTEXT:
            DoEditASCIIText();
            DEBUG_PRINTF("  KEY_EDITTEXT processed\n");
            break;

          case KEY_LOADTEXT:
            if (LoadASCIIText(AGuide.gt_CurDoc,AGuide.gt_CurDoc->doc_FileName))
            {
              CalcMaxCol();
              UpdateEditWin();
            }

            DEBUG_PRINTF("  KEY_LOADTEXT processed\n");
            break;

          case KEY_FLUSHTEXT:
            FreeASCIIText(AGuide.gt_CurDoc);
            UpdateEditWin();
            DEBUG_PRINTF("  KEY_FLUSHTEXT processed\n");
            break;
        }

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
    }
  }

  /* Programm beendet? */
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
