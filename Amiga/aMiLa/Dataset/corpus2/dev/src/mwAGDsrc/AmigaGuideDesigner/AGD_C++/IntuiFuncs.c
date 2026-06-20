/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     IntuiFuncs.c
** FUNKTION:  verschiedene Funktionen zur Intuition-Handhabung
**            (Gadgets,Windows,BevelBoxen)
**
*/

#include "AGD.h"

static UWORD __chip BusyPointer[]=
{
  0x0000, 0x0000,

  0x0400, 0x07C0,
  0x0000, 0x07C0,
  0x0100, 0x0380,
  0x0000, 0x07E0,
  0x07C0, 0x1FF8,
  0x1FF0, 0x3FEC,
  0x3FF8, 0x7FDE,
  0x3FF8, 0x7FBE,
  0x7FFC, 0xFF7F,
  0x7EFC, 0xFFFF,
  0x7FFC, 0xFFFF,
  0x3FF8, 0x7FFE,
  0x3FF8, 0x7FFE,
  0x1FF0, 0x3FFC,
  0x07C0, 0x1FF8,
  0x0000, 0x07E0,

  0x0000, 0x0000,
};

struct TagItem UnderscoreTags[]={GT_Underscore,'_',TAG_DONE};

static ULONG ProjIDCMP,DocsIDCMP,EditIDCMP,CommIDCMP;

/* ==================================================================================== GetValidWindow
** ermittelt ein existierendes Window
*/
struct Window *GetValidWindow(void)
{
  struct Window *win;

  if (ProjWin) win=ProjWin;
  else if (DocsWin) win=DocsWin;
   else if (EditWin) win=EditWin;
    else if (CommWin) win=CommWin;
     else win=NULL;

  return(win);
}

/* ===================================================================================== DisableWindow
** blockiert ein Window mit einem Null-Requester und setzt den BusyPointer
*/
ULONG DisableWindow(struct Window *win,struct Requester *req)
{
  if (win)
  {
    ULONG oldidcmp=win->IDCMPFlags;
    ModifyIDCMP(win,IDCMP_REFRESHWINDOW);

    /* Requester aufrufen */
    if (req) Request(req,win);

    /* Pointer setzen */
    if (IntuitionBase->lib_Version>=39)
      SetWindowPointer(win,WA_BusyPointer,TRUE,TAG_DONE);
    else
      SetPointer(win,BusyPointer,16,16,-6,0);

    return(oldidcmp);
  }

  return(0);
}

/* ====================================================================================== EnableWindow
** beendet den Sperr-Requester und setzt den Standard-Pointer
*/
void EnableWindow(struct Window *win,struct Requester *req,ULONG oldidcmp)
{
  if (win)
  {
    /* Pointer löschen */
    if (IntuitionBase->lib_Version>=39)
      SetWindowPointer(win,WA_Pointer,NULL,TAG_DONE);
    else
      ClearPointer(win);

    /* Requester beenden */
    if (req) EndRequest(req,win);

    ModifyIDCMP(win,oldidcmp);
  }
}

/* ================================================================================= DisableAllWindows
** sperrt alle Windows
*/
void DisableAllWindows(void)
{
  ProjIDCMP=DisableWindow(ProjWin,&BlockReq);
  DocsIDCMP=DisableWindow(DocsWin,&BlockReq);
  EditIDCMP=DisableWindow(EditWin,&BlockReq);
  CommIDCMP=DisableWindow(CommWin,&BlockReq);
}

/* ================================================================================== EnableAllWindows
** gibt all Windows wieder frei
*/
void EnableAllWindows(void)
{
  EnableWindow(CommWin,&BlockReq,CommIDCMP);
  EnableWindow(EditWin,&BlockReq,EditIDCMP);
  EnableWindow(DocsWin,&BlockReq,DocsIDCMP);
  EnableWindow(ProjWin,&BlockReq,ProjIDCMP);
}

/* =================================================================================== CloseAllWindows
** schließt alle Windows
*/
void CloseAllWindows(void)
{
  GetProjWinPos();
  GetDocsWinSize();
  GetEditWinSize();
  GetCommWinPos();

  CloseProjWin();
  CloseDocsWin();
  CloseEditWin();
  CloseCommWin();
}

/* ================================================================================== UpdateAllWindows
** erneuert alle Windows
*/
void UpdateAllWindows(void)
{
  UpdateProjWin();
  UpdateDocsWin();
  UpdateEditWin();
  UpdateCommWin();
}

/* ================================================================================== CreateGadgetList
** kreiert eine Gadgetliste aus einem GadgetData-Array
** Original: (c) 1990-1993 Stefan Becker (vom Toolmanager 2.1)
*/
struct Gadget* CreateGadgetList(struct GadgetData *gd, UBYTE gadnum)
{
  struct Gadget    *glist=NULL;
  struct Gadget    *gad  =NULL;
  struct NewGadget  ng={0};
  ULONG i;

  ng.ng_TextAttr  =&ScrP.ScrAttr;
  ng.ng_VisualInfo=Screen.ps_VisualInfo;

  /* Context anlegen */
  if (gad=CreateContext(&glist))
  {
    for (i=0; i<gadnum; i++, gd++)
    {
      /* NewGadget setzen */
      ng.ng_LeftEdge  =gd->LeftEdge;
      ng.ng_TopEdge   =gd->TopEdge;
      ng.ng_Width     =gd->Width;
      ng.ng_Height    =gd->Height;
      ng.ng_GadgetText=gd->GadgetText;
      ng.ng_GadgetID  =gd->GadgetID;
      ng.ng_Flags     =gd->Flags;

      if (gd->Tags)
      {
        UnderscoreTags[1].ti_Tag =TAG_MORE;
        UnderscoreTags[1].ti_Data=(ULONG)gd->Tags;
      }
      else
        UnderscoreTags[1].ti_Tag =TAG_DONE;

      /* CreateGadget() */
      if (!(gad=CreateGadgetA(gd->Type,gad,&ng,UnderscoreTags)))
      {
        /* Fehler */
        break;
      }

      /* Gadget-Pointer sichern */
      gd->Gadget=gad;
    }

    /* TagList wieder in Ordnung bringen, für Gebrauch von anderen Modulen */
    UnderscoreTags[1].ti_Data=TAG_DONE;

    /* Alles OK */
    if (gad) return(glist);

    /* Fehler */
    FreeGadgets(glist);
  }

  /* FALSE */
  return(NULL);
}

/* =============================================================================== DrawSeparatorsBoxes
** zeichnet alle Separators, die in einem SepData-Vector stehen
*/
void DrawSeparators(struct Window *w,struct SepData *sd,UBYTE sepnum)
{
  ULONG i;

  for (i=0;i<sepnum;i++,sd++)
  {
    DrawBevelBox(w->RPort,
                 sd->LeftEdge,sd->TopEdge,
                 sd->Width,SEPHEIGHT,
                 GT_VisualInfo,Screen.ps_VisualInfo,
                 GTBB_Recessed,TRUE,
                 TAG_DONE);
  }
}

/* ==================================================================================== FindVanillaKey
** sucht aus einem String den Buchstaben '_' und gibt den nächsten Buchstaben zurück
*/
char FindVanillaKey(const char *text)
{
  unsigned char *d;

  /* '_' in GadgetText suchen */
  if (d=strchr(text,'_'))
  {
    /* gefunden-nächsten Buchstaben zurückgeben */
    d++;
    return((char)tolower(*d));
  }
  else
  {
    /* nicht gefunden-illegales Zeichen zurückgeben */
    return(1);
  }
}

/* =================================================================================== MatchVanillaKey
** sucht aus einem Array von Buchstaben einen bestimmten heraus und gibt dessen
** Position im Array zurück
*/
LONG MatchVanillaKey(char key,const char *vanillakeys)
{
  char *d;

  /* in Array 'key' suchen */
  if (d=strchr(vanillakeys,key))
    /* gefunden-Nummer zurückgeben */
    return(d-vanillakeys);
  else
    /* nicht gefunden-illegalen Wert zurückgeben */
    return(-1);
}

/* ====================================================================================== DoStringCopy
** verdoppelt den Gadget-Buffer und gibt vorher den alten frei
*/
void DoStringCopy(char **buf,struct Gadget *gad)
{
  if (*buf) FreeVec(*buf);
  *buf=mstrdup(GetString(gad));
}

/* ======================================================================================= End of File
*/

