/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Document.c
** FUNKTION:  Document-Funktionen des AmigaGuideDesigners
**
*/

/*#define DEBUG*/
#include "AGD.h"

/* ========================================================================================= DeleteDoc
** entfernt ein Document aus der Liste
*/
struct Document *DeleteDoc(struct Document *doc)
{
  struct Document *nxtdoc=(struct Document *)doc->doc_Node.ln_Succ;

  DEBUG_PRINTF("\n    -- Invoking DeleteDoc-function --\n");

  /* Doc aus der Kette entfernen */
  Remove((struct Node *)doc);
  DEBUG_PRINTF("    doc removed from chain\n");

  /* NodeName */
  if (doc->doc_Node.ln_Name)
  {
    FreeVec(doc->doc_Node.ln_Name);
    DEBUG_PRINTF("    doc->doc_NodeName freed\n");
  }

  /* WinTitle */
  if (doc->doc_WinTitle)
  {
    FreeVec(doc->doc_WinTitle);
    DEBUG_PRINTF("    doc->doc_WinTitle freed\n");
  }

  /* NextNode */
  if (doc->doc_NextNode)
  {
    FreeVec(doc->doc_NextNode);
    DEBUG_PRINTF("    doc->doc_NextNode freed\n");
  }

  /* PrevNode */
  if (doc->doc_PrevNode)
  {
    FreeVec(doc->doc_PrevNode);
    DEBUG_PRINTF("    doc->doc_PrevNode freed\n");
  }

  /* TOCNode */
  if (doc->doc_TOCNode)
  {
    FreeVec(doc->doc_TOCNode);
    DEBUG_PRINTF("    doc->doc_TOCNode freed\n");
  }

  /* FileName */
  if (doc->doc_FileName)
  {
    FreeVec(doc->doc_FileName);
    DEBUG_PRINTF("    doc->doc_FileName freed\n");
  }

  /* Commands */
  if (doc->doc_Comms)
  {
    struct Command *com;
    LONG curln;

    for (curln=0;curln<doc->doc_NumLn;curln++)
    {
      com=(struct Command *)doc->doc_Comms[curln].mlh_Head;

      while (com->com_Node.mln_Succ) com=DeleteComm(com);
    }

    FreeCommVector(doc);
  }

  doc->doc_CurComm=NULL;

  /* ASCIIText */
  FreeASCIIText(doc);
 
  /* Struktur freigeben */
  FreeMem(doc,sizeof(struct Document));
  DEBUG_PRINTF("    doc freed\n    -- returning --\n\n");

  return(nxtdoc);
}

/* ========================================================================================= InsertDoc
** fügt ein neues Document (Node) in die Liste ein
*/
struct Document *InsertDoc(struct Document *predoc)
{
  struct Document *doc;

  DEBUG_PRINTF("\n    -- Invoking InsertDoc-function --\n");

  /* Document-Struktur anfordern */
  if (doc=(struct Document *)
      AllocMem(sizeof(struct Document),MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR))
  {
    DEBUG_PRINTF("    newdoc allocated\n");

    Insert((struct List *)&AGuide.gt_Docs,(struct Node *)doc,(struct Node *)predoc);
    DEBUG_PRINTF("    newdoc inserted in chain\n");

    doc->doc_Node.ln_Name=mstrdup(DocsP.NodeName);
    FormatDocsPrefsStrings(doc);

    /* Ok */
    return(doc);
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(NULL);
}

/* ============================================================================ FormatDocsPrefsStrings
** setzt die Werte eines Documents nach den Formaten in DocsP
*/
void FormatDocsPrefsStrings(struct Document *doc)
{
  if (doc->doc_NextNode) FreeVec(doc->doc_NextNode);
  if (doc->doc_PrevNode) FreeVec(doc->doc_PrevNode);
  if (doc->doc_TOCNode)  FreeVec(doc->doc_TOCNode);
  if (doc->doc_FileName) FreeVec(doc->doc_FileName);
  if (doc->doc_WinTitle) FreeVec(doc->doc_WinTitle);

  doc->doc_NextNode=FormatPrefsString(DocsP.NextNodeName,doc,PSSEQF_NOTHING);
  doc->doc_PrevNode=FormatPrefsString(DocsP.PrevNodeName,doc,PSSEQF_NOTHING);
  doc->doc_TOCNode =FormatPrefsString(DocsP.TOCNodeName,doc,PSSEQF_NOTHING);
  doc->doc_FileName=FormatPrefsString(DocsP.FileName,doc,PSSEQF_NOTHING);
  doc->doc_WinTitle=FormatPrefsString(DocsP.WinTitle,doc,PSSEQF_NOTHING);
}

/* ========================================================================================== ClearDoc
** löscht die Werte eines Documents
*/
struct Document *ClearDoc(struct Document *doc)
{
  struct Document *predoc=(struct Document *)doc->doc_Node.ln_Pred;

  DEBUG_PRINTF("\n    -- Invoking ClearDoc-function --\n");

  DeleteDoc(doc);
  doc=InsertDoc(predoc);

  DEBUG_PRINTF("    -- returning --\n\n");
  return(doc);
}
  
/* =========================================================================================== CopyDoc
** kopiert ein Document
*/
struct Document *CopyDoc(struct Document *predoc)
{
  struct Document *doc;

  DEBUG_PRINTF("\n    -- Invoking CopyDoc-function --\n");

  /* Document-Struktur anfordern */
  if (doc=InsertDoc(predoc))
  {
    DEBUG_PRINTF("    newdoc inserted\n");

    doc->doc_Node.ln_Name=mstrdup(predoc->doc_Node.ln_Name);
    doc->doc_WinTitle=mstrdup(predoc->doc_WinTitle);
    doc->doc_NextNode=mstrdup(predoc->doc_NextNode);
    doc->doc_PrevNode=mstrdup(predoc->doc_PrevNode);
    doc->doc_TOCNode =mstrdup(predoc->doc_TOCNode);
    doc->doc_FileName=mstrdup(predoc->doc_FileName);

    /* Ok */
    return(doc);
  }

  DEBUG_PRINTF("    -- returning --\n\n");
  return(NULL);
}
  
/* ====================================================================================== MoveDocFirst
** verschiebt ein Document in der Kette nach ganz oben
*/
void MoveDocFirst(struct Document *doc)
{
  Remove((struct Node *)doc);
  AddHead(&AGuide.gt_Docs,(struct Node *)doc);
}

/* ======================================================================================= MoveDocLast
** verschiebt ein Document in der Kette nach ganz unten
*/
void MoveDocLast(struct Document *doc)
{
  Remove((struct Node *)doc);
  AddTail(&AGuide.gt_Docs,(struct Node *)doc);
}
 
/* ========================================================================================= MoveDocUp
** verschiebt ein Document in der Kette um Ein Document aufwärts
*/
BOOL MoveDocUp(struct Document *doc)
{
  if (doc->doc_Node.ln_Pred->ln_Pred)
  {
    struct Document *predoc=(struct Document *)doc->doc_Node.ln_Pred->ln_Pred;

    Remove((struct Node *)doc);
    Insert(&AGuide.gt_Docs,(struct Node *)doc,(struct Node *)predoc);

    return(TRUE);
  }

  return(FALSE);
}

/* ======================================================================================= MoveDocDown
** verschiebt ein Document in der Kette um Ein Document abwärts
*/
BOOL MoveDocDown(struct Document *doc)
{
  if (doc->doc_Node.ln_Succ->ln_Succ)
  {
    struct Document *sucdoc=(struct Document *)doc->doc_Node.ln_Succ;

    Remove((struct Node *)doc);
    Insert(&AGuide.gt_Docs,(struct Node *)doc,(struct Node *)sucdoc);

    return(TRUE);
  }

  return(FALSE);
}

/* ========================================================================================= GetDocNum
** ermittelt die Nummer eines Documents
*/
LONG GetDocNum(struct Document *doc)
{
  LONG i=0;

  while (doc->doc_Node.ln_Pred->ln_Pred)
  {
    doc=(struct Document *)doc->doc_Node.ln_Pred;
    i++;
  }

  return(i);
}

/* ======================================================================================== GetDocAddr
** ermittelt die Struktur eines Documents
*/
struct Document *GetDocAddr(LONG num)
{
  LONG i;
  struct Document *doc=(struct Document *)AGuide.gt_Docs.lh_Head;

  for (i=0;i<num && doc->doc_Node.ln_Succ->ln_Succ;i++)
  {
    doc=(struct Document *)doc->doc_Node.ln_Succ;
  }

  return(doc);
}

/* ==================================================================================== FreeCommVector
** gibt den Vector wieder frei
*/
void FreeCommVector(struct Document *doc)
{
  DEBUG_PRINTF("\n    -- Invoking FreeCommVector-function --\n");

  if (doc->doc_Comms)
  {
    FreeMem(doc->doc_Comms,doc->doc_CommsBufLen);
    doc->doc_Comms=NULL;
    doc->doc_CommsBufLen=0;
    DEBUG_PRINTF("    doc->doc_Comms freed\n");
  }

  DEBUG_PRINTF("    -- returning --\n\n");
}

/* =================================================================================== AllocCommVector
** allokiert den Comm-Vector (neu) und kopiert die alten Werte dorthin
*/
BOOL AllocCommVector(struct Document *doc,LONG newnumln)
{
  ULONG buflen;
  struct MinList *comms;

  DEBUG_PRINTF("\n    -- Invoking AllocCommVector-function --\n");

  /* Blockgröße errechnen */
  buflen=newnumln*sizeof(struct MinList);
  DEBUG_PRINTF("    buflen calculated\n");

  /* Speicherblock anfordern */
  if (comms=(struct MinList *)
      AllocMem(buflen,MEMF_ANY|MEMF_PUBLIC))
  {
    ULONG i;

    DEBUG_PRINTF("    comms allocated\n");

    /* erst mal alles auf Defaults setzen */
    for (i=0;i<newnumln;i++)
      NewList((struct List *)&comms[i]);

    /* wenn Speicherblock schon vorhanden, alte Werte drüberkopieren */
    if (doc->doc_Comms)
    {
      ULONG copyln;

      DEBUG_PRINTF("    doc->doc_Comms already allocated\n");

      if (newnumln>doc->doc_NumLn)
        copyln=doc->doc_NumLn;
      else
        copyln=newnumln;

      DEBUG_PRINTF("    size of doc->doc_Comms and comms compared\n");

      /* alte Werte in neuen Block kopieren */
      for (i=0;i<copyln;i++)
      {
        /* nur kopieren, wenn eine Node dazwischen liegt, sonst wird`s nichts */
        if (doc->doc_Comms[i].mlh_Head->mln_Succ)
        {
          comms[i].mlh_Head=doc->doc_Comms[i].mlh_Head;
          comms[i].mlh_TailPred=doc->doc_Comms[i].mlh_TailPred;
          comms[i].mlh_Head->mln_Pred=(struct MinNode *)&comms[i].mlh_Head;
          comms[i].mlh_TailPred->mln_Succ=(struct MinNode *)&comms[i].mlh_Tail;
        }
      }
      DEBUG_PRINTF("    data copied from doc->doc_Comms to comms\n");

      /* alten Block freigeben */
      FreeMem(doc->doc_Comms,doc->doc_CommsBufLen);
      DEBUG_PRINTF("    doc->doc_Comms freed\n");
    }

    /* neuen Block in Struktur vermerken */
    doc->doc_Comms      =comms;
    doc->doc_CommsBufLen=buflen;
    DEBUG_PRINTF("    doc->doc_Comms & doc_CommsBufLen replaced with comms & buflen\n");

    DEBUG_PRINTF("    -- returning --\n\n");
    return(TRUE);
  }

  /* Fehler */
  DEBUG_PRINTF("    error on allocating comms\n    -- returning --\n\n");
  return(FALSE);
}

/* ======================================================================================= End of File
*/
