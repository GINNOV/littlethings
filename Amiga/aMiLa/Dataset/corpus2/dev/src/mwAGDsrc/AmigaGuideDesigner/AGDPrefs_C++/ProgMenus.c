/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProgMenus.c
** FUNKTION:  ProgMenus-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

struct Menu       *Menus;

/* MENUS */
#define MENU_PROJECT       0
#define  MENU_OPEN          1
#define  MENU_SAVEAS        2
#define  MENU_ABOUT         4
#define  MENU_QUIT          6

#define MENU_EDIT         7
#define MENU_RESET         8
#define MENU_LASTSAVED     9
#define MENU_RESTORE       10

#define MENU_WINDOWS      11
#define  MENU_MAINWIN      12
#define  MENU_PROJSET      13
#define  MENU_DOCSSET      14
#define  MENU_COMMSET      15
#define  MENU_MISCSET      16
#define  MENU_SCRSET       17

#define MENU_SETTINGS     18
#define  MENU_CRICONS      19

#define MENUNUM_MAINWIN FULLMENUNUM(2,0,0)
#define MENUNUM_PROJSET FULLMENUNUM(2,1,0)
#define MENUNUM_DOCSSET FULLMENUNUM(2,2,0)
#define MENUNUM_COMMSET FULLMENUNUM(2,3,0)
#define MENUNUM_MISCSET FULLMENUNUM(2,4,0)
#define MENUNUM_SCRSET  FULLMENUNUM(2,5,0)
#define MENUNUM_CRICONS FULLMENUNUM(3,0,0)

static struct NewMenu NewMenus[] =
{
 {NM_TITLE,NULL,       NULL,0,0,0},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_OPEN},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_SAVEAS},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_ABOUT},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_QUIT},
 {NM_TITLE,NULL,       NULL,0,0,0},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_RESET},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_LASTSAVED},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_RESTORE},
 {NM_TITLE,NULL,       NULL,0,0,0},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_MAINWIN},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_PROJSET},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_DOCSSET},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_COMMSET},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_MISCSET},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_SCRSET},
 {NM_TITLE,NULL,       NULL,0,0,0},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_CRICONS},
 {NM_END}
};


/* ===================================================================================== FreeProgMenus
** gibt die ProgMenus frei
*/
void FreeProgMenus(void)
{
  DEBUG_PRINTF("\n  -- Invoking FreeProgMenus-function --\n");

  /* Menus freigeben */
  if (Menus)
  {
    FreeMenus(Menus);
    Menus=NULL;
    DEBUG_PRINTF("  Menus freed\n");
  }

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* =================================================================================== CreateProgMenus
** fordert die ProgMenus für alle Fenster an
*/
BOOL CreateProgMenus(void)
{
  DEBUG_PRINTF("\n  -- Invoking CreateProgMenus-function --\n");

  /* MenuLabels initialisieren */
  NewMenus[MENU_PROJECT].nm_Label     ="Project";
  NewMenus[MENU_OPEN].nm_Label        ="Open...";
  NewMenus[MENU_OPEN].nm_CommKey      ="O";
  NewMenus[MENU_SAVEAS].nm_Label      ="Save as...";
  NewMenus[MENU_SAVEAS].nm_CommKey    ="A";
  NewMenus[MENU_ABOUT].nm_Label       ="About...";
  NewMenus[MENU_QUIT].nm_Label        ="Quit";
  NewMenus[MENU_QUIT].nm_CommKey      ="Q";

  NewMenus[MENU_EDIT].nm_Label        ="Edit";
  NewMenus[MENU_RESET].nm_Label       ="Reset To Defaults";
  NewMenus[MENU_RESET].nm_CommKey     ="D";
  NewMenus[MENU_LASTSAVED].nm_Label   ="Last Saved";
  NewMenus[MENU_LASTSAVED].nm_CommKey ="L";
  NewMenus[MENU_RESTORE].nm_Label     ="Restore";
  NewMenus[MENU_RESTORE].nm_CommKey   ="R";

  NewMenus[MENU_WINDOWS].nm_Label     ="Windows";
  NewMenus[MENU_MAINWIN].nm_Label     ="Main Window...";
  NewMenus[MENU_MAINWIN].nm_CommKey   ="1";
  NewMenus[MENU_MAINWIN].nm_Flags    |=AGDPrefsP.MainWin;
  NewMenus[MENU_PROJSET].nm_Label     ="Project Editor Settings...";
  NewMenus[MENU_PROJSET].nm_CommKey   ="2";
  NewMenus[MENU_PROJSET].nm_Flags    |=AGDPrefsP.ProjSetWin?CHECKED:0;
  NewMenus[MENU_DOCSSET].nm_Label     ="Document Editor Settings...";
  NewMenus[MENU_DOCSSET].nm_CommKey   ="3";
  NewMenus[MENU_DOCSSET].nm_Flags    |=AGDPrefsP.DocsSetWin?CHECKED:0;
  NewMenus[MENU_COMMSET].nm_Label     ="Command Editor Settings...";
  NewMenus[MENU_COMMSET].nm_CommKey   ="4";
  NewMenus[MENU_COMMSET].nm_Flags    |=AGDPrefsP.CommSetWin?CHECKED:0;
  NewMenus[MENU_MISCSET].nm_Label     ="Miscellaneous Settings...";
  NewMenus[MENU_MISCSET].nm_CommKey   ="5";
  NewMenus[MENU_MISCSET].nm_Flags    |=AGDPrefsP.MiscSetWin?CHECKED:0;
  NewMenus[MENU_SCRSET].nm_Label      ="Screen Settings...";
  NewMenus[MENU_SCRSET].nm_CommKey    ="6";
  NewMenus[MENU_SCRSET].nm_Flags     |=AGDPrefsP.ScrSetWin?CHECKED:0;

  NewMenus[MENU_SETTINGS].nm_Label    ="Settings";
  NewMenus[MENU_CRICONS].nm_Label     ="Create Icons?";
  NewMenus[MENU_CRICONS].nm_Flags    |=AGDPrefsP.CrIcons?CHECKED:0;

  DEBUG_PRINTF("  Menu-Labels initialized\n");

  /* Menus anmelden */
  if (Menus=
      CreateMenus(NewMenus,TAG_DONE))
  {
    DEBUG_PRINTF("  Menus created\n");

    /* Menus layouten */
    if (LayoutMenus(Menus,Screen.ps_VisualInfo,
                    GTMN_TextAttr,&Screen.ps_ScrAttr,
                    GTMN_NewLookMenus,TRUE,
                    TAG_DONE))
    {
      DEBUG_PRINTF("  Menus layouted\n  -- returning --\n\n");

      return(TRUE);
    }
    else
      EasyRequestAllWins("Error on layouting the program`s menus","Ok",NULL);
  }
  else
    EasyRequestAllWins("Error on creating the program`s menus","Ok",NULL);

  DEBUG_PRINTF("  Error\n");
  FreeProgMenus();

  DEBUG_PRINTF("  -- returning --\n\n");
  return(FALSE);
}

/* =================================================================================== HandleProgMenus
** IDCMP-Message auswerten
*/
void HandleProgMenus(UWORD code)
{
  struct MenuItem *menuitem;

  DEBUG_PRINTF("\n    -- Invoking HandleProgMenus-function --\n");

  /* es könnten mehr als ein MenuItem auf einmal angeklickt worden sein */
  while (code!=MENUNULL)
  {
    menuitem=ItemAddress(Menus,code);

    /* welches MenuItem? */
    switch ((int)GTMENUITEM_USERDATA(menuitem))
    {
      /* Project laden */
      case MENU_OPEN:
        FileRD.Path   =PrefsName;
        FileRD.Title  ="Pfad für Prefs wählen";
        FileRD.Flags1 =FRF_DOPATTERNS;
        FileRD.Flags2 =0;

        if (OpenFileRequester())
        {
          if (PrefsName) FreeVec(PrefsName);
          PrefsName=FileRD.Path;
          if (!LoadPrefs(PrefsName)) BeepProgScreen();

          UpdateAllWindows();
        }

        DEBUG_PRINTF("    MENU_OPEN processed\n");
        break;

      /* Project speichern als */
      case MENU_SAVEAS:
        FileRD.Path   =PrefsName;
        FileRD.Title  ="Pfad für Prefs wählen";
        FileRD.Flags1 =FRF_DOSAVEMODE|FRF_DOPATTERNS;
        FileRD.Flags2 =0;

        if (OpenFileRequester())
        {
          if (PrefsName) FreeVec(PrefsName);
          PrefsName=FileRD.Path;
          if (!SavePrefs(PrefsName)) BeepProgScreen();
        }

        DEBUG_PRINTF("  MENU_SAVEAS processed\n");
        break;

      /* über */
      case MENU_ABOUT:
      {
        EasyRequestAllWins(PROGNAME " " VERSION "." REVISION " (" __DATE__ ")\n"
                           "freely distributable\n"
                           "©" YEARS " Michael Weiser",
                           "Ok",NULL);

        DEBUG_PRINTF("    MENU_ABOUT processed\n");
        break;
      }

      /* Programm beenden */
      case MENU_QUIT:
        CloseAllWindows();
        DEBUG_PRINTF("    MENU_QUIT processed\n");
        break;

      case MENU_RESET:
        FreePrefs();
        InitPrefs();
        UpdateAllWindows();
        DEBUG_PRINTF("    MENU_RESET processed\n");
        break;

      case MENU_LASTSAVED:
        if (!LoadPrefs(PrefsNameEnvArc)) BeepProgScreen();

        UpdateAllWindows();

        DEBUG_PRINTF("    MENU_LASTSAVED processed\n");
        break;

      case MENU_RESTORE:
        if (PrefsName)
        {
          if (!LoadPrefs(PrefsName)) BeepProgScreen();
        }
        else
          if (!LoadPrefs(PrefsNameEnv))
            if (!LoadPrefs(PrefsNameEnvArc)) BeepProgScreen();

        UpdateAllWindows();

        DEBUG_PRINTF("    MENU_RESTORE processed\n");
        break;

      case MENU_MAINWIN:
        if (menuitem->Flags&CHECKED)
          OpenMainWin();
        else
        {
          GetMainWinPos();
          CloseMainWin();
        }

        DEBUG_PRINTF("    MENU_MAINWIN processed\n");
        break;

      case MENU_PROJSET:
        if (menuitem->Flags&CHECKED)
          OpenProjSetWin();
        else
        {
          GetProjSetWinPos();
          CloseProjSetWin();
        }

        DEBUG_PRINTF("    MENU_PROJSET processed\n");
        break;

      case MENU_DOCSSET:
        if (menuitem->Flags&CHECKED)
          OpenDocsSetWin();
        else
        {
          GetDocsSetWinPos();
          CloseDocsSetWin();
        }

        DEBUG_PRINTF("    MENU_DOCSSET processed\n");
        break;

      case MENU_COMMSET:
        if (menuitem->Flags&CHECKED)
          OpenCommSetWin();
        else
        {
          GetCommSetWinPos();
          CloseCommSetWin();
        }

        DEBUG_PRINTF("    MENU_COMMSET processed\n");
        break;

      case MENU_MISCSET:
        if (menuitem->Flags&CHECKED)
          OpenMiscSetWin();
        else
        {
          GetMiscSetWinPos();
          CloseMiscSetWin();
        }

        DEBUG_PRINTF("    MENU_MISCSET processed\n");
        break;

      case MENU_SCRSET:
        if (menuitem->Flags&CHECKED)
          OpenScrSetWin();
        else
        {
          GetScrSetWinPos();
          CloseScrSetWin();
        }

        DEBUG_PRINTF("    MENU_SCRSET processed\n");
        break;

      case MENU_CRICONS:
        AGDPrefsP.CrIcons=menuitem->Flags&CHECKED;
        DEBUG_PRINTF("    MENU_CRICONS processed\n");
        break;
    }

    /* nächstes angeklicktes MenuItem */
    code=menuitem->NextSelect;
  }

  /* Programm beendet? */
  DEBUG_PRINTF("    -- returning --\n\n");
}

static
void SetState(UBYTE menunum,BOOL state)
{
  struct MenuItem *mi;
  mi=ItemAddress(Menus,menunum);
  mi->Flags=(mi->Flags&~CHECKED)|((state)?CHECKED:0);
}

/* ===================================================================================== SetMenuStates
** setzt die Status (ja, das is wirklich die Mehrzahl von Status) der Menus
*/
void SetProgMenusStates(void)
{
  DEBUG_PRINTF("\n  -- Invoking SetMenuStates-function --\n");

  SetState(MENUNUM_CRICONS,AGDPrefsP.CrIcons);
  SetState(MENUNUM_MAINWIN,AGDPrefsP.MainWin);
  SetState(MENUNUM_PROJSET,AGDPrefsP.ProjSetWin);
  SetState(MENUNUM_DOCSSET,AGDPrefsP.DocsSetWin);
  SetState(MENUNUM_COMMSET,AGDPrefsP.CommSetWin);
  SetState(MENUNUM_MISCSET,AGDPrefsP.MiscSetWin);
  SetState(MENUNUM_SCRSET ,AGDPrefsP.ScrSetWin);

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
