#include <crbinc/inc.h>
#include <crbinc/memutil.h>
#include <crbinc/arithc.h>

struct Order0Info
  {
  /* copied in from user */
  struct FAI * FAI;
  long NumSymbols;

  /* my stuff */
  long * CharCounts;
  long CharCountTot;
  long EscapeCount;
  };

/*externs:*/
extern void CleanUp(char * ExitMess);

/*protos:*/
void Order0_CleanUp(struct Order0Info * O0I);

/*functions:*/

struct Order0Info * Order0_Init (struct FAI * FAI,long NumSymbols)
{
struct Order0Info * Ret;

if ( (Ret = AllocMem(sizeof(struct Order0Info),MEMF_ANY|MEMF_CLEAR)) == NULL )
  return(NULL);

Ret->NumSymbols = NumSymbols;
Ret->FAI = FAI;
Ret->EscapeCount = 1;
Ret->CharCountTot = 0;

if ( (Ret->CharCounts = AllocMem(NumSymbols*sizeof(long),MEMF_ANY|MEMF_CLEAR)) == NULL )
  { free(Ret); return(NULL); }

return(Ret);
}

void Order0_EncodeC(struct Order0Info * O0I,long Symbol,ubyte * ExcludeMask)
{
long LowProb,TotProb,HighProb,i,NumSymbols;
long * CharCounts;
bool WroteChar;

NumSymbols = O0I->NumSymbols;
CharCounts = O0I->CharCounts;
TotProb    = O0I->EscapeCount;

for(i=0;i<Symbol;i++)
  {
  if ( ! ExcludeMask[i] && CharCounts[i] ) { TotProb += CharCounts[i]; ExcludeMask[i] = 1; }
  }

if ( CharCounts[Symbol] )
  {
  LowProb = TotProb;
  TotProb = HighProb = LowProb + CharCounts[Symbol];
  WroteChar = 1;
  }
else
  {
  LowProb = 0;
  HighProb = O0I->EscapeCount;
  WroteChar = 0;
  }

for(i=Symbol+1;i<NumSymbols;i++)
  {
  if ( ! ExcludeMask[i] && CharCounts[i] ) { TotProb += CharCounts[i]; ExcludeMask[i] = 1; }
  }

FastArithEncodeRange(O0I->FAI,LowProb,HighProb,TotProb);

if ( CharCounts[Symbol] < 2 )
  {
  if ( CharCounts[Symbol] == 0 )
    {
    CharCounts[Symbol] = 1;
    O0I->EscapeCount ++;
    }
  else
    {
    CharCounts[Symbol] = 2;
    if ( O0I->EscapeCount > 1 ) O0I->EscapeCount --;
    }
  }
else
  {
  CharCounts[Symbol] ++;
  }

if ( (++O0I->CharCountTot) > O0I->FAI->FastArithCumProbMaxSafe )
  {
  O0I->CharCountTot = 0;
  for(i=0;i<NumSymbols;i++) { CharCounts[i] >>= 1; O0I->CharCountTot += CharCounts[i]; }
  }

if ( ! WroteChar )
  {
  /* use order -1 */

  LowProb = 0;
  for(i=0;i<Symbol;i++)
    {
    LowProb += 1 - ExcludeMask[i];
    }
  TotProb = LowProb;
  for(;i<NumSymbols;i++)
    {
    TotProb += 1 - ExcludeMask[i];
    }
  FastArithEncodeRange(O0I->FAI,LowProb,LowProb+1,TotProb);
  }

return;
}

void Order0_DecodeC(struct Order0Info * O0I,long * SymbolPtr,ubyte * ExcludeMask)
{
long TargetProb,LowProb,TotProb,HighProb,i;
long * CharCounts;
long Symbol,NumSymbols;

NumSymbols = O0I->NumSymbols;
CharCounts = O0I->CharCounts;
TotProb    = O0I->EscapeCount;

for(i=0;i<NumSymbols;i++)
  {
  if ( ! ExcludeMask[i] && CharCounts[i] ) TotProb += CharCounts[i];
  }

FastArithDecodeRange(O0I->FAI,&TargetProb,TotProb);

if ( TargetProb < O0I->EscapeCount )
  {
  FastArithDecodeRangeRemove(O0I->FAI,0,O0I->EscapeCount,TotProb);

  for(i=0;i<NumSymbols;i++)
    {
    if ( CharCounts[i] ) ExcludeMask[i] = 1;
    }

  /** decode with order -1 **/

  TotProb = 0;
  for(i=0;i<NumSymbols;i++) TotProb += 1 - ExcludeMask[i];

  FastArithDecodeRange(O0I->FAI,&TargetProb,TotProb);

  LowProb = 0;
  Symbol = 0x10000;
  for(i=0;i<NumSymbols;i++)
    {
    if ( ExcludeMask[i] == 0 )
      {
      if ( TargetProb == 0 ) { Symbol = i; break; }
      TargetProb--;
      LowProb++;
      }
    }

  FastArithDecodeRangeRemove(O0I->FAI,LowProb,LowProb+1,TotProb);

  if ( O0I->CharCounts[Symbol] != 0 )
    CleanUp(" Escaped when CharCounts[Symbol] != 0 ");
  
  O0I->CharCounts[Symbol] = 1;
  O0I->EscapeCount ++;
  
  }
else
  {
  TargetProb -= O0I->EscapeCount;
  Symbol = NumSymbols;
  LowProb = O0I->EscapeCount;
  for(i=0;i<NumSymbols;i++)
    {
    if ( ! ExcludeMask[i] && CharCounts[i] )
      {
      TargetProb -= CharCounts[i];
      if ( TargetProb < 0 )
        { HighProb = LowProb + CharCounts[i]; Symbol = i; break; }
      LowProb += CharCounts[i];
      }
    }

  if ( Symbol == NumSymbols )
    CleanUp("Error : Symbol not found in Order0!");

  FastArithDecodeRangeRemove(O0I->FAI,LowProb,HighProb,TotProb);

  if ( CharCounts[Symbol] < 2 )
    {
    if ( CharCounts[Symbol] == 0 )
      {
      CharCounts[Symbol] = 1;
      O0I->EscapeCount ++;
      }
    else
      {
      CharCounts[Symbol] = 2;
      if ( O0I->EscapeCount > 1 ) O0I->EscapeCount --;
      }
    }
  else
    {
    CharCounts[Symbol] ++;
    }

  }

if ( (++O0I->CharCountTot) >  O0I->FAI->FastArithCumProbMaxSafe )
  {
  O0I->CharCountTot = 0;
  for(i=0;i<NumSymbols;i++) { CharCounts[i] >>= 1; O0I->CharCountTot += CharCounts[i]; }
  }

*SymbolPtr = Symbol;

return;
}

void Order0_CleanUp(struct Order0Info * O0I)
{
FreeMem(O0I,sizeof(struct Order0Info));
}
