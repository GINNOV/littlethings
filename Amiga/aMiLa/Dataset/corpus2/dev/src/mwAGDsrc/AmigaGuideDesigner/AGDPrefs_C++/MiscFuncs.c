/*
** PROGRAMM:  AmigaGuideDesigner Preferences
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     MiscFuncs.c
** FUNKTION:  einige selbstgestrickte Funktionen
**
*/

#include "AGDPrefs.h"

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

/* ======================================================================================== GetNodeNum
** ermittelt die Nummer einer Node
*/
LONG GetNodeNum(struct Node *node)
{
  LONG i=0;

  while (node->ln_Pred->ln_Pred)
  {
    node=node->ln_Pred;
    i++;
  }

  return(i);
}

/* ======================================================================================= GetNodeAddr
** ermittelt die Struktur einer Node
*/
struct Node *GetNodeAddr(struct List *l,LONG num)
{
  LONG i;
  struct Node *node=l->lh_Head;

  for (i=0;i<num && node->ln_Succ->ln_Succ;i++)
  {
    node=node->ln_Succ;
  }

  return(node);
}

/* ======================================================================================= End of File
*/

