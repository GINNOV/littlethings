/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     ProgMenus.c
** FUNKTION:  ProgMenus-Routinen für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

struct Menu       *Menus;

/* MENUS */
#define MENU_PROJECT       0
#define  MENU_NEW           1
#define  MENU_OPEN          2
#define  MENU_SAVE          4
#define  MENU_SAVEAS        5
#define  MENU_ABOUT         7
#define  MENU_QUIT          9

#define MENU_EDIT         10
#define  MENU_CUT          11
#define  MENU_COPY         12
#define  MENU_PASTE        13
#define  MENU_ERASE        15
#define  MENU_UNDO         17
#define  MENU_REDO         18

#define MENU_WINDOWS      19
#define  MENU_PROJWIN      20
#define  MENU_DOCSWIN      21
#define  MENU_EDITWIN      22
#define  MENU_COMMWIN      23

#define MENU_SETTINGS     24
#define  MENU_CRICONS      25
#define  MENU_LOADWINPOS   27
#define  MENU_SAVEWINPOS   28
#define  MENU_SAVEWINPOSAS 29
#define  MENU_LOADSET      31

#define MENUNUM_PROJWIN FULLMENUNUM(2,0,0)
#define MENUNUM_DOCSWIN FULLMENUNUM(2,1,0)
#define MENUNUM_EDITWIN FULLMENUNUM(2,2,0)
#define MENUNUM_COMMWIN FULLMENUNUM(2,3,0)
#define MENUNUM_CRICONS FULLMENUNUM(3,0,0)

static struct NewMenu NewMenus[] =
{
 {NM_TITLE,NULL,       NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_NEW},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_OPEN},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_SAVE},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_SAVEAS},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_ABOUT},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_QUIT},
 {NM_TITLE,NULL,       NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_CUT},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_COPY},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_PASTE},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_ERASE},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_UNDO},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_REDO},
 {NM_TITLE,NULL,       NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_PROJWIN},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_DOCSWIN},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_EDITWIN},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_COMMWIN},
 {NM_TITLE,NULL,       NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,CHECKIT|MENUTOGGLE,0,(APTR)MENU_CRICONS},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_LOADWINPOS},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_SAVEWINPOS},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_SAVEWINPOSAS},
  {NM_ITEM,NM_BARLABEL,NULL,0,0,NULL},
  {NM_ITEM,NULL,       NULL,0,0,(APTR)MENU_LOADSET},
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
  NewMenus[MENU_NEW].nm_Label         ="New";
  NewMenus[MENU_NEW].nm_CommKey       ="N";
  NewMenus[MENU_OPEN].nm_Label        ="Open...";
  NewMenus[MENU_OPEN].nm_CommKey      ="O";
  NewMenus[MENU_SAVE].nm_Label        ="Save...";
  NewMenus[MENU_SAVE].nm_CommKey      ="S";
  NewMenus[MENU_SAVEAS].nm_Label      ="Save as...";
  NewMenus[MENU_SAVEAS].nm_CommKey    ="A";
  NewMenus[MENU_ABOUT].nm_Label       ="About...";
  NewMenus[MENU_QUIT].nm_Label        ="Quit";
  NewMenus[MENU_QUIT].nm_CommKey      ="Q";

  NewMenus[MENU_EDIT].nm_Label        ="Edit";
  NewMenus[MENU_CUT].nm_Label         ="Cut";
  NewMenus[MENU_CUT].nm_CommKey       ="X";
  NewMenus[MENU_COPY].nm_Label        ="Copy";
  NewMenus[MENU_COPY].nm_CommKey      ="C";
  NewMenus[MENU_PASTE].nm_Label       ="Paste";
  NewMenus[MENU_PASTE].nm_CommKey     ="V";
  NewMenus[MENU_ERASE].nm_Label       ="Erase";
  NewMenus[MENU_UNDO].nm_Label        ="Undo";
  NewMenus[MENU_UNDO].nm_CommKey      ="Z";
  NewMenus[MENU_REDO].nm_Label        ="Redo";

  NewMenus[MENU_WINDOWS].nm_Label     ="Windows";
  NewMenus[MENU_PROJWIN].nm_Label     ="Project Editor...";
  NewMenus[MENU_PROJWIN].nm_CommKey   ="1";
  NewMenus[MENU_PROJWIN].nm_Flags    |=WinPosP.ProjWin?CHECKED:0;
  NewMenus[MENU_DOCSWIN].nm_Label     ="Document Editor...";
  NewMenus[MENU_DOCSWIN].nm_CommKey   ="2";
  NewMenus[MENU_DOCSWIN].nm_Flags    |=WinPosP.DocsWin?CHECKED:0;
  NewMenus[MENU_EDITWIN].nm_Label     ="Text Editor...";
  NewMenus[MENU_EDITWIN].nm_CommKey   ="3";
  NewMenus[MENU_EDITWIN].nm_Flags    |=WinPosP.EditWin?CHECKED:0;
  NewMenus[MENU_COMMWIN].nm_Label     ="Command Editor...";
  NewMenus[MENU_COMMWIN].nm_CommKey   ="4";
  NewMenus[MENU_COMMWIN].nm_Flags    |=WinPosP.CommWin?CHECKED:0;

  NewMenus[MENU_SETTINGS].nm_Label    ="Settings";
  NewMenus[MENU_CRICONS].nm_Label     ="Create Icons?";

  /* Kunstgriff, damit nach Prefs-laden die Checkmark richtig gesetzt wird */
  NewMenus[MENU_CRICONS].nm_Flags     =(NewMenus[MENU_CRICONS].nm_Flags&~CHECKED)|
                                       (MiscP.CrIcons?CHECKED:0);

  NewMenus[MENU_LOADWINPOS].nm_Label  ="Load Window Positions...";
  NewMenus[MENU_SAVEWINPOS].nm_Label  ="Save Window Positions";
  NewMenus[MENU_SAVEWINPOSAS].nm_Label="Save Window Positions as...";
  NewMenus[MENU_LOADSET].nm_Label     ="Load Settings...";

  DEBUG_PRINTF("  Menu-Labels initialized\n");

  /* Menus anmelden */
  if (Menus=
      CreateMenus(NewMenus,TAG_DONE))
  {
    DEBUG_PRINTF("  Menus created\n");

    /* Menus layouten */
    if (LayoutMenus(Menus,Screen.ps_VisualInfo,
                    GTMN_TextAttr,&ScrP.ScrAttr,
                    GTMN_NewLookMenus,TRUE,
                    TAG_DONE))
    {
      DEBUG_PRINTF("  Menus layouted\n  -- returning --\n\n");

      return(TRUE);
    }
    else
      EasyRequestAllWins("Error on layouting the program`s menus","Ok");
  }
  else
    EasyRequestAllWins("Error on creating the program`s menus","Ok");

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
      /* neues Project */
      case MENU_NEW:
        FreeAGuide();
        InitAGuide();
        UpdateAllWindows();
        break;

      /* Project laden */
      case MENU_OPEN:
        ProjectName="TestProj.AGD";
        LoadProject();
        ProjectName=NULL;
        break;

      /* Project speichern */
      case MENU_SAVE:
        ProjectName="TestProj.AGD";
        SaveProject();
        ProjectName=NULL;
        DEBUG_PRINTF("    MENU_SAVE processed\n");
        break;

      /* Project speichern als */
      case MENU_SAVEAS:
        break;

      /* über */
      case MENU_ABOUT:
        EasyRequestAllWins(PROGNAME " " VERSION "." REVISION " (" __DATE__ ")\n"
                           "freely distributable\n"
                           "©" YEARS " Michael Weiser\n"
                           "\n"
                           "ARexxPort/PublicScreenName: %s",
                           "Ok",
                           PortName);

        DEBUG_PRINTF("    MENU_ABOUT processed\n");
        break;

      /* Programm beenden */
      case MENU_QUIT:
        CloseAllWindows();
        DEBUG_PRINTF("    MENU_QUIT processed\n");
        break;

      /* Project-Window */
      case MENU_PROJWIN:
        if (menuitem->Flags&CHECKED)
          OpenProjWin();
        else
        {
          GetProjWinPos();
          CloseProjWin();
          WinPosP.ProjWin=FALSE;
        }

        DEBUG_PRINTF("    MENU_PROJWIN processed\n");
        break;

      /* Documents-Window */
      case MENU_DOCSWIN:
        if (menuitem->Flags&CHECKED)
          OpenDocsWin();
        else
        {
          GetDocsWinSize();
          CloseDocsWin();
          WinPosP.DocsWin=FALSE;
        }

        DEBUG_PRINTF("    MENU_DOCSWIN processed\n");
        break;

      case MENU_EDITWIN:
        if (menuitem->Flags&CHECKED)
          OpenEditWin();
        else
        {
          GetEditWinSize();
          CloseEditWin();
          WinPosP.EditWin=FALSE;
        }

        DEBUG_PRINTF("    MENU_EDITWIN processed\n");
        break;

      case MENU_COMMWIN:
        if (menuitem->Flags&CHECKED)
          OpenCommWin();
        else
        {
          GetCommWinPos();
          CloseCommWin();
          WinPosP.CommWin=FALSE;
        }

        DEBUG_PRINTF("    MENU_COMMWIN processed\n");
        break;

      case MENU_CRICONS:
        MiscP.CrIcons=menuitem->Flags&CHECKED;
        DEBUG_PRINTF("    MENU_CRICONS processed\n");
        break;

      case MENU_LOADWINPOS:
        FileRD.Path   =PrefsPaths.WinPosP;
        FileRD.Title  ="Pfad für Prefs wählen";
        FileRD.Flags1 =FRF_DOPATTERNS;
        FileRD.Flags2 =0;

        if (OpenFileRequester())
        {
          if (PrefsPaths.WinPosP) FreeVec(PrefsPaths.WinPosP);
          PrefsPaths.WinPosP=FileRD.Path;
          ReOpen=REOPEN_WINPOSP;
        }

        DEBUG_PRINTF("    MENU_LOADWINPOS processed\n");
        break;

      case MENU_SAVEWINPOS:
        if (!SavePrefs(PrefsPaths.WinPosPEnv,PREFSMODE_WINPOS) ||
            !SavePrefs(PrefsPaths.WinPosPEnvArc,PREFSMODE_WINPOS))
          BeepProgScreen();

        DEBUG_PRINTF("  MENU_SAVESET processed\n");
        break;

      case MENU_SAVEWINPOSAS:
        FileRD.Path   =PrefsPaths.WinPosP;
        FileRD.Title  ="Pfad für Prefs wählen";
        FileRD.Flags1 =FRF_DOSAVEMODE|FRF_DOPATTERNS;
        FileRD.Flags2 =0;

        if (OpenFileRequester())
        {
          if (PrefsPaths.WinPosP) FreeVec(PrefsPaths.WinPosP);
          PrefsPaths.WinPosP=FileRD.Path;

          if (!SavePrefs(PrefsPaths.PrefsName,PREFSMODE_WINPOS))
            BeepProgScreen();
        }

        DEBUG_PRINTF("  MENU_SAVESETAS processed\n");
        break;

      case MENU_LOADSET:
        FileRD.Path   =PrefsPaths.PrefsName;
        FileRD.Title  ="Pfad für Prefs wählen";
        FileRD.Flags1 =FRF_DOPATTERNS;
        FileRD.Flags2 =0;

        if (OpenFileRequester())
        {
          if (PrefsPaths.PrefsName) FreeVec(PrefsPaths.PrefsName);
          PrefsPaths.PrefsName=FileRD.Path;
          ReOpen=REOPEN_PREFSNAME;
        }

        DEBUG_PRINTF("    MENU_LOADSET processed\n");
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

  SetState(MENUNUM_PROJWIN,WinPosP.ProjWin);
  SetState(MENUNUM_DOCSWIN,WinPosP.DocsWin);
  SetState(MENUNUM_EDITWIN,WinPosP.EditWin);
  SetState(MENUNUM_COMMWIN,WinPosP.CommWin);

  DEBUG_PRINTF("  -- returning --\n\n");
}

/* ======================================================================================= End of File
*/
