
/***

has bugs.  See CCtest.c 

probably in ProbTree_FindTarget and/or excluded order(-1)

***/

#include <crbinc/inc.h>
#include <crbinc/arithc.h>
#include <crbinc/fenwtree.h>

#define CCTYPE_ORDERN 1 /* order-1 & higher only*/
#define CCTYPE_ORDER0 2 /* ->Prev contains order -1 info*/

struct ContextStats
  {
  struct ContextStats * Prev; /*pointer to next lower order*/
  struct FAI * FAI;
  long Type;
  long EscapeFreq;
  long NumSymbols;
  long ProbTreeLen;
  long TotProb;
  long TotProb_ScalePoint;
  long * ProbTree;
  };

struct ContextStats * ContextUtil_Init(struct FAI * FAI,long NumSymbols,long TotProb_ScalePoint,long Type);
void ContextUtil_CleanUp(struct ContextStats * CS);

long ContextUtil_DecodeC(struct ContextStats * CS);
void ContextUtil_EncodeC(struct ContextStats * CS,long GotC);

struct ContextStats * ContextUtil_Init(struct FAI * FAI,long NumSymbols,long TotProb_ScalePoint,long Type)
{
struct ContextStats * CS;

if ( (CS = malloc(sizeof(struct ContextStats))) == NULL )
  return(NULL);

MemClearMacro(CS,sizeof(struct ContextStats));

CS->ProbTreeLen = 1;
while( CS->ProbTreeLen < (NumSymbols+1) ) CS->ProbTreeLen <<= 1;

if ( (CS->ProbTree = malloc(sizeof(long)*CS->ProbTreeLen)) == NULL )
  {
  ContextUtil_CleanUp(CS);
  return(NULL);
  }

MemClearMacroFast(CS->ProbTree,CS->ProbTreeLen);

CS->FAI = FAI;

CS->EscapeFreq = 1;
CS->TotProb = 1;
CS->NumSymbols = NumSymbols;
CS->TotProb_ScalePoint = min(TotProb_ScalePoint,FAI->FastArithCumProbMax);
CS->Type = Type;

if ( Type == CCTYPE_ORDER0 )
  {
  long i,j;
  long * ExcludeTree;

  if ( (CS->Prev = malloc(sizeof(long)*CS->ProbTreeLen)) == NULL )
    {
    ContextUtil_CleanUp(CS);
    return(NULL);
    }
  MemClearMacroFast(CS->Prev,CS->ProbTreeLen);

  ExcludeTree = (long *) CS->Prev;

  for(i=0;i<NumSymbols;i++)
    {
    j = i + 1;
    ProbTree_Update(ExcludeTree,CS->ProbTreeLen,j);
    }
  ExcludeTree[0] = NumSymbols;
  }

return(CS);
}

void ContextUtil_FixExcludeTree(struct ContextStats * CS)
{
long i,j,k,P,NumSymbols,TotP;
long *ExcludeTree,*ProbTree;

NumSymbols = CS->NumSymbols;
ExcludeTree = (long *)CS->Prev;
ProbTree = CS->ProbTree;

MemClearMacroFast(ExcludeTree,CS->ProbTreeLen);

TotP=0;
for(i=0;i<NumSymbols;i++)
  {
  j = i + 1;
  ProbTree_GetProb(ProbTree,j,P,k);
  if( !P )
    {
    TotP++;
    j = i + 1;
    ProbTree_Update(ExcludeTree,CS->ProbTreeLen,j);
    }
  }
ExcludeTree[0] = TotP;
}

void ContextUtil_CleanUp(struct ContextStats * CS)
{
if ( CS->ProbTree ) free(CS->ProbTree);
if ( CS->Type == CCTYPE_ORDER0 && CS->Prev )
  if ( CS->Prev ) free(CS->Prev);
if ( CS ) free(CS);
}

/*
 * decode a char from the Context model & then update it
 *
 */
long ContextUtil_DecodeC(struct ContextStats * CS)
{
long GotCWork,GotCParent,MidC,GotC;
long LowProb,HighProb,SharedProb,TargetProb;
long ProbTotal,ProbTreeLen;
long * ProbTree;
long EscapeFreq;

EscapeFreq = CS->EscapeFreq;
ProbTreeLen = CS->ProbTreeLen;
ProbTree = CS->ProbTree;
ProbTotal = CS->TotProb;

FastArithDecodeRange(CS->FAI,&TargetProb,ProbTotal);

if ( TargetProb < EscapeFreq ) /*an escpae*/
  {
  FastArithDecodeRangeRemove(CS->FAI,0,EscapeFreq,ProbTotal);

  if ( CS->Type == CCTYPE_ORDER0 )
    {
    long * ExcludeTree;

    ExcludeTree = (long *) CS->Prev;

    FastArithDecodeRange(CS->FAI,&TargetProb,ExcludeTree[0]);

    ProbTree_FindTarget(ExcludeTree,ProbTreeLen,GotC,TargetProb,MidC);

    GotCWork = GotC + 1;
    ProbTree_GetRange(ExcludeTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

    GotCWork = GotC + 1;
    ProbTree_Update_Variable(ExcludeTree,ProbTreeLen,GotCWork,-1);

    FastArithDecodeRangeRemove(CS->FAI,LowProb,HighProb,ExcludeTree[0]);

    ExcludeTree[0] --;
    }
  else if ( CS->Type == CCTYPE_ORDERN )
    {
    if ( CS->Prev ) GotC = ContextUtil_DecodeC(CS->Prev);
    else
      {
      /* error */
      }
    }
  else
    {
    /* error */
    }

  EscapeFreq++;
  ProbTotal++;
  }
else
  {
  TargetProb -= EscapeFreq; /*pull off the escape*/

  ProbTree_FindTarget(ProbTree,ProbTreeLen,GotC,TargetProb,MidC);

  GotCWork = GotC + 1;
  ProbTree_GetRange(ProbTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

  /*make space for the escape*/
  LowProb += EscapeFreq; 
  HighProb+= EscapeFreq;
  FastArithDecodeRangeRemove(CS->FAI,LowProb,HighProb,ProbTotal);

  if ( HighProb == LowProb + 1 )
    {
    if ( EscapeFreq > 1 )
      {
      EscapeFreq--;
      ProbTotal--;
      }
    }
  }

GotCWork = GotC + 1;
ProbTree_Update(ProbTree,ProbTreeLen,GotCWork);
ProbTotal ++;

if ( ProbTotal > CS->TotProb_ScalePoint )
  {
  ProbTotal -= EscapeFreq;
  HalveFenwickTreeLong(ProbTree,ProbTreeLen,CS->NumSymbols,&ProbTotal);
  EscapeFreq >>= 1;
  EscapeFreq ++;
  ProbTotal += EscapeFreq;

  if ( CS->Type == CCTYPE_ORDER0 )
    ContextUtil_FixExcludeTree(CS);
  }

CS->TotProb = ProbTotal;
CS->EscapeFreq = EscapeFreq;

return(GotC);
}

/*
 * encode a char with the Context model & then update it
 *
 */
void ContextUtil_EncodeC(struct ContextStats * CS,long GotC)
{
long GotCWork,GotCParent;
long LowProb,HighProb,SharedProb;
long ProbTotal,ProbTreeLen;
long * ProbTree;
long EscapeFreq;

EscapeFreq = CS->EscapeFreq;
ProbTreeLen = CS->ProbTreeLen;
ProbTree = CS->ProbTree;
ProbTotal = CS->TotProb;

GotCWork = GotC + 1;
ProbTree_GetRange(ProbTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

if ( HighProb > LowProb )
  {
  /*make space for the escape*/
  LowProb  += EscapeFreq;
  HighProb += EscapeFreq;
  }
else
  {
  /*write an escape*/
  LowProb = 0;
  HighProb = EscapeFreq;
  }

FastArithEncodeRange(CS->FAI,LowProb,HighProb,ProbTotal);

if ( LowProb < EscapeFreq )
  {
  if ( CS->Type == CCTYPE_ORDER0 )
    {
    long * ExcludeTree;

    ExcludeTree = (long *) CS->Prev;

    GotCWork = GotC + 1;
    ProbTree_GetRange(ExcludeTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

    FastArithEncodeRange(CS->FAI,LowProb,HighProb,ExcludeTree[0]);

    GotCWork = GotC + 1;
    ProbTree_Update_Variable(ExcludeTree,ProbTreeLen,GotCWork,-1);

    ExcludeTree[0] --;  
    }
  else if ( CS->Type == CCTYPE_ORDERN )
    {
    if ( CS->Prev ) ContextUtil_EncodeC(CS->Prev,GotC);
    else
      {
      }
    }
  else
    {
    }

  EscapeFreq++;
  ProbTotal++;
  }
else if ( HighProb == LowProb + 1 )
  {
  if ( EscapeFreq > 1 ) 
    {
    EscapeFreq--;
    ProbTotal--;
    }
  }

GotCWork = GotC + 1;
ProbTree_Update(ProbTree,ProbTreeLen,GotCWork);
ProbTotal ++;

if ( ProbTotal > CS->TotProb_ScalePoint )
  {
  ProbTotal -= EscapeFreq;
  HalveFenwickTreeLong(ProbTree,ProbTreeLen,CS->NumSymbols,&ProbTotal);
  EscapeFreq >>= 1;
  EscapeFreq ++;
  ProbTotal += EscapeFreq;

  if ( CS->Type == CCTYPE_ORDER0 )
    ContextUtil_FixExcludeTree(CS);
  }

CS->TotProb = ProbTotal;
CS->EscapeFreq = EscapeFreq;

}
