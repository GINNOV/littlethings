/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Main.c
** FUNKTION:  Hauptprogramm-Code für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGD.h"

static const char  VersionCom[]="\0$VER: " PROGNAME " " VERSION "." REVISION " (" __DATE__ ")\0";

struct GfxBase      *GfxBase;
struct Library      *IntuitionBase;
struct Library      *DiskfontBase;
struct Library      *IconBase;
struct Library      *GadToolsBase;
struct Library      *AslBase;
struct Library      *WorkbenchBase;
struct Library      *UtilityBase;
struct Library      *IFFParseBase;
struct ReqToolsBase *ReqToolsBase;

struct Requester     BlockReq;

char                *PortName     =NULL;
UBYTE                ReOpen       =FALSE;

struct PrefsPaths    PrefsPaths   ={
                                    NULL,
                                    "ENV:" SPROGNAME ".prefs",
                                    "ENVARC:" SPROGNAME ".prefs",
                                    NULL,
                                    "ENV:" SPROGNAME "WinPos.prefs",
                                    "ENVARC:" SPROGNAME "WinPos.prefs",
                                   };

static char         *Template     ="SETTINGS/K,WINPOSPREFS/K,PROJECT";

static char         *ToolTypes[]  ={
                                    "SETTINGS",
                                    "WINPOSPREFS"
                                   };

#define ARG_SETTINGS 0
#define ARG_WINPOSP  1
#define ARG_PROJECT  2
#define ARGNUM       3

/* ============================================================================== LowLevelErrorMessage
** gibt mit Hilfe eines CON:-Fensters und DOS eine Message aus
** (am Anfang ist die intuition.library ja noch nicht geöffnet,
**  die dos.library aber schon durch den startup-code)
*/ 
static
void LowLevelErrorMessage(char *text)
{
  BPTR file;

  if (file=Open("CON:30/20/400/50/AmigaGuideDesigner",MODE_NEWFILE))
  {
    Write(file,text,strlen(text));

    Delay(200);
    Close(file);
  }
}

/* ==================================================================================== CloseLibraries
** schließt alle vom Programm geöffneten Libraries
*/
static void CloseLibraries(void)
{
  if (ReqToolsBase)  CloseLibrary((struct Library *)ReqToolsBase);
  if (AslBase)       CloseLibrary(AslBase);
  if (IFFParseBase)  CloseLibrary(IFFParseBase);
  if (UtilityBase)   CloseLibrary(UtilityBase);
  if (WorkbenchBase) CloseLibrary(WorkbenchBase);
  if (GadToolsBase)  CloseLibrary(GadToolsBase);
  if (IconBase)      CloseLibrary(IconBase);
  if (DiskfontBase)  CloseLibrary(DiskfontBase);
  if (IntuitionBase) CloseLibrary(IntuitionBase);
  if (GfxBase)       CloseLibrary((struct Library *)GfxBase);
}

/* ===================================================================================== OpenLibraries
** öffnet alle benötigten Libraries
*/
static int OpenLibraries(void)
{
 if (GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",37L)) {
  if (IntuitionBase=OpenLibrary("intuition.library",37L)) {
   if (DiskfontBase=OpenLibrary("diskfont.library",34L)) {
    if (IconBase=OpenLibrary("icon.library",37L)) {
     if (GadToolsBase=OpenLibrary("gadtools.library",37L)) {
      if (WorkbenchBase=OpenLibrary("workbench.library",37L)) {
       if (UtilityBase=OpenLibrary("utility.library",37L)) {
        if (IFFParseBase=OpenLibrary("iffparse.library",37L)) {
         ReqToolsBase=(struct ReqToolsBase *)OpenLibrary("reqtools.library",38L);
         AslBase=OpenLibrary("asl.library",37L);

         if (!AslBase && !ReqToolsBase)
          EasyRequestAllWins("Error opening either asl.library V37+\n"
                             "or reqtools.library V38+",
                             "Ok");

         return(TRUE);
        }
        else
         EasyRequestAllWins("Error opening iffparse.library V37+","Ok");
       }
       else
        EasyRequestAllWins("Error opening utility.library V37+","Ok");
      }
      else
       EasyRequestAllWins("Error opening workbench.library V37+","Ok");
     }
     else
      EasyRequestAllWins("Error opening gadtools.library V37+","Ok");
    }
    else
     EasyRequestAllWins("Error opening icon.library V37+","Ok");
   }
   else
    EasyRequestAllWins("Error opening diskfont.library V34+","Ok");
  }
  else
   LowLevelErrorMessage("Error opening intuition.library V37+");
 }
 else
  LowLevelErrorMessage("Error opening graphics.library V37+");

 /* schiefgegangen */
 CloseLibraries();
 return(FALSE);
}

/* ======================================================================================= mainprogram
** das eigentliche Hauptprogramm
*/
static int mainprogram(struct WBArg *wa)
{
  int rc=RETURN_OK;

  DEBUG_PRINTF("\n-- Invoking mainprogram-function --\n");

  /* 2.04 vorhanden? */
  if (SysBase->lib_Version>=37)
  {
    DEBUG_PRINTF("OS 2.0 available\n");

    /* Libraries öffnen */
    if (OpenLibraries())
    {
      BPTR olddir,lock;

      DEBUG_PRINTF("Libraries opened\n");

      InitPrefs();
      DEBUG_PRINTF("Prefs initialized\n");

      /* Programm-Verzeichnis aktuell */
      olddir=CurrentDir(wa->wa_Lock);

      /* von der Workbench gestartet? */
      if (wa)
      {
        struct DiskObject *dobj;

        DEBUG_PRINTF("WB-Start\n");

        /* Icon öffnen und Tooltypes auslesen */
        if (dobj=GetDiskObject(wa->wa_Name))
        {
          char *t;

          /* SETTINGS */
          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_SETTINGS]))
          {
            if (PrefsPaths.PrefsName) FreeVec(PrefsPaths.PrefsName);
            PrefsPaths.PrefsName=mstrdup(t);
          }

          /* WINPOSPREFS */
          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_WINPOSP]))
          {
            if (PrefsPaths.WinPosP) FreeVec(PrefsPaths.WinPosP);
            PrefsPaths.WinPosP=mstrdup(t);
          }

          /* Icon freigeben */
          FreeDiskObject(dobj);

          DEBUG_PRINTF("Tooltypes loaded\n");
        }
        else
        {
          EasyRequestAllWins("Error opening the icon\n"
                             "for reading tooltypes\n"
                             "FileName: %s",
                             "Ok",
                             wa->wa_Name);
          rc=FALSE;
        }
      }
      else
      {
        LONG args[ARGNUM];
        struct RDArgs *rdargs;

        DEBUG_PRINTF("CLI-Start\n");

        /* Args einlesen */
        if (rdargs=ReadArgs(Template,args,NULL))
        {
          if (args[ARG_SETTINGS])
          {
            if (PrefsPaths.PrefsName) FreeVec(PrefsPaths.PrefsName);
            PrefsPaths.PrefsName=mstrdup((char *)args[ARG_SETTINGS]);
          }

          if (args[ARG_WINPOSP])
          {
            if (PrefsPaths.WinPosP) FreeVec(PrefsPaths.WinPosP);
            PrefsPaths.WinPosP=mstrdup((char *)args[ARG_WINPOSP]);
          }

          if (args[ARG_PROJECT])
          {
            if (ProjectName) FreeVec(ProjectName);
            ProjectName=mstrdup((char *)args[ARG_PROJECT]);
          }

          /* Args wieder freigeben */
          FreeArgs(rdargs);

          DEBUG_PRINTF("CLI-Args read\n");
        }
        else
          EasyRequestAllWins("Error reading the CLI-arguments","Ok");
      }

      /* ProgPrefs laden */
      if (PrefsPaths.PrefsName)
        LoadPrefs(PrefsPaths.PrefsName,PREFSMODE_PROGPREFS);
      else
      {
        if (!LoadPrefs(PrefsPaths.PrefsNameEnv,PREFSMODE_PROGPREFS))
          LoadPrefs(PrefsPaths.PrefsNameEnvArc,PREFSMODE_PROGPREFS);
      }

      /* WinPosPrefs laden */
      if (PrefsPaths.WinPosP)
        LoadPrefs(PrefsPaths.WinPosP,PREFSMODE_WINPOS);
      else
      {
        if (!LoadPrefs(PrefsPaths.WinPosPEnv,PREFSMODE_WINPOS))
          LoadPrefs(PrefsPaths.WinPosPEnvArc,PREFSMODE_WINPOS);
      }

      /* AGD.<nummer>-String generieren. */
      if (PortName=(char *)
          AllocVec(14,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
      {
        struct Screen *pscr;
        int   i=1;

        DEBUG_PRINTF("memory for PortName allocated\n");

        strcpy(PortName,SPROGNAME ".");
        stci_d(&PortName[4],i);

        while(pscr=LockPubScreen(PortName))
        {
          UnlockPubScreen(PortName,pscr);
          i++;
          stci_d(&PortName[4],i);
        }

        DEBUG_PRINTF("PortName constructed\n");
      }

      if (InitAGuide())
      {
        ULONG prefbit=0;
        struct NotifyRequest prefnr;

        DEBUG_PRINTF("AGuide initialized\n");

        prefnr.nr_Name =PrefsPaths.PrefsNameEnv;
        prefnr.nr_Flags=NRF_SEND_SIGNAL;
        prefnr.nr_stuff.nr_Signal.nr_Task=FindTask(NULL);

        /* Signal allokieren */
        if (~0!=(prefnr.nr_stuff.nr_Signal.nr_SignalNum=AllocSignal(-1)))
        {
          DEBUG_PRINTF("prefnr.nr_stuff.nr_Signal.nr_SignalNum allocted\n");

          /* Notify starten */
          if (StartNotify(&prefnr))
          {
            prefbit=1L<<prefnr.nr_stuff.nr_Signal.nr_SignalNum;
            DEBUG_PRINTF("notify on ENV:AGD.prefs started\nprefbit set\n");
          }
          else
          {
            rc=RETURN_ERROR;
            EasyRequestAllWins("Error starting notify on file\n"
                               "%s",
                               "Ok",
                               PrefsPaths.PrefsNameEnv);
          }
        }
        else
        {
          rc=RETURN_ERROR;
          EasyRequestAllWins("Error allocating signal for\n"
                             "notifying file\n"
                             "%s",
                             "Ok",
                             PrefsPaths.PrefsNameEnv);
        }

        /*if (ProjectName) LoadProject(ProjectName);*/

        do
        {
          ReOpen=REOPEN_NOTHING;

          /* Screen besorgen */
          if (GetProgScreen())
          {
            DEBUG_PRINTF("Screen got\n");

            /* Menus anmelden */
            if (CreateProgMenus())
            {
              DEBUG_PRINTF("Menus created\n");

              /* Windows initialisieren */
              InitProjWin();
              InitDocsWin();

              if (InitEditWin() &&
                  InitCommWin())
              {
                ULONG signals,signalmask,minmask;

                DEBUG_PRINTF("Windows and Requesters initialized\n");

                /* Requester initialisieren */
                InitRequester(&BlockReq);
                InitListReq();
                DEBUG_PRINTF("ListReq initialized\n");

                if (WinPosP.ProjWin) OpenProjWin();
                if (WinPosP.DocsWin) OpenDocsWin();
                if (WinPosP.EditWin) OpenEditWin();
                if (WinPosP.CommWin) OpenCommWin();

                signalmask=SIGBREAKF_CTRL_C|ProjBit|DocsBit|EditBit|CommBit|prefbit;
                minmask   =SIGBREAKF_CTRL_C|prefbit;

                /* Hauptschleife (bis alle Windows geschlossen sind) */
                while (signalmask!=minmask)
                {
                  /* auf Message warten */
                  signals=Wait(signalmask);

                  if (signals&SIGBREAKF_CTRL_C) CloseAllWindows();
                  if (signals&ProjBit) HandleProjWinIDCMP();
                  if (signals&DocsBit) HandleDocsWinIDCMP();
                  if (signals&EditBit) HandleEditWinIDCMP();
                  if (signals&CommBit) HandleCommWinIDCMP();
                  if (signals&prefbit) ReOpen=REOPEN_PREFSNAMEENV;

                  if (ReOpen) CloseAllWindows();

                  signalmask=SIGBREAKF_CTRL_C|ProjBit|DocsBit|EditBit|CommBit|prefbit;
                }

                DEBUG_PRINTF("left Main Loop\n");

                UnInitCommWin();
                UnInitEditWin();
                DEBUG_PRINTF("Windows and Requesters uninitialized\n");
              }
              else
                rc=RETURN_ERROR;

              /* Menus freigeben */
              FreeProgMenus();
            }
            else
              rc=RETURN_ERROR;

            FreeProgScreen();
            DEBUG_PRINTF("ProgScreen freed\n");
          }
          else
            rc=RETURN_ERROR;

          switch (ReOpen)
          {
            case REOPEN_PREFSNAME:
              LoadPrefs(PrefsPaths.PrefsName,PREFSMODE_PROGPREFS);
              break;

            case REOPEN_PREFSNAMEENV:
              LoadPrefs(PrefsPaths.PrefsNameEnv,PREFSMODE_PROGPREFS);
              break;

            case REOPEN_WINPOSP:
              LoadPrefs(PrefsPaths.WinPosP,PREFSMODE_WINPOS);
              break;
          }
        }
        while(ReOpen && rc==RETURN_OK);

        if (prefbit)
        {
          EndNotify(&prefnr);
          DEBUG_PRINTF("notify stopped\n");
        }

        if (prefnr.nr_stuff.nr_Signal.nr_SignalNum!=~0)
        {
          FreeSignal(prefnr.nr_stuff.nr_Signal.nr_SignalNum);
          DEBUG_PRINTF("prefnr.nr_stuff.nr_Signal.nr_SignalNum freed\n");
        }

        if (AGuide.gt_Name)
        {
          FreeVec(AGuide.gt_Name);
          DEBUG_PRINTF("AGuide.gt_Name freed\n");
        }

        FreeAGuide();
      }
      else
        rc=RETURN_ERROR;

      if (lock=Lock(MiscP.TmpDocFileName,SHARED_LOCK))
      {
        DeleteFile(MiscP.TmpDocFileName);
        UnLock(lock);
      }

      FreePrefs();

      if (PortName)
      {
        FreeVec(PortName);
        DEBUG_PRINTF("PortName freed\n");
      }

      if (PrefsPaths.PrefsName)
      {
        FreeVec(PrefsPaths.PrefsName);
        DEBUG_PRINTF("PrefsPaths.PrefsName freed\n");
      }

      if (PrefsPaths.WinPosP)
      {
        FreeVec(PrefsPaths.WinPosP);
        DEBUG_PRINTF("PrefsPaths.WinPosP freed\n");
      }

      CurrentDir(olddir);

      /* Libraries freigeben */
      CloseLibraries();
      DEBUG_PRINTF("Libraries closed\n");
    }
    else
      rc=RETURN_ERROR;
  }
  else
  {
    LowLevelErrorMessage("Sorry, but this program is kickstart 2.04 only!");
    rc=RETURN_FAIL;
  }

  DEBUG_PRINTF("-- returning --\n\n");
  return(rc);
}

/* ============================================================================================== main
** main() sollte eigentlich das Hauptprogramm sein...
*/
int main(int argc, char *argv[])
{
  int rc;

  if (argc==0)
  {
    struct WBStartup *wbs=(struct WBStartup *)argv;
    struct WBArg *wa=&wbs->sm_ArgList[wbs->sm_NumArgs-1];

    /* in mainprogram einspringen */
    rc=mainprogram(wa);
  }
  else
  {
    rc=mainprogram(NULL);
  }

  /* Programm beenden */
  return(rc);
}

/* ======================================================================================= End of File
*/
