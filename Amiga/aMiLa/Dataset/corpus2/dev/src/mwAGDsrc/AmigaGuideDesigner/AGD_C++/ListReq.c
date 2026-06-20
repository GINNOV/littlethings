/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ListReq.c
** FUNKTION:  ListReq-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

static struct Window       *ListWin;

static UWORD                MinWidth,MinHeight;

/* GADGETS */
/* erste Spalte */
#define GD_LIST_LST         0
#define GD_OK_BUT           1
#define GD_CANCEL_BUT       2
#define GDNUM               3

static struct Gadget       *GadList;
static struct Gadget       *List;
static BOOL                 GadListRemoved=TRUE;

/* VANILLAKEYS */
#define KEY_OK              0
#define KEY_CANCEL          1
#define KEY_NULL            2
#define KEYNUM              3

static char                 VanKeys[KEYNUM];

#define QUIT_NOTQUIT        0
#define QUIT_OK             1
#define QUIT_CANCEL         2

static UWORD ButW,GadH;

/* ======================================================================================= InitListReq
** fordert alle wichtigen Resourcen für den ListReq an, damit später nur noch
** schnell das Window geöffnet werden muß
*/
void InitListReq(void)
{
  UWORD tmp;

  DEBUG_PRINTF("\n  -- Invoking InitListReq-Function --\n");

  /* Breite der Boden-Buttons ermitteln */
  ButW=TextLength(&Screen.ps_DummyRPort,
                  "_Ok",
                  strlen("_Ok"));

  tmp=TextLength(&Screen.ps_DummyRPort,
                 "_Cancel",
                 strlen("_Cancel"));

  if (ButW<tmp) ButW=tmp;

  ButW+=2*INTERWIDTH;
  GadH=Screen.ps_ScrFont->tf_YSize+INTERHEIGHT;
  DEBUG_PRINTF("  gad-variables calculated\n");

  /* Windowgröße */
  MinWidth =Screen.ps_Screen->WBorLeft+Screen.ps_Screen->WBorRight+2*ButW+3*INTERWIDTH;
  MinHeight=Screen.ps_WBorTop+Screen.ps_Screen->WBorBottom+3*INTERHEIGHT+5*GadH;
  DEBUG_PRINTF("  Window-Size calculated\n");

  /* VanillaKeys ermittlen */
  VanKeys[KEY_OK]    =FindVanillaKey("_Ok");
  VanKeys[KEY_CANCEL]=FindVanillaKey("_Cancel");
  VanKeys[KEY_NULL]  ='\0';

  DEBUG_PRINTF("  VanillaKeys calculated\n");

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ================================================================================= CreateListReqGads
** legt die Gadgets für das Window (so schnell wie möglich) an
*/
static
struct Gadget *CreateListReqGads(struct List *list,LONG akt)
{
  struct Gadget *gad,*gadlist;
  struct NewGadget ng;

  DEBUG_PRINTF("\n    -- Invoking CreateListReqGads-function --\n");

  gad=CreateContext(&gadlist);

  /* List-ListView-Gadget */
  ng.ng_LeftEdge  =ListWin->BorderLeft+INTERWIDTH;
  ng.ng_TopEdge   =ListWin->BorderTop+INTERHEIGHT;
  ng.ng_Width     =ListWin->Width-ListWin->BorderLeft-ListWin->BorderRight-2*INTERWIDTH;
  ng.ng_Height    =ListWin->Height-ListWin->BorderTop-ListWin->BorderBottom-3*INTERHEIGHT-GadH;
  ng.ng_GadgetText=NULL;
  ng.ng_TextAttr  =&ScrP.ScrAttr;
  ng.ng_GadgetID  =GD_LIST_LST;
  ng.ng_Flags     =0;
  ng.ng_VisualInfo=Screen.ps_VisualInfo;
  ng.ng_UserData  =0;

  List=gad=CreateGadget(LISTVIEW_KIND,gad,&ng,
                        GTLV_Labels,(ULONG)list,
                        GTLV_ShowSelected,NULL,
                        GTLV_Selected,akt,
                        TAG_DONE);

  /* Ok-Button-Gadget */
  ng.ng_TopEdge   =ng.ng_TopEdge+ng.ng_Height+INTERHEIGHT;
  ng.ng_Width     =(ng.ng_Width-INTERWIDTH)/2;
  ng.ng_Height    =GadH;
  ng.ng_GadgetText="_Ok";
  ng.ng_GadgetID  =GD_OK_BUT;
  ng.ng_Flags     =PLACETEXT_IN;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  /* Cancel-Button-Gadget */
  ng.ng_LeftEdge  =ng.ng_LeftEdge+ng.ng_Width+INTERWIDTH;
  ng.ng_GadgetText="_Cancel";
  ng.ng_GadgetID  =GD_CANCEL_BUT;

  gad=CreateGadgetA(BUTTON_KIND,gad,&ng,UnderscoreTags);

  DEBUG_PRINTF("    error - freeing everything\n");
  if (!gad)
  {
    FreeGadgets(gadlist);
    gadlist=0;
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(gadlist);
}

/* ======================================================================================= OpenListReq
** öffnet den ListReq
*/
LONG OpenListReq(struct List *labels,LONG akt,char *wintitle)
{
  DEBUG_PRINTF("\n  -- Invoking OpenListReq-function --\n");

  if (WinPosP.ListRWidth<MinWidth) WinPosP.ListRWidth=MinWidth;
  if (WinPosP.ListRHeight<MinHeight) WinPosP.ListRHeight=MinHeight;

  /* Window öffnen */
  if (ListWin=
      OpenWindowTags(NULL,
                     WA_Left,WinPosP.ListRLeft,
                     WA_Top,WinPosP.ListRTop,
                     WA_Width,WinPosP.ListRWidth,
                     WA_Height,WinPosP.ListRHeight,
                     WA_MinWidth,MinWidth,
                     WA_MinHeight,MinHeight,
                     WA_MaxWidth,~0,
                     WA_MaxHeight,~0,
                     WA_Title,wintitle,
                     WA_ScreenTitle,Screen.ps_Title,
                     WA_IDCMP,BUTTONIDCMP|LISTVIEWIDCMP|IDCMP_CLOSEWINDOW|\
                              IDCMP_REFRESHWINDOW|IDCMP_VANILLAKEY|\
                              IDCMP_RAWKEY|IDCMP_NEWSIZE|IDCMP_SIZEVERIFY,
                     WA_Flags,WFLG_DRAGBAR|WFLG_CLOSEGADGET|WFLG_DEPTHGADGET|\
                              WFLG_SIZEGADGET|WFLG_SIZEBBOTTOM|WFLG_ACTIVATE|\
                              WFLG_RMBTRAP|WFLG_SIMPLE_REFRESH,
                     WA_AutoAdjust,TRUE,
                     WA_PubScreen,Screen.ps_Screen,
                     TAG_DONE))
  {
    LONG max=GetDocNum((struct Document *)labels->lh_TailPred);

    DEBUG_PRINTF("  ListWin opened\n");

    if (akt>max) akt=max;

    ProgScreenToFront();

    /* Gadgets kreieren */
    if (GadList=CreateListReqGads(labels,akt))
    {
      struct IntuiMessage *imsg;
      struct Gadget *gad;
      BOOL quit=QUIT_NOTQUIT;
      ULONG secs,micros,oldsecs=0,oldmicros=0;
      ULONG class;
      UWORD code,qual;
      APTR  iaddr;

      DEBUG_PRINTF("  GadList created\n");

      /* Gadgetlist anhängen */
      AddGList(ListWin,GadList,~0,~0,NULL);
      GadListRemoved=FALSE;
      DEBUG_PRINTF("  GadList added to ListWin\n");

      /* Window neu aufbauen */
      RefreshGList(GadList,ListWin,NULL,~0);
      GT_RefreshWindow(ListWin,NULL);
      DEBUG_PRINTF("  GadList refreshed\n");

      DisableAllWindows();
      DEBUG_PRINTF("  all Windows disabled\n");

      while (quit==QUIT_NOTQUIT)
      {
        WaitPort(ListWin->UserPort);

        while (imsg=GT_GetIMsg(ListWin->UserPort))
        {
          DEBUG_PRINTF("  Got Message from ListWin->UserPort\n");

          class =imsg->Class;
          code  =imsg->Code;
          iaddr =imsg->IAddress;
          secs  =imsg->Seconds;
          micros=imsg->Micros;
          qual  =imsg->Qualifier;

          switch(class)
          {
            case IDCMP_SIZEVERIFY:
              /* Gadgetliste abhängen */
              if (GadListRemoved==FALSE)
              {
                RemoveGList(ListWin,GadList,~0);
                GadListRemoved=TRUE;
                DEBUG_PRINTF("  GadList removed from ListWin\n");
              }

              DEBUG_PRINTF("  SizeVerify processed\n");
              break;

            /* Neue Window Größe */
            case IDCMP_NEWSIZE:
            {
              /* Gadgetliste abhängen */
              if (GadListRemoved==FALSE)
              {
                RemoveGList(ListWin,GadList,~0);
                DEBUG_PRINTF("  GadList removed from ListWin\n");
              }

              /* GadList freigeben */
              FreeGadgets(GadList);
              DEBUG_PRINTF("  GadList freed\n");

              /* Gadgets kreieren */
              if (GadList=CreateListReqGads(labels,akt))
              {
                DEBUG_PRINTF("  GadList created\n");

                /* Window löschen */
                SetAPen(ListWin->RPort,0);
                RectFill(ListWin->RPort,
                         ListWin->BorderLeft,
                         ListWin->BorderTop,
                         ListWin->Width-ListWin->BorderRight-1,
                         ListWin->Height-ListWin->BorderBottom-1);
                DEBUG_PRINTF("  ListWin cleared\n");

                /* Gadgetlist anhängen */
                AddGList(ListWin,GadList,~0,~0,NULL);
                GadListRemoved=FALSE;
                DEBUG_PRINTF("  GadList added to ListWin\n");

                /* Window neu aufbauen */
                RefreshGList(GadList,ListWin,NULL,~0);
                GT_RefreshWindow(ListWin,NULL);
                RefreshWindowFrame(ListWin);
                DEBUG_PRINTF("  ListWin and GadList refreshed\n");
              }
              else
                BeepProgScreen();

              DEBUG_PRINTF("  NewSize processed\n");
              break;
            }

            /* muß Window neu gezeichnet werden ? */
            case IDCMP_REFRESHWINDOW:
              GT_BeginRefresh(ListWin);
              GT_EndRefresh(ListWin,TRUE);
              DEBUG_PRINTF("  ListWin refreshed\n");
              break;

            /* Window geschlossen? */
            case IDCMP_CLOSEWINDOW:
              quit=QUIT_CANCEL;
              DEBUG_PRINTF("  quit set to QUIT_CANCEL\n");
              break;

            /* Gadget angeklickt? */
            case IDCMP_GADGETUP:
            {
              gad=(struct Gadget *)iaddr;

              /* welches Gadget */
              switch (gad->GadgetID)
              {
                case GD_LIST_LST:
                  if (DoubleClick(oldsecs,oldmicros,secs,micros) && akt==code)
                  {
                    quit=QUIT_OK;
                    DEBUG_PRINTF("  DoubleClick - quit set to QUIT_OK\n");
                  }

                  akt=code;

                  oldsecs=secs;
                  oldmicros=micros;

                  DEBUG_PRINTF("  GD_LIST_LST processed\n");
                  break;

                case GD_OK_BUT:
                  quit=QUIT_OK;
                  DEBUG_PRINTF("  GD_OK_BUT processed - quit set to QUIT_OK\n");
                  break;

                case GD_CANCEL_BUT:
                  quit=QUIT_CANCEL;
                  DEBUG_PRINTF("  GD_CANCEL_BUT processed - quit set to QUIT_CANCEL\n");
                  break;
              }

              DEBUG_PRINTF("  Gadgets processed\n");
              break;
            }

            /* RawKey? */
            case IDCMP_RAWKEY:
            {
              if (qual&(IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
              {
                /* welche Taste */
                switch (code)
                {
                  case CURSORDOWN:
                    akt=max;
                    DEBUG_PRINTF("  Shift+CursorUp processed\n");
                    break;

                  case CURSORUP:
                    akt=0;
                    DEBUG_PRINTF("  Shift+CursorDown processed\n");
                    break;
                }
              }
              else
              {
                /* welche Taste */
                switch (code)
                {
                  case CURSORDOWN:
                    if (akt<max) akt++;
                    DEBUG_PRINTF("  CursorDown processed\n");
                    break;

                  case CURSORUP:
                    if (akt>0) akt--;
                    DEBUG_PRINTF("  CursorUp processed\n");
                    break;
                }
              }

              GT_SetGadgetAttrs(List,ListWin,NULL,
                                GTLV_Selected,akt,
                                GTLV_Top,akt,
                                TAG_DONE);
              DEBUG_PRINTF("  RawKeys processed\n");
              break;
            }

            /* VanillaKey? */
            case IDCMP_VANILLAKEY:
            {
              /* welche Taste */
              switch (MatchVanillaKey(code,&VanKeys[0]))
              {
                case KEY_OK:
                  quit=QUIT_OK;
                  DEBUG_PRINTF("  KEY_OK processed - quit set to QUIT_OK\n");
                  break;

                case KEY_CANCEL:
                  quit=QUIT_CANCEL;
                  DEBUG_PRINTF("  KEY_CANCEL processed - quit set to QUIT_CANCEL\n");
                  break;
              }

              DEBUG_PRINTF("  VanillaKeys processed\n");
              break;
            }
          }

          /* antworten */
          GT_ReplyIMsg(imsg);
          DEBUG_PRINTF("  Message replyed\n");
        }
      }

      /* Cancel? */
      if (quit==QUIT_CANCEL)
      {
        akt=-1;
        DEBUG_PRINTF("  quit==QUIT_CANCEL -> akt=-1\n");
      }

      /* alte Position merken */
      WinPosP.ListRLeft  =ListWin->LeftEdge;
      WinPosP.ListRTop   =ListWin->TopEdge;
      WinPosP.ListRWidth =ListWin->Width;
      WinPosP.ListRHeight=ListWin->Height;
      DEBUG_PRINTF("  new Dimensions copied to WinPosP\n");

      /* Gadgetliste abhängen */
      RemoveGList(ListWin,GadList,~0);
      GadListRemoved=TRUE;
      DEBUG_PRINTF("  GadList removed from ListWin\n");

      /* GadgetListe freigeben */
      FreeGadgets(GadList);
      DEBUG_PRINTF("  GadList freed\n");
    }
    else
      EasyRequestAllWins("Error on creating gadgets\n"
                         "for the List Requester Window",
                         "Ok");

    /* Window schließen */
    CloseWindow(ListWin);
    DEBUG_PRINTF("  ListWin closed\n");

    EnableAllWindows();
    DEBUG_PRINTF("  all Windows enabled\n  -- returning --\n\n");

    return(akt);
  }
  else
    EasyRequestAllWins("Error on opening the List Requester Window",
                       "Ok");

  return(-1);
}

/* ======================================================================================= End of File
*/
