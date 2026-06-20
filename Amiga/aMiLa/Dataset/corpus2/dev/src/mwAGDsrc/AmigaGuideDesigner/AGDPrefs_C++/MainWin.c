/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     MainWin.c
** FUNKTION:  MainWindow für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

       struct Window     *MainWin=NULL;
       ULONG              MainBit=0;

static UWORD              Width,Height;
static WORD               WZoom[4];

/* GADGETS */
/* erste Spalte */
#define GD_PROJSET_BUT     0
#define GD_DOCSSET_BUT     1
#define GD_COMMSET_BUT     2
#define GD_MISCSET_BUT     3
#define GD_SCRSET_BUT      4
#define GD_SAVE_BUT        5
#define GD_USE_BUT         6
#define GD_CANCEL_BUT      7
#define GDNUM              8

static struct GadgetData  GadDat[GDNUM];
static struct Gadget     *GadList;
static struct SepData     SepD;

/* VANILLAKEYS */
#define KEY_PROJSET         0
#define KEY_DOCSSET         1
#define KEY_COMMSET         2
#define KEY_MISCSET         3
#define KEY_SCRSET          4
#define KEY_SAVE            5
#define KEY_USE             6
#define KEY_CANCEL          7
#define KEY_NULL            8
#define KEYNUM              9

static char               VanKeys[KEYNUM];

/* ==================================================================================== InitMainWin
** fordert alle wichtigen Resourcen für das MainWin an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitMainWin(void)
{
  struct GadgetData *gd;
  ULONG i;
  UWORD tmp,butw,butw2;
  UWORD left,top,gadh,yadd;

  DEBUG_PRINTF("\n  -- Invoking InitMainWin-Function --\n");

  /* Gadgetlabels initialisieren */
  GadDat[GD_PROJSET_BUT].GadgetText     ="_Project Settings...";
  GadDat[GD_DOCSSET_BUT].GadgetText     ="_Documents Settings...";
  GadDat[GD_COMMSET_BUT].GadgetText     ="C_ommands Settings...";
  GadDat[GD_MISCSET_BUT].GadgetText     ="_Miscellaneous Settings...";
  GadDat[GD_SCRSET_BUT].GadgetText      ="Sc_reen Settings...";
  GadDat[GD_SAVE_BUT].GadgetText        ="_Save";
  GadDat[GD_USE_BUT].GadgetText         ="_Use";
  GadDat[GD_CANCEL_BUT].GadgetText      ="_Cancel";
  DEBUG_PRINTF("  Gadget-Labels initialized\n");

  butw=0;
  for (i=GD_PROJSET_BUT;i<=GD_SCRSET_BUT;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText))+INTERWIDTH;

    if (butw<tmp) butw=tmp;
  }
  butw+=INTERWIDTH;
  DEBUG_PRINTF("  butw calculated\n");

  butw2=0;
  for (i=GD_SAVE_BUT;i<=GD_CANCEL_BUT;i++)
  {
    tmp=TextLength(&Screen.ps_DummyRPort,
                   GadDat[i].GadgetText,
                   strlen(GadDat[i].GadgetText))+INTERWIDTH;

    if (butw2<tmp) butw2=tmp;
  }
  butw2+=3*INTERWIDTH;
  DEBUG_PRINTF("  butw2 calculated\n");

  if (3*butw2+2*INTERWIDTH>2*butw+INTERWIDTH)
    butw=(3*butw2+INTERWIDTH)/2;

  left   =Screen.ps_Screen->WBorLeft+INTERWIDTH;
  gadh   =Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  yadd   =gadh+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  if (AGDPrefsP.MainWTop==~0) AGDPrefsP.MainWTop=Screen.ps_Screen->BarHeight+1;
  Width =2*butw+3*INTERWIDTH;
  Height=4*yadd+(5*INTERHEIGHT)/2+SEPHEIGHT;

  /* alternative Windowgröße */
  WZoom[0]=AGDPrefsP.MainWLeft;
  WZoom[1]=AGDPrefsP.MainWTop;
  WZoom[2]=200;
  WZoom[3]=Screen.ps_WBorTop;
  DEBUG_PRINTF("  Window-Sizes calculated\n");

  top=Screen.ps_WBorTop+INTERHEIGHT;

  for (i=GD_PROJSET_BUT;i<=GD_COMMSET_BUT;i++)
  {
    GadDat[i].LeftEdge=left;
    GadDat[i].TopEdge =top;
    GadDat[i].Width   =butw;
    GadDat[i].Height  =gadh;
    GadDat[i].Flags   =PLACETEXT_IN;
    GadDat[i].GadgetID=i;
    GadDat[i].Type    =BUTTON_KIND;
    GadDat[i].Tags    =NULL;

    top+=yadd;
  }

  top=Screen.ps_WBorTop+INTERHEIGHT;

  for (i=GD_MISCSET_BUT;i<=GD_SCRSET_BUT;i++)
  {
    GadDat[i].LeftEdge=left+butw+INTERWIDTH;
    GadDat[i].TopEdge =top;
    GadDat[i].Width   =butw;
    GadDat[i].Height  =gadh;
    GadDat[i].Flags   =PLACETEXT_IN;
    GadDat[i].GadgetID=i;
    GadDat[i].Type    =BUTTON_KIND;
    GadDat[i].Tags    =NULL;

    top+=yadd;
  }

  top+=yadd;

  SepD.LeftEdge=left;
  SepD.TopEdge =top;
  SepD.Width   =2*butw+INTERWIDTH;

  top+=SEPHEIGHT+INTERHEIGHT;

  /* Save-Button-Gadget */
  gd=&GadDat[GD_SAVE_BUT];
  gd->LeftEdge=left;
  gd->TopEdge =top;
  gd->Width   =butw2;
  gd->Height  =gadh+INTERHEIGHT/2;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_SAVE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Use-Button-Gadget */
  gd=&GadDat[GD_USE_BUT];
  gd->LeftEdge=left+(Width-butw2)/2-INTERWIDTH;
  gd->TopEdge =top;
  gd->Width   =butw2;
  gd->Height  =gadh+INTERHEIGHT/2;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_USE_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  /* Cancel-Button-Gadget */
  gd=&GadDat[GD_CANCEL_BUT];
  gd->LeftEdge=left+Width-2*INTERWIDTH-butw2;
  gd->TopEdge =top;
  gd->Width   =butw2;
  gd->Height  =gadh+INTERHEIGHT/2;
  gd->Flags   =PLACETEXT_IN;
  gd->GadgetID=GD_CANCEL_BUT;
  gd->Type    =BUTTON_KIND;
  gd->Tags    =NULL;

  DEBUG_PRINTF("  Gadgets initialized\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_PROJSET]=FindVanillaKey(GadDat[GD_PROJSET_BUT].GadgetText);
  VanKeys[KEY_DOCSSET]=FindVanillaKey(GadDat[GD_DOCSSET_BUT].GadgetText);
  VanKeys[KEY_COMMSET]=FindVanillaKey(GadDat[GD_COMMSET_BUT].GadgetText);
  VanKeys[KEY_MISCSET]=FindVanillaKey(GadDat[GD_MISCSET_BUT].GadgetText);
  VanKeys[KEY_SCRSET] =FindVanillaKey(GadDat[GD_SCRSET_BUT].GadgetText);
  VanKeys[KEY_SAVE]   =FindVanillaKey(GadDat[GD_SAVE_BUT].GadgetText);
  VanKeys[KEY_USE]    =FindVanillaKey(GadDat[GD_USE_BUT].GadgetText);
  VanKeys[KEY_CANCEL] =FindVanillaKey(GadDat[GD_CANCEL_BUT].GadgetText);
  VanKeys[KEY_NULL]   ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");
  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CloseMainWin
** schließt das ProjectSettings-Fenster
*/
void CloseMainWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking CloseMainWin-function --\n");

  if (MainWin)
  {
    /* MenuStrip löschen */
    ClearMenuStrip(MainWin);
    DEBUG_PRINTF("  MenuStrip at MainWin cleared\n");

    /* Window schließen */
    CloseWindow(MainWin);
    MainWin=NULL;
    MainBit=0;
    DEBUG_PRINTF("  MainWin closed\n");

    /* Gadgets freigeben */
    FreeGadgets(GadList);
    DEBUG_PRINTF("  GadList freed\n");
  }

  AGDPrefsP.MainWin=FALSE;

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ==================================================================================== OpenMainWin
** öffnet das ProjectSettings-Fenster
*/
BOOL OpenMainWin(void)
{
  DEBUG_PRINTF("\n  -- Invoking OpenMainWin-function --\n");

  /* wenn noch nicht offen (könnte mehrmals aufgerufen werden) */
  if (!MainWin)
  {
    if (GadList=
        CreateGadgetList(GadDat,GDNUM))
    {
      DEBUG_PRINTF("  GadList created\n");

      /* Window öffnen */
      if (MainWin=
          OpenWindowTags(NULL,
                         WA_Left,AGDPrefsP.MainWLeft,
                         WA_Top,AGDPrefsP.MainWTop,
                         WA_InnerWidth,Width,
                         WA_InnerHeight,Height,
                         WA_Title,PROGNAME,
                         WA_ScreenTitle,Screen.ps_Title,
                         WA_Gadgets,GadList,
                         WA_IDCMP,BUTTONIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|\
                                  IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY,
                         WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                                  WFLG_NEWLOOKMENUS|WFLG_ACTIVATE,
                         WA_AutoAdjust,TRUE,
                         WA_Zoom,WZoom,
                         WA_PubScreen,Screen.ps_Screen,
                         TAG_DONE))
      {
        DEBUG_PRINTF("  MainWin opened\n");

        /* MenuStrip ans Window anhängen */
        SetMenuStrip(MainWin,Menus);
        DEBUG_PRINTF("  MenuStrip set at MainWin\n");

        /* Window neu aufbauen */
        GT_RefreshWindow(MainWin,NULL);
        DrawSeparators(MainWin,&SepD,1);
        DEBUG_PRINTF("  GadList refreshed\n");

        MainBit=1UL<<MainWin->UserPort->mp_SigBit;
        AGDPrefsP.MainWin=TRUE;

        ProgScreenToFront();

        /* Ok zurückgeben */
        DEBUG_PRINTF("  -- returning --\n\n");
        return(TRUE);
      }
      else
        EasyRequestAllWins("Error on opening the\n"
                           PROGNAME "Window",
                           "Ok",
                           NULL);
    }
    else
      EasyRequestAllWins("Error on creating gadgets for\n"
                         "the " PROGNAME " Window",
                         "Ok",
                         NULL);

    DEBUG_PRINTF("  Error\n");
    CloseMainWin();

    DEBUG_PRINTF("  -- returning --\n\n");
    return(FALSE);
  }
  else
  {
    ActivateWindow(MainWin);
    WindowToFront(MainWin);
  }

  DEBUG_PRINTF("  -- returning --\n\n");
  return(TRUE);
}

/* ================================================================================== GetMainWinPos
** speichert die aktuelle Windowposition in der WinPosP-Struktur ab
*/
void GetMainWinPos(void)
{
  if (MainWin)
  {
    AGDPrefsP.MainWLeft=MainWin->LeftEdge;
    AGDPrefsP.MainWTop =MainWin->TopEdge;
  }
}

/* ============================================================================= HandleMainWinIDCMP
** IDCMP-Message auswerten
*/
void HandleMainWinIDCMP(void)
{
  struct IntuiMessage *imsg;
  ULONG class;
  UWORD code;
  APTR  iaddr;

  DEBUG_PRINTF("\n  -- Invoking HandleMainWinIDCMP-function --\n");

  /* Message auslesen */
  while (MainWin && (imsg=GT_GetIMsg(MainWin->UserPort)))
  {
    DEBUG_PRINTF("  Got Message from MainWin->UserPort\n");

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
        GT_BeginRefresh(MainWin);
        DrawSeparators(MainWin,&SepD,1);
        GT_EndRefresh(MainWin,TRUE);
        DEBUG_PRINTF("  MainWin refreshed\n");
        break;

      /* Window geschlossen? */
      case IDCMP_CLOSEWINDOW:
        GetMainWinPos();
        CloseMainWin();
        SetProgMenusStates();
        DEBUG_PRINTF("  MainWin closed\n");

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
          /* ProjSet */
          case GD_PROJSET_BUT:
            OpenProjSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_PROJSET_BUT processed\n");
            break;

          /* DocsSet */
          case GD_DOCSSET_BUT:
            OpenDocsSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_DOCSSET_BUT processed\n");
            break;

          /* CommSet */
          case GD_COMMSET_BUT:
            OpenCommSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_COMMSET_BUT processed\n");
            break;

          /* MiscSet */
          case GD_MISCSET_BUT:
            OpenMiscSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_MISCSET_BUT processed\n");
            break;

          /* ScrSet */
          case GD_SCRSET_BUT:
            OpenScrSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  GD_SCRSET_BUT processed\n");
            break;

          /* Save */
          case GD_SAVE_BUT:
            if (!SavePrefs(PrefsNameEnvArc)) BeepProgScreen();
            DEBUG_PRINTF("  GD_SAVE_BUT processed\n");

          /* Use */
          case GD_USE_BUT:
            if (!SavePrefs(PrefsNameEnv)) BeepProgScreen();
            CloseAllWindows();
            DEBUG_PRINTF("  GD_USE_BUT processed\n");

          /* Cancel */
          case GD_CANCEL_BUT:
            CloseAllWindows();
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
          /* ProjSet */
          case KEY_PROJSET:
            OpenProjSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_PROJSET processed\n");
            break;

          /* DocsSet */
          case KEY_DOCSSET:
            OpenDocsSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_DOCSSET processed\n");
            break;

          /* CommSet */
          case KEY_COMMSET:
            OpenCommSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_COMMSET processed\n");
            break;

          /* MiscSet */
          case KEY_MISCSET:
            OpenMiscSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_MISCSET processed\n");
            break;

          /* ScrSet */
          case KEY_SCRSET:
            OpenScrSetWin();
            SetProgMenusStates();
            DEBUG_PRINTF("  KEY_SCRSET processed\n");
            break;

          /* Save */
          case KEY_SAVE:
            if (!SavePrefs(PrefsNameEnvArc)) BeepProgScreen();
            DEBUG_PRINTF("  KEY_SAVE processed\n");

          /* Use */
          case KEY_USE:
            if (!SavePrefs(PrefsNameEnv)) BeepProgScreen();
            CloseAllWindows();
            DEBUG_PRINTF("  KEY_USE processed\n");

          /* Cancel */
          case KEY_CANCEL:
            CloseAllWindows();
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
