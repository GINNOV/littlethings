/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Command.c
** FUNKTION:  Command-Funktionen des AmigaGuideDesigners
**
*/

/*#define DEBUG*/
#include "AGD.h"

/* ======================================================================================== DeleteComm
** löscht einen Comm aus der Liste
*/
struct Command *DeleteComm(struct Command *com)
{
  struct Command *nxtcom=(struct Command *)com->com_Node.mln_Succ;

  DEBUG_PRINTF("\n    -- Invoking DeleteComm-function --\n");

  /* aus der Kette entfernen */
  Remove((struct Node *)com);
  DEBUG_PRINTF("    com removed from chain\n");

  /* StringData */
  if (com->com_StrData)
  {
    FreeVec(com->com_StrData);
    DEBUG_PRINTF("    com->com_StrData freed\n");
  }

  /* Struktur freigeben */
  FreeMem(com,sizeof(struct Command));
  DEBUG_PRINTF("    com freed\n    -- returning --\n\n");

  return(nxtcom);
}

/* ======================================================================================== InsertComm
** erzeugt einen neuen Comm und fügt ihn in die Liste ein
*/
struct Command *InsertComm(struct Document *doc,LONG ln,LONG cr,LONG len)
{
  struct Command *newcom,*nxtcom;

  DEBUG_PRINTF("\n    -- Invoking InsertComm-function --\n");

  /* richtigen Platz in Liste finden */
  nxtcom=GetCommVecLnHead(doc,ln);
  while (nxtcom->com_Node.mln_Succ && cr>nxtcom->com_Char)
    nxtcom=(struct Command *)nxtcom->com_Node.mln_Succ;

  DEBUG_PRINTF("    position for newcom found in chain\n");

  /* Speicher für Struktur anfordern */
  if (newcom=(struct Command *)
      AllocMem(sizeof(struct Command),MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
  {
    DEBUG_PRINTF("    newcom allocated\n");

    /* in die Kette einfügen (Reihenfolge ist wichtig, nich verändern) */
    Insert((struct List *)GetCommVecLn(doc,ln),(struct Node *)newcom,(struct Node *)nxtcom->com_Node.mln_Pred);
    DEBUG_PRINTF("    newcom inserted in chain\n");

    newcom->com_Type   =CommP.CommType;
    newcom->com_Char   =cr;
    newcom->com_Len    =len;
    newcom->com_StrData=mstrdup(CommP.StrData);
    newcom->com_FGPen  =CommP.FGPen;
    newcom->com_BGPen  =CommP.BGPen;
    newcom->com_Style  =CommP.Style;
    DEBUG_PRINTF("    newcom set\n");

    /* Ok */
    DEBUG_PRINTF("    -- returning --\n\n");
    return(newcom);
  }

  /* Fehler */
  DEBUG_PRINTF("    error on allocating newcom\n    -- returning --\n\n");
  return(NULL);
}

/* ======================================================================================= End of File
*/
