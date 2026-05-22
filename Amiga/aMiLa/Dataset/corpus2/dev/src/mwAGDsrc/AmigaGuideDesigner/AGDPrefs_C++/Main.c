/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Main.c
** FUNKTION:  Hauptprogramm-Code für AmigaGuideDesigner
**
*/

/*#define DEBUG*/
#include "AGDPrefs.h"

static const char  VersionCom[]="\0$VER: " PROGNAME " " VERSION "." REVISION " (" __DATE__ ")\0";

struct GfxBase      *GfxBase      =NULL;
struct Library      *IntuitionBase=NULL;
struct Library      *DiskfontBase =NULL;
struct Library      *IconBase     =NULL;
struct Library      *GadToolsBase =NULL;
struct Library      *AslBase      =NULL;
struct Library      *WorkbenchBase=NULL;
struct Library      *IFFParseBase =NULL;
struct ReqToolsBase *ReqToolsBase =NULL;

struct Requester     BlockReq;

char                *PortName     =NULL;

char                *Template     ="FROM,USE/S,SAVE/S,EDIT/S,PUBSCREEN/K,CREATEICONS/S,"
                                   "RTFILEREQ/S,RTFONTREQ/S,RTSCRMREQ/S,RTEASYREQ/S,DEFAULTFONT/S,"
                                   "REQMODE/S";

#define ARG_FROM         0
#define ARG_USE          1
#define ARG_SAVE         2
#define ARG_EDIT         3
#define ARG_PUBSCREEN    4
#define ARG_CRICONS      5
#define ARG_RTFILEREQ    6
#define ARG_RTFONTREQ    7
#define ARG_RTSCRMREQ    8
#define ARG_RTEASYREQ    9
#define ARG_DEFAULTFONT 10
#define ARG_REQMODE     11
#define ARGNUM          12

static char         *ToolTypes[]  ={
                                    NULL,
                                    "USE",
                                    "SAVE",
                                    "EDIT",
                                    "PUBSCREEN",
                                    "CREATEICONS",

                                    "RTFILEREQ",
                                    "RTFONTREQ",
                                    "RTSCRMREQ",
                                    "RTEASYREQ",
                                    "DEFAULTFONT",
                                    "REQMODE"
                                   };

/* ============================================================================== LowLevelErrorMessage
** gibt mit Hilfe eines CON:-Fensters und DOS eine Message aus
** (am Anfang ist die intuition.library ja noch nicht geöffnet,
**  die dos.library aber schon durch den startup-code)
*/ 
static
void LowLevelErrorMessage(char *text)
{
  BPTR file;

  if (file=Open("CON:30/20/400/50/" PROGNAME,MODE_NEWFILE))
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
       if (IFFParseBase=OpenLibrary("iffparse.library",37L)) {
        ReqToolsBase=(struct ReqToolsBase *)OpenLibrary("reqtools.library",38L);
        AslBase=OpenLibrary("asl.library",37L);

        if (!AslBase && !ReqToolsBase)
         EasyRequestAllWins("Error on opening either asl.library V37+\n"
                            "or reqtools.library V38+",
                            "Ok",
                            NULL);

        return(TRUE);
       }
       else
        EasyRequestAllWins("Error on opening iffparse.library V37+","Ok",NULL);
      }
      else
       EasyRequestAllWins("Error on opening workbench.library V37+","Ok",NULL);
     }
     else
      EasyRequestAllWins("Error on opening gadtools.library V37+","Ok",NULL);
    }
    else
     EasyRequestAllWins("Error on opening icon.library V37+","Ok",NULL);
   }
   else
    EasyRequestAllWins("Error on opening diskfont.library V34+","Ok",NULL);
  }
  else
   LowLevelErrorMessage("Error on opening intuition.library V37+");
 }
 else
  LowLevelErrorMessage("Error on opening graphics.library V37+");

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
      BPTR olddir;
      BOOL use=FALSE,save=FALSE;

      DEBUG_PRINTF("Libraries opened\n");

      InitAGDPrefs();
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
          char *ttrue="TRUE";

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_PUBSCREEN]))
          {
            if (AGDPrefsP.PubScreenName) FreeVec(AGDPrefsP.PubScreenName);
            AGDPrefsP.PubScreenName=mstrdup(t);
          }

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_CRICONS]))
            AGDPrefsP.CrIcons=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_RTFILEREQ]))
            AGDPrefsP.RTFileReq=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_RTFONTREQ]))
            AGDPrefsP.RTFontReq=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_RTSCRMREQ]))
            AGDPrefsP.RTScrMReq=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_RTEASYREQ]))
            AGDPrefsP.RTEasyReq=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_DEFAULTFONT]))
            AGDPrefsP.DefaultFont=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_REQMODE]))
            AGDPrefsP.ReqMode=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_USE]))
            use=MatchToolValue(t,ttrue);

          if (t=FindToolType(dobj->do_ToolTypes,ToolTypes[ARG_SAVE]))
            save=MatchToolValue(t,ttrue);

          /* Icon freigeben */
          FreeDiskObject(dobj);

          if (use || save)
          {
            if (PrefsName) FreeVec(PrefsName);
            PrefsName=mstrdup(wa->wa_Name);
          }

          DEBUG_PRINTF("Tooltypes loaded\n");
        }
        else
        {
          EasyRequestAllWins("Error on opening the icon\n"
                             "for reading tooltypes\n"
                             "FileName: %s",
                             "Ok",
                             &wa->wa_Name);
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
          if (args[ARG_PUBSCREEN])
          {
            if (AGDPrefsP.PubScreenName) FreeVec(AGDPrefsP.PubScreenName);
            AGDPrefsP.PubScreenName=mstrdup((char *)args[ARG_PUBSCREEN]);
          }

          if (args[ARG_RTEASYREQ])   AGDPrefsP.RTEasyReq  =TRUE;
          if (args[ARG_RTFILEREQ])   AGDPrefsP.RTFileReq  =TRUE;
          if (args[ARG_RTFONTREQ])   AGDPrefsP.RTFontReq  =TRUE;
          if (args[ARG_RTSCRMREQ])   AGDPrefsP.RTScrMReq  =TRUE;

          if (args[ARG_DEFAULTFONT]) AGDPrefsP.DefaultFont=TRUE;
          if (args[ARG_REQMODE])     AGDPrefsP.ReqMode    =TRUE;
          if (args[ARG_CRICONS])     AGDPrefsP.CrIcons    =TRUE;

          if (args[ARG_USE])  use=TRUE;
          if (args[ARG_SAVE]) save=TRUE;
          if (args[ARG_FROM])
          {
            if (PrefsName) FreeVec(PrefsName);
            PrefsName=mstrdup((char *)args[ARG_FROM]);
          }

          /* Args wieder freigeben */
          FreeArgs(rdargs);

          DEBUG_PRINTF("CLI-Args read\n");
        }
        else
          EasyRequestAllWins("Error on reading the CLI-arguments","Ok",NULL);
      }

      if (!use && !save)
      {
        /* Prefs laden */
        if (PrefsName)
          LoadPrefs(PrefsName);
        else
          if (!LoadPrefs(PrefsNameEnv))
            LoadPrefs(PrefsNameEnvArc);

        /* Screen besorgen */
        if (GetProgScreen())
        {
          DEBUG_PRINTF("Screen got\n");

          /* Menus anmelden */
          if (CreateProgMenus())
          {
            ULONG signals,signalmask;

            DEBUG_PRINTF("Menus created\n");

            /* Windows initialisieren */
            InitMainWin();
            InitProjSetWin();
            InitDocsSetWin();
            InitCommSetWin();
            InitMiscSetWin();
            InitScrSetWin();
            InitRequester(&BlockReq);
            InitListReq();
            DEBUG_PRINTF("Windows and Requesters initialized\n");

            if (AGDPrefsP.MainWin)    OpenMainWin();
            if (AGDPrefsP.ProjSetWin) OpenProjSetWin();
            if (AGDPrefsP.DocsSetWin) OpenProjSetWin();
            if (AGDPrefsP.CommSetWin) OpenProjSetWin();
            if (AGDPrefsP.MiscSetWin) OpenProjSetWin();
            if (AGDPrefsP.ScrSetWin)  OpenProjSetWin();

            SetProgMenusStates();

            signalmask=SIGBREAKF_CTRL_C|ProjSetBit|DocsSetBit|CommSetBit|MiscSetBit|ScrSetBit|MainBit;

            /* Hauptschleife (bis alle Windows geschlossen sind) */
            while (signalmask!=SIGBREAKF_CTRL_C)
            {
              /* auf Message warten */
              signals=Wait(signalmask);

              if (signals&SIGBREAKF_CTRL_C) CloseAllWindows();
              if (signals&MainBit)    HandleMainWinIDCMP();
              if (signals&ProjSetBit) HandleProjSetWinIDCMP();
              if (signals&DocsSetBit) HandleDocsSetWinIDCMP();
              if (signals&CommSetBit) HandleCommSetWinIDCMP();
              if (signals&MiscSetBit) HandleMiscSetWinIDCMP();
              if (signals&ScrSetBit)  HandleScrSetWinIDCMP();

              signalmask=SIGBREAKF_CTRL_C|MainBit|ProjSetBit|DocsSetBit|CommSetBit|MiscSetBit|ScrSetBit;
            }

            DEBUG_PRINTF("left Main Loop\n");

            /* Menus freigeben */
            FreeProgMenus();
            DEBUG_PRINTF("ProgMenus freed\n");
          }
          else
            rc=RETURN_ERROR;

          FreeProgScreen();
          DEBUG_PRINTF("ProgScreen freed\n");
        }
        else
          rc=RETURN_ERROR;
      }
      else
      {
        if (LoadPrefs(PrefsName))
        {
          if (use)  SavePrefs(PrefsNameEnv);
          if (save) SavePrefs(PrefsNameEnvArc);
        }
      }

      FreePrefs();
      FreeAGDPrefs();

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
