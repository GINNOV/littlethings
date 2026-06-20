/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProgScreen.c
** FUNKTION:  ProgScreen-Code f¸r AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

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
  if (Screen.ps_Screen)
  {
    UnlockPubScreen(AGDPrefsP.PubScreenName,Screen.ps_Screen);
    DEBUG_PRINTF("  Screen.ps_Screen unlocked\n");
  }

  /* ScreenFont freigeben */
  if (Screen.ps_ScrFont)
  {
    CloseFont(Screen.ps_ScrFont);
    DEBUG_PRINTF("  Screen.ps_ScrFont freed\n");
  }

  if (Screen.ps_ScrAttr.ta_Name)
  {
    FreeVec(Screen.ps_ScrAttr.ta_Name);
    DEBUG_PRINTF("  Screen.ps_ScrAttr.ta_Name freed\n");
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

  /* PubScreen locken */
  if (!(Screen.ps_Screen=LockPubScreen(AGDPrefsP.PubScreenName)))
    if (Screen.ps_Screen=LockPubScreen(NULL))
    {
      if (AGDPrefsP.PubScreenName)
      {
        FreeVec(AGDPrefsP.PubScreenName);
        AGDPrefsP.PubScreenName=NULL;
      }
    }
    else
      EasyRequestAllWins("Error on locking the default public screen","Ok",NULL);

  if (Screen.ps_Screen)
  {
    DEBUG_PRINTF("  Screen.ps_Screen locked/opened\n");

    if (AGDPrefsP.DefaultFont)
    {
      Screen.ps_ScrAttr.ta_Name =mstrdup(GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name);
      Screen.ps_ScrAttr.ta_YSize=GfxBase->DefaultFont->tf_YSize;
      Screen.ps_ScrAttr.ta_Style=GfxBase->DefaultFont->tf_Style;
      Screen.ps_ScrAttr.ta_Flags=GfxBase->DefaultFont->tf_Flags;
    }
    else
    {
      Screen.ps_ScrAttr.ta_Name =mstrdup(Screen.ps_Screen->Font->ta_Name);
      Screen.ps_ScrAttr.ta_YSize=Screen.ps_Screen->Font->ta_YSize;
      Screen.ps_ScrAttr.ta_Style=Screen.ps_Screen->Font->ta_Style;
      Screen.ps_ScrAttr.ta_Flags=Screen.ps_Screen->Font->ta_Flags;
    }

    /* Window-Font ˆffnen */
    if (Screen.ps_ScrFont=
        OpenDiskFont(&Screen.ps_ScrAttr))
    {
      DEBUG_PRINTF("  Screen.ps_ScrFont opened\n");

      /* DrawInfo anfordern */
      if (Screen.ps_DrawInfo=
          GetScreenDrawInfo(Screen.ps_Screen))
      {
        DEBUG_PRINTF("  got Screen.ps_DrawInfo\n");

        InitRastPort(&Screen.ps_DummyRPort);
        SetFont(&Screen.ps_DummyRPort,Screen.ps_ScrFont);
        DEBUG_PRINTF("  Screen.ps_DummyRPort initialized and Font set\n");

        /* VisualInfo f¸r GadTools besorgen */
        if (Screen.ps_VisualInfo=
            GetVisualInfo(Screen.ps_Screen,TAG_DONE))
        {
          Screen.ps_WBorTop=Screen.ps_Screen->WBorTop+Screen.ps_Screen->Font->ta_YSize+1;

          return(TRUE);
        }
        else
          EasyRequestAllWins("Error on getting info data for\n"
                             "gadget drawing",
                             "Ok",
                             NULL);
      }
      else
        EasyRequestAllWins("Error on getting the screen`s drawing info","Ok",NULL);
    }
    else
    {
      APTR args[2];
      args[0]=&Screen.ps_ScrAttr.ta_Name;
      args[1]=&Screen.ps_ScrAttr.ta_YSize;

      EasyRequestAllWins("Error on opening window font\n"
                         "FileName: %s\n"
                         "Size: %d",
                         "Ok",
                         args[0]);
    }
  }

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
