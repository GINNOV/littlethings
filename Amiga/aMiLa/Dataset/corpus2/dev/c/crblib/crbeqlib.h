#ifndef _CRBEQLIB_H
#define _CRBEQLIB_H

#include <crbinc/inc.h>

/* ** THE CRBEQ OPTIMIZING EQUATION COMPILER*/

struct EqData
  {
  double Result;
  double X,Y,Z,T;
  int ParseError;
  char *ErrorMess;
  char **DebugMess;

  double *UserVar; int NumUserVars;
  
  ubyte *EQ;          int EQSize;
  double *PreStored;  int PreStoredSize;
  double *Store;      int StoreSize;
  char *StrEq;        int StrEqSize;
  char *WrkBase;
  char *WrkPtr;
  char *RepPtr;
  int DebugMessNext;
  int Flags;
  int CurPreStoreNum;
  int CurStoreNum;  
  int CPos;
  int SLen;

  char **Tokens;
  int TokNum;
  char *TokWork;
  int TokWorkCnt;
  char **OrdTerms;
  ubyte *OrdPri;
  char *OrdWork;
  };

extern double           ValCRBEQ(struct EqData *d);
extern struct EqData * MakeCRBEQ(char *StrEQ,int Flags);
extern void            FreeCRBEQ(struct EqData *EqData);
extern int             CopyCRBEQ(struct EqData *FromEqData,
                                struct EqData **ToEqData);
extern void            HelpCRBEQ(void);

/* 'Flags' values:*/
#define DEBUG    (1<<0) /*show lots of Debug info*/
#define OPTIMIZE (1<<1) /*optimize CRBEQ (post-parse optimizations)*/

#endif
