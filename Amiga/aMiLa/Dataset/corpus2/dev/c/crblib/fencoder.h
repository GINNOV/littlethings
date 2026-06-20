#ifndef _CONTEXTCODER_H
#define _CONTEXTCODER_H

/*
 * you must set ->Prev yourself
 *  if you want more than order-(0)-(-1) context coding
 *
 */

#include <crbinc/inc.h>
#include <crbinc/arithc.h>
#include <crbinc/fenwtree.h>

#define CCTYPE_ORDERN 1 /* order-1 & higher only*/
#define CCTYPE_ORDER0 2 /* ->Prev contains order -1 info*/

struct ContextStats
  {
  struct ContextStats * Prev; /*pointer to next lower order*/

  long RestIsPrivate;
  };

extern struct ContextStats * ContextUtil_Init(struct FAI * FAI,
  long NumSymbols,long TotProb_ScalePoint,long Type);
extern void ContextUtil_CleanUp(struct ContextStats * CS);

extern long ContextUtil_DecodeC(struct ContextStats * CS);
extern void ContextUtil_EncodeC(struct ContextStats * CS,long GotC);

#endif
