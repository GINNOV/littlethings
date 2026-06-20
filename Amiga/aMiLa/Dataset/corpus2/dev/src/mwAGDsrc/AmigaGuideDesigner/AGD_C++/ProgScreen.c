/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProgScreen.c
** FUNKTION:  ProgScreen-Code f¸r AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

       struct ProgScreen  Screen={0};

static LONG               Pens[]={~0};

/* ==================================================================================== FreeProgScreen
** gibt alles zum ProgScreen gehˆrende frei
** (Screen, Fonts, DrawInfo, VisualInfo usw.)
*/
void FreeProgScreen(void)
{
  DEBUG_PRINTF("\n  -- Invoking FreeProgScreen-function --\n");

  /* VisualInfo freigeben */
  if (Screen.ps_VisualInfo)
  {
    FreeVisualInfo(Screen.ps_VisualInfo);
    DEBUG_PRINTF("  Screen.ps_VisualInfo freed\n");
  }

  /* DrawInfo freigeben */
  if (Screen.ps_DrawInfo)
  {
    FreeScreenDrawInfo(Screen.ps_Screen,Screen.ps_DrawInfo);
    DEBUG_PRINTF("  Screen.ps_DrawInfo freed\n");
  }

  /* Screen freigeben */
  if (ScrP.CustomScreen)
  {
    if (Screen.ps_Screen)
    {
      while (!CloseScreen(Screen.ps_Screen))
        EasyRequestAllWins("Error on closing the screen\n"
                           "Please close all visitor windows",
                           "Ok");
      DEBUG_PRINTF("  Screen.ps_Screen closed\n");
    }
  }
  else
    if (Screen.ps_Screen)
    {
      UnlockPubScreen(ScrP.PubScreenName,Screen.ps_Screen);
      DEBUG_PRINTF("  Screen.ps_Screen unlocked\n");
    }


  if (Screen.ps_PubSig) FreeSignal(Screen.ps_PubSig);

  /* PrintFont freigeben */
  if (Screen.ps_PrintFont)
  {
    CloseFont(Screen.ps_PrintFont);
    DEBUG_PRINTF("  Screen.ps_PrintFont freed\n");
  }

  /* ScreenFont freigeben */
  if (Screen.ps_ScrFont)
  {
    CloseFont(Screen.ps_ScrFont);
    DEBUG_PRINTF("  Screen.ps_ScrFont freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ===================================================================================== GetProgScreen
** liefert bzw. initialisiert die gesamte struct ProgScreen (Fonts, Screen usw.)
*/
BOOL GetProgScreen(void)
{
  DEBUG_PRINTF("\n  -- Invoking GetProgScreen-function --\n");

  Screen.ps_Title=PROGNAME " ©" YEARS " Michael Weiser";
  DEBUG_PRINTF("  Screen.ps_Title built\n  -- returning -- \n\n");

  /* Window-Font ˆffnen */
  if (Screen.ps_ScrFont=
      OpenDiskFont(&ScrP.ScrAttr))
  {
    DEBUG_PRINTF("  Screen.ps_ScrFont opened\n");

    /* Text-Print-Font ˆffnen */
    if (Screen.ps_PrintFont=
        OpenDiskFont(&ScrP.PrintAttr))
    {
      DEBUG_PRINTF("  Screen.ps_PrintFont opened\n");

      if (ScrP.CustomScreen)
      {
        if (~0!=(Screen.ps_PubSig=AllocSignal(-1)))
        {
          DEBUG_PRINTF("  Screen.ps_PubSig allocated\n");

          /* eignen Screen ˆffnen */
          if (!(Screen.ps_Screen=
              OpenScreenTags(NULL,
                             SA_Width,ScrP.Width,
                             SA_Height,ScrP.Height,
                             SA_Depth,ScrP.Depth,
                             SA_DisplayID,ScrP.DisplayID,
                             SA_Pens,Pens,
                             SA_Title,Screen.ps_Title,
                             SA_Font,&ScrP.ScrAttr,
                             SA_Type,PUBLICSCREEN,
                             SA_AutoScroll,ScrP.AutoScroll,
                             SA_PubName,PortName,
                             SA_PubSig,Screen.ps_PubSig,
                             SA_PubTask,FindTask(NULL),
                             SA_Overscan,ScrP.Overscan,
                             SA_FullPalette,TRUE,
                             TAG_DONE)))
          {
            EasyRequestAllWins("Error on opening the screen\n"
                               "Width: %ld\n"
                               "Height: %ld\n"
                               "Depth: %ld\n"
                               "ModeID: %ld\n",
                               "Ok",
                               ScrP.Width,ScrP.Height,ScrP.Depth,ScrP.DisplayID);

            FreeSignal(Screen.ps_PubSig);
            Screen.ps_PubSig=~0;
            ScrP.CustomScreen=FALSE;
          }
        }
      }

      if (!ScrP.CustomScreen)
      {
        /* PubScreen locken */
        if (!(Screen.ps_Screen=LockPubScreen(ScrP.PubScreenName)))
          if (Screen.ps_Screen=LockPubScreen(NULL))
          {
            if (ScrP.PubScreenName)
            {
              FreeVec(ScrP.PubScreenName);
              ScrP.PubScreenName=NULL;
            }
          }
          else
            EasyRequestAllWins("Error on locking the default public screen","Ok");
      }

      if (Screen.ps_Screen)
      {
        DEBUG_PRINTF("  Screen.ps_Screen locked/opened\n");

        /* DrawInfo anfordern */
        if (Screen.ps_DrawInfo=
            GetScreenDrawInfo(Screen.ps_Screen))
        {
          DEBUG_PRINTF("  got Screen.ps_DrawInfo\n");

          InitRastPort(&Screen.ps_DummyRPort);
          SetFont(&Screen.ps_DummyRPort,Screen.ps_ScrFont);
          DEBUG_PRINTF("  Screen.ps_DummyRPort initialized and set to ScrFont\n");

          InitRastPort(&Screen.ps_PDummyRPort);
          SetFont(&Screen.ps_PDummyRPort,Screen.ps_PrintFont);
          DEBUG_PRINTF("  Screen.ps_PDummyRPort initialized and set toPrintFont\n");

          /* VisualInfo f¸r GadTools besorgen */
          if (Screen.ps_VisualInfo=
              GetVisualInfo(Screen.ps_Screen,TAG_DONE))
          {
            struct Image *sizim;

            DEBUG_PRINTF("  got VisualInfo\n");

            /* SizeWindow-Image anfordern, um BorderBreiten zu besorgen */
            if (sizim=(struct Image *)NewObject(NULL,SYSICLASS,
                                                SYSIA_Which,SIZEIMAGE,
                                                SYSIA_DrawInfo,Screen.ps_DrawInfo,
                                                TAG_DONE))
            {
              DEBUG_PRINTF("  got sizim for getting WBordor-Width and -Height\n");

              Screen.ps_WBorRight =sizim->Width;
              Screen.ps_WBorTop   =Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;
              Screen.ps_WBorBottom=sizim->Height;

              DisposeObject(sizim);
              DEBUG_PRINTF("  WBorder dimensions copied, sizim freed\n");

              if (ScrP.CustomScreen)
              {
                PubScreenStatus(Screen.ps_Screen,0);
                DEBUG_PRINTF("  screen taken public\n");
              }

              return(TRUE);
            }
            else
              EasyRequestAllWins("Error on getting window sizing image\n"
                                 "for preset window border dimensions",
                                 "Ok");
          }
          else
            EasyRequestAllWins("Error on getting info data for\n"
                               "gadget drawing",
                               "Ok");
        }
        else
          EasyRequestAllWins("Error on getting the screen`s drawing info","Ok");
      }
    }
    else
      EasyRequestAllWins("Error on opening print font\n"
                         "FileName %s\n"
                         "Size %ld",
                         "Ok",
                         ScrP.PrintAttr.ta_Name,
                         ScrP.PrintAttr.ta_YSize);
  }
  else
    EasyRequestAllWins("Error on opening window font\n"
                       "FileName: %s\n"
                       "Size: %ld",
                       "Ok",
                       ScrP.ScrAttr.ta_Name,
                       ScrP.ScrAttr.ta_YSize);

  DEBUG_PRINTF("  error - freeing everything\n");
  FreeProgScreen();

  DEBUG_PRINTF("  -- returning --\n\n");
  return(FALSE);
}

/* ==================================================================================== BeepProgScreen
** l‰ﬂt den ProgScreen aufblitzen
*/
void BeepProgScreen(void)
{
  DEBUG_PRINTF("\n  -- Invoking BeepProgScreen-function --\n");

  DisplayBeep(Screen.ps_Screen);

  DEBUG_PRINTF("  -- returning --\n\n");
}
 
/* ================================================================================= ProgScreenToFront
** holt den ProgScreen nach vorne
*/
void ProgScreenToFront(void)
{
  DEBUG_PRINTF("\n  -- Invoking ProgScreenToFront-function --\n");

  ScreenToFront(Screen.ps_Screen);

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End Of File
*/
