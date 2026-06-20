/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     DocsSetWin.c
** FUNKTION:  DocsSettingsWindow für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window     *DocsSetWin=NULL;
       ULONG              DocsSetBit=0;

static UWORD              Width,Height;
static WORD               WZoom[4];

static struct TagItem     NodeNameTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem     WinTitleTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem     NextNodeTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem     PrevNodeTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

static struct TagItem     TOCNodeTags[]={GTST_String,NULL,
                                         GTST_MaxChars,STRMAXCHARS,
                                         TAG_DONE};

static struct TagItem     FileNameTags[]={GTST_String,NULL,
                                          GTST_MaxChars,STRMAXCHARS,
                                          TAG_DONE};

/* GADGETS */
/* erste Spalte */
#define GD_NODENAME_STR      0
#define GD_WINTITLE_STR      1
#define GD_NEXTNODE_STR      2
#define GD_PREVNODE_STR      3
#define GD_TOCNODE_STR       4
#define GD_FILENAME_STR      5
#define GD_FILENAME_SEL      6
#define GD_USE_BUT           7
#define GD_CANCEL_BUT        8
#define GDNUM                9

static struct GadgetData  GadDat[GDNUM];
static struct Gadget     *GadList;
static struct SepData     SepD;

/* VANILLAKEYS */
#define KEY_NODENAME          0
#define KEY_WINTITLE          1
#define KEY_NEXTNODE          2
#define KEY_PREVNODE          3
#define KEY_TOCNODE           4
#define KEY_FILENAME_LWR      5
#define KEY_FILENAME_UPR      6
#define KEY_USE               7
#define KEY_CANCEL            8
#define KEY_NULL              9
#define KEYNUM               10

static char               VanKeys[KEYNUM];

static void SetStrGad(UBYTE,char *);
static void DoPathSelect(UBYTE);
static void ActGad(UBYTE);

/* ==================================================================================== InitDocsSetWin
** fordert alle wichtigen Resourcen für das DocsSetWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitDocsSetWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,selw,labw,butw,strw,selstrw,left,lableft;
  UWORD top,gadh,yadd;

  DEBUG_PRINTF("\n  -- Invoking InitDocsSetWin-Function --\n");

  /* Gadgetlabels initialisieren */
  /* StringGadgets und Select-Buttons */
  GadDat[GD_NODENAME_STR].GadgetText    ="_NodeName";
  GadDat[GD_WINTITLE_STR].GadgetText    ="_WinTitle";
  GadDat[GD_NEXTNODE_STR].GadgetText    ="Ne_xtNode";
  GadDat[GD_PREVNODE_STR].GadgetText    ="_PrevNode";
  GadDat[GD_TOCNODE_STR].GadgetText     ="_TOCNode";
  GadDat[GD_FILENAME_STR].GadgetText    ="_FileName";

  GadDat[GD_FILENAME_SEL].GadgetText    ="Sel";

  /* Buttons */
  GadDat[GD_USE_BUT].GadgetText         ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText      ="_Cancel";

  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  /* Breite des Select-Buttons ermitteln */
  selw=TextLength(&Screen.ps_DummyRPort,
                  "Sel",strlen("Sel"))+INTERWIDTH;
  DEBUG_PRINTF("  selw calculated\n");

  /* breitestes Gadgetlabel ermitteln */
  labw=0;
  for (i=GD_NODENAME_STR;i<=GD_FILENAME_STR;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText));

    if (labw<tmp) labw=tmp;
  }
  labw+=INTERWIDTH;
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

  /* Größen der Gadgets berechnen */
  strw=Screen.ps_ScrFont->tf_XSize*20;
  DEBUG_PRINTF("  strw calculated\n");

  if (2*butw+INTERWIDTH>labw+strw)
    strw=2*butw+INTERWIDTH-labw;

  selstrw=strw-selw;
  left   =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  lableft=left+labw;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.DocsSetWTop==~0) AGDPrefsP.DocsSetWTop =Screen.ps_Screen->BarHeight+1;
  Width =labw+strw+2*INTERWIDTH;
  Height=7*yadd+2*INTERHEIGHT+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.DocsSetWLeft;
  WZoom[1]=AGDPrefsP.DocsSetWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1+INTERHEIGHT;

  /* NodeName-String-Gadget */
  gd=&GadDat[GD_NODENAME_STR];
  gd->LeftEdge=lableft;
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
  gd->LeftEdge=lableft;
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
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_NEXTNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =NextNodeTags;

  top+=yadd;

  /* PrevNode-String-Gadget */
  gd=&GadDat[GD_PREVNODE_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_PREVNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =PrevNodeTags;

  top+=yadd;

  /* TOCNode-String-Gadget */
  gd=&GadDat[GD_TOCNODE_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =strw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_TOCNODE_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =TOCNodeTags;

  top+=yadd;

  /* FileName-String-Gadget */
  gd=&GadDat[GD_FILENAME_STR];
  gd->LeftEdge=lableft;
  gd->TopEdge =top;
  gd->Width   =selstrw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_LEFT;
  gd->GadgetID=GD_FILENAME_STR;
  gd->Type    =STRING_KIND;
  gd->Tags    =FileNameTags;

  /* FileName-Sel-Gadget */
  gd=&GadDat[GD_FILENAME_SEL];
  gd->LeftEdge=lableft+GadDat[GD_FILENAME_STR].Width;
  gd->TopEdge =top;
  gd->Width   =selw;
  gd->Height  =gadh;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_FILENAME_SEL;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

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
  VanKeys[KEY_NODENAME]    =FindVanillaKey(GadDat[GD_NODENAME_STR].GadgetText);
  VanKeys[KEY_WINTITLE]    =FindVanillaKey(GadDat[GD_WINTITLE_STR].GadgetText);
  VanKeys[KEY_NEXTNODE]    =FindVanillaKey(GadDat[GD_NEXTNODE_STR].GadgetText);
  VanKeys[KEY_PREVNODE]    =FindVanillaKey(GadDat[GD_PREVNODE_STR].GadgetText);
  VanKeys[KEY_TOCNODE]     =FindVanillaKey(GadDat[GD_TOCNODE_STR].GadgetText);
  VanKeys[KEY_FILENAME_LWR]=FindVanillaKey(GadDat[GD_FILENAME_STR].GadgetText);
  VanKeys[KEY_FILENAME_UPR]=toupper(VanKeys[KEY_FILENAME_LWR]);
  VanKeys[KEY_USE]         =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL]      =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CloseDocsSetWin
** schließt das DocsWinSettings-Fenster
*/
void CloseDocsSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseDocsSetWin-function --\n");

  if (DocsSetWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(DocsSetWin);
    DEBUG_PRINTF("  MenuStrip at DocsSetWin cleared\n");

    /* Window schließen */
    CloseWindow(DocsSetWin);
    DocsSetWin =NULL;
    DocsSetBit=0;
    DEBUG_PRINTF("  DocsSetWin closed\n");

    /* Gadgets freigeben */
    FreeGadgets(GadList);
    DEBUG_PRINTF("  GadList freed\n");
  }

  AGDPrefsP.DocsSetWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== OpenDocsSetWin
** öffnet das DocsWinSettings-Fenster
*/
BOOL OpenDocsSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenDocsSetWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!DocsSetWin)
  {
    NodeNameTags[0].ti_Data=(ULONG)DocsP.NodeName;
    WinTitleTags[0].ti_Data=(ULONG)DocsP.WinTitle;
    NextNodeTags[0].ti_Data=(ULONG)DocsP.NextNodeName;
    PrevNodeTags[0].ti_Data=(ULONG)DocsP.PrevNodeName;
    TOCNodeTags[0].ti_Data =(ULONG)DocsP.TOCNodeName;
    FileNameTags[0].ti_Data=(ULONG)DocsP.FileName;

    if (GadList=
        CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (DocsSetWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.DocsSetWLeft,
                         WA_Top,AGDPrefsP.DocsSetWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,"Documents Editor Settings",
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
        DEBUG_PRINTF("  DocsSetWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(DocsSetWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at DocsSetWin\n");

        /* Window neu aufbauen */
        GT_RefreshWindow(DocsSetWin,NULL);
        DrawSeparators(DocsSetWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        DocsSetBit=1UL<<DocsSetWin->UserPort->mp_SigBit;
        AGDPrefsP.DocsSetWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening the Documents\n"
                           "Editor Settings Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "the Documents Editor Settings Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseDocsSetWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(DocsSetWin);
    WindowToFront(DocsSetWin);
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(TRUE);
}

/* ================================================================================== GetDocsSetWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetDocsSetWinPos(void)
{
  if (DocsSetWin)
  {
    AGDPrefsP.DocsSetWLeft=DocsSetWin->LeftEdge;
    AGDPrefsP.DocsSetWTop =DocsSetWin->TopEdge;
  }
}

/* ================================================================================== UpdateDocsSetWin
** updated das DocsSetWin
*/
void UpdateDocsSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking UpdateDocsSetWin-function --\n");

  if (DocsSetWin)
  {
    DEBUG_PRINTF("  DocsSetWin opened\n");

    SetStrGad(GD_NODENAME_STR,DocsP.NodeName);
    SetStrGad(GD_WINTITLE_STR,DocsP.WinTitle);
    SetStrGad(GD_NEXTNODE_STR,DocsP.NextNodeName);
    SetStrGad(GD_PREVNODE_STR,DocsP.PrevNodeName);
    SetStrGad(GD_TOCNODE_STR,DocsP.TOCNodeName);
    SetStrGad(GD_FILENAME_STR,DocsP.FileName);

    DEBUG_PRINTF("  gadgets set\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ==================================================================================== CopyDocsSetWin
** kopiert die Gadgets im DocsSetWin
*/
void CopyDocsSetWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CopyDocsSetWin-function --\n");

  if (DocsSetWin)
  {
    DEBUG_PRINTF("  DocsSetWin opened\n");

    DoStringCopy(&DocsP.NodeName,GadDat[GD_NODENAME_STR].Gadget);
    DoStringCopy(&DocsP.WinTitle,GadDat[GD_WINTITLE_STR].Gadget);
    DoStringCopy(&DocsP.NextNodeName,GadDat[GD_NEXTNODE_STR].Gadget);
    DoStringCopy(&DocsP.PrevNodeName,GadDat[GD_PREVNODE_STR].Gadget);
    DoStringCopy(&DocsP.TOCNodeName,GadDat[GD_TOCNODE_STR].Gadget);
    DoStringCopy(&DocsP.FileName,GadDat[GD_FILENAME_STR].Gadget);

    DEBUG_PRINTF("  gadgets copied\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}
  
/* ============================================================================================ ActGad
** aktiviert ein String-Gadget im DocsSetWin
*/
static
void ActGad(UBYTE gdnum)
{
  ActivateGadget(GadDat[gdnum].Gadget,DocsSetWin,NULL);
}
  
/* ========================================================================================= SetStrGad
** setzt ein String-Gadget im DocsSetWin
*/
static
void SetStrGad(UBYTE gdnum,char *str)
{
  GT_SetGadgetAttrs(GadDat[gdnum].Gadget,
                    DocsSetWin,NULL,
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

/* ============================================================================= HandleDocsSetWinIDCMP
** IDCMP-Message auswerten
*/
void HandleDocsSetWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  struct Gadget *gad;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleDocsSetWinIDCMP-function --\n");

  /* Message auslesen */
  while (DocsSetWin && (imsg=GT_GetIMsg(DocsSetWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from DocsSetWin->UserPort\n");

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
        GT_BeginRefresh(DocsSetWin);
        DrawSeparators(DocsSetWin,&SepD,1);
        GT_EndRefresh(DocsSetWin,TRUE);
        DEBUG_PRINTF("  DocsSetWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetDocsSetWinPos();
        CloseDocsSetWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  DocsSetWin closed\n");

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
          case GD_FILENAME_SEL:
            DoPathSelect(GD_FILENAME_STR);
            DEBUG_PRINTF("  GD_FILENAME_SEL processed\n");
            break;

          case GD_USE_BUT:
            CopyDocsSetWin();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          case GD_CANCEL_BUT:
            if (AGDPrefsP.ReqMode)
            {
              GetDocsSetWinPos();
              CloseDocsSetWin();
              SetProgMenusStates();
            }
            else
              UpdateDocsSetWin();

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
          case KEY_NODENAME:
            ActGad(GD_NODENAME_STR);
            DEBUG_PRINTF("  KEY_NODENAME processed\n");
            break;

          case KEY_WINTITLE:
            ActGad(GD_WINTITLE_STR);
            DEBUG_PRINTF("  KEY_WINTITLE processed\n");
            break;

          case KEY_NEXTNODE:
            ActGad(GD_NEXTNODE_STR);
            DEBUG_PRINTF("  KEY_NEXTNODE processed\n");
            break;

          case KEY_PREVNODE:
            ActGad(GD_PREVNODE_STR);
            DEBUG_PRINTF("  KEY_PREVNODE processed\n");
            break;

          case KEY_TOCNODE:
            ActGad(GD_TOCNODE_STR);
            DEBUG_PRINTF("  KEY_TOCNODE processed\n");
            break;

          case KEY_FILENAME_LWR:
            ActGad(GD_FILENAME_STR);
            DEBUG_PRINTF("  KEY_FILENAME_LWR processed\n");
            break;

          case KEY_FILENAME_UPR:
            DoPathSelect(GD_FILENAME_STR);
            DEBUG_PRINTF("  KEY_FILENAME_UPR processed\n");
            break;

          case KEY_USE:
            CopyDocsSetWin();
            DEBUG_PRINTF("  KEY_USE processed\n");

          case KEY_CANCEL:
            if (AGDPrefsP.ReqMode)
            {
              GetDocsSetWinPos();
              CloseDocsSetWin();
              SetProgMenusStates();
            }
            else
              UpdateDocsSetWin();

            DEBUG_PRINTF("  KEY_CANCEL processed\n");
            break;
        }

        DEBUG_PRINTF("  VanillaKeys processed\n");
        break;
      }
    }
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
