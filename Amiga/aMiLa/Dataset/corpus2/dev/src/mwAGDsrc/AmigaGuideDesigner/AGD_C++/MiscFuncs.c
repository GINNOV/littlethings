/*
** PROGRAMM:  AmigaGuideDesigner
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     MiscFuncs.c
** FUNKTION:  einige selbstgestrickte Funktionen
**
*/

/*#define DEBUG*/
#include "AGD.h"

#ifdef DEBUG
#define PRINTPSEATTRIBS \
  printf("pse->String: %s\n" \
         "pse->SLen:   %d\n" \
         "pse->Seq:    %d\n", \
          pse->String, \
          pse->SLen, \
          pse->Seq)
#else
#define PRINTPSEATTRIBS
#endif

struct PrefsStringEntry {
                         struct MinNode  Node;
                         char           *String;
                         ULONG           SLen;
                         UBYTE           Seq;
                        };

char *PSSeqs={
              "A" /* [A]guidename */
              "G" /* a[G]uidepath */
              "D" /* [D]atabase   */
              "C" /* [C]opyright  */
              "T" /* au[T]hor     */
              "V" /* [V]ersion    */
              "M" /* [M]aster     */
              "I" /* [I]ndex      */

              "N" /* [N]odename   */
              "P" /* [P]revnode   */
              "X" /* ne[X]tnode   */
              "F" /* [F]ilename   */
              "\0"
             };

/* ============================================================================================ strdup
** legt einen neuen Speicherbereich an und kopiert einen String dorthin
*/
char *mstrdup(const char *src)
{
  char *dst=NULL;

  /* Speicher anfordern und String kopieren */
  if (src)
  {
    ULONG len=strlen(src);

    if (len>0 && (dst=(char *)AllocVec(len+1,MEMF_ANY|MEMF_PUBLIC|MEMF_CLEAR)))
      strcpy(dst,src);
  }

  /* neuen String-Zeiger zurückgeben */
  return(dst);
}

/* ================================================================================= FormatPrefsString
** setzt in einen Prefs-String mit Formatierungssequenzen die entsprechenden Werte ein
*/
char *FormatPrefsString(const char *format,struct Document *doc,ULONG not)
{
  struct MinList           ps;
  struct PrefsStringEntry *pse;
  struct Document         *doc2;
  char                    *c,*d,*lastseq;
  char                    *prefsstring=NULL;
  ULONG                    pslen,len;

  NewList((struct List *)&ps);

  /* parsen */
  for (c=lastseq=(char *)format;*c;c++)
  {
    if (*c=='%' && *(c+1))
    {
      for (d=PSSeqs;*d;d++)
      {
        if (toupper(*(c+1))==*d)
        {
          if (pse=(struct PrefsStringEntry *)
              AllocMem(sizeof(struct PrefsStringEntry),MEMF_ANY|MEMF_PUBLIC))
          {
            DEBUG_PRINTF("    pse allocated\n");

            pse->SLen=c-lastseq;

            if (pse->String=(char *)
                AllocVec(pse->SLen+1,MEMF_ANY|MEMF_PUBLIC))
            {
              strncpy(pse->String,lastseq,pse->SLen);
              pse->String[pse->SLen]=0;
            }

            pse->Seq=d-PSSeqs;

            AddTail((struct List *)&ps,(struct Node *)pse);
            DEBUG_PRINTF("    pse added at tail of ps\n");

            PRINTPSEATTRIBS;
          }

          lastseq=c+2;
        }
      }
    }
  }

  if (pse=(struct PrefsStringEntry *)
      AllocMem(sizeof(struct PrefsStringEntry),MEMF_ANY|MEMF_PUBLIC))
  {
    DEBUG_PRINTF("    rest-of-line-pse allocated\n");

    pse->SLen=c-lastseq+1;

    if (pse->String=(char *)
        AllocVec(pse->SLen+1,MEMF_ANY|MEMF_PUBLIC))
    {
      strncpy(pse->String,lastseq,pse->SLen);
      pse->String[pse->SLen]=0;
    }

    pse->Seq   =PSSEQ_SEQNUM;

    AddTail((struct List *)&ps,(struct Node *)pse);
    DEBUG_PRINTF("    rest-of-line-pse added at tail of ps\n");

    PRINTPSEATTRIBS;
  }

  /* Länge berechnen */
  pslen=0;
  pse=(struct PrefsStringEntry *)ps.mlh_Head;
  while (pse->Node.mln_Succ)
  {
    c=NULL;

    if (!(not&(1L<<pse->Seq)))
    {
      switch (pse->Seq)
      {
        case PSSEQ_AGUIDENAME:
          c=FilePart(AGuide.gt_Name);
          break;

        case PSSEQ_AGUIDEPATH:
          c=AGuide.gt_Name;
          break;

        case PSSEQ_DATABASE:
          c=AGuide.gt_Database;
          break;

        case PSSEQ_COPYRIGHT:
          c=AGuide.gt_Copyright;
          break;

        case PSSEQ_AUTHOR:
          c=AGuide.gt_Author;
          break;

        case PSSEQ_VERSION:
          c=AGuide.gt_Version;
          break;

        case PSSEQ_MASTER:
          c=AGuide.gt_Master;
          break;

        case PSSEQ_INDEX:
          c=AGuide.gt_Index;
          break;

        case PSSEQ_NODENAME:
          c=doc->doc_Node.ln_Name;
          break;

        case PSSEQ_PREVNODE:
          doc2=(struct Document *)doc->doc_Node.ln_Pred;
          if (doc2 && doc2->doc_Node.ln_Pred) c=doc2->doc_Node.ln_Name;
          break;

        case PSSEQ_NEXTNODE:
          doc2=(struct Document *)doc->doc_Node.ln_Succ;
          if (doc2 && doc2->doc_Node.ln_Succ) c=doc2->doc_Node.ln_Name;
          break;

        case PSSEQ_FILENAME:
          c=doc->doc_FileName;
          break;
      }
    }

    pslen+=pse->SLen+strlen(c);

    pse=(struct PrefsStringEntry *)pse->Node.mln_Succ;
  }

  #ifdef DEBUG
    printf("pslen: %d\n",pslen);
  #endif

  /* bauen */
  if (prefsstring=(char *)
      AllocVec(pslen,MEMF_ANY|MEMF_PUBLIC))
  {
    DEBUG_PRINTF("    prefsstring allocated\n");

    c=prefsstring;
    pse=(struct PrefsStringEntry *)ps.mlh_Head;
    while (pse->Node.mln_Succ)
    {
      strncpy(c,pse->String,pse->SLen);
      c+=pse->SLen;

      d=NULL;

      if (!(not&(1L<<pse->Seq)))
      {
        switch (pse->Seq)
        {
          case PSSEQ_AGUIDENAME:
            d=FilePart(AGuide.gt_Name);
            break;

          case PSSEQ_AGUIDEPATH:
            d=AGuide.gt_Name;
            break;

          case PSSEQ_DATABASE:
            d=AGuide.gt_Database;
            break;

          case PSSEQ_COPYRIGHT:
            d=AGuide.gt_Copyright;
            break;

          case PSSEQ_AUTHOR:
            d=AGuide.gt_Author;
            break;

          case PSSEQ_VERSION:
            d=AGuide.gt_Version;
            break;

          case PSSEQ_MASTER:
            d=AGuide.gt_Master;
            break;

          case PSSEQ_INDEX:
            d=AGuide.gt_Index;
            break;

          case PSSEQ_NODENAME:
            d=doc->doc_Node.ln_Name;
            break;

          case PSSEQ_PREVNODE:
            doc2=(struct Document *)doc->doc_Node.ln_Pred;
            if (doc2->doc_Node.ln_Pred) d=doc2->doc_Node.ln_Name;
            break;

          case PSSEQ_NEXTNODE:
            doc2=(struct Document *)doc->doc_Node.ln_Succ;
            if (doc2->doc_Node.ln_Succ) d=doc2->doc_Node.ln_Name;
            break;

          case PSSEQ_FILENAME:
            d=doc->doc_FileName;
            break;
        }
      }

      if (d)
      {
        len=strlen(d);
        strncpy(c,d,len);
        c+=len;

        #ifdef DEBUG
          printf("c-prefsstring: %d\n",c-prefsstring);
        #endif
      }

      pse=(struct PrefsStringEntry *)pse->Node.mln_Succ;
    }

    prefsstring[pslen-1]=0;

    DEBUG_PRINTF("    prefsstring built\n");
  }

  /* freigeben */
  while (pse=(struct PrefsStringEntry *)RemTail((struct List *)&ps))
  {
    if (pse->String)
    {
      FreeVec(pse->String);
      DEBUG_PRINTF("    pse->String freed\n");
    }

    FreeMem(pse,sizeof(struct PrefsStringEntry));
    DEBUG_PRINTF("    pse freed\n");
  }

  return(prefsstring);
}

/* ======================================================================================= End of File
*/

