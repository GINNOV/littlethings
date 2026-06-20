#include <crbinc/inc.h>
#include <crbinc/memutil.h>
#include <crbinc/arithc.h>

struct O0coderInfo
  {
  /* copied in from user */
  struct FAI * FAI;
  long NumChars;

  /* my stuff */
  long * CharCounts;
  long CharCountTot;
  long EscapeCount;
  };

/*externs:*/
extern void CleanUp(char * ExitMess);

/*protos:*/
void O0coder_CleanUp(struct O0coderInfo * O0I);

/*functions:*/

struct O0coderInfo * O0coder_Init (struct FAI * FAI,long NumChars)
{
struct O0coderInfo * Ret;

if ( (Ret = AllocMem(sizeof(struct O0coderInfo),MEMF_CLEAR)) == NULL )
  return(NULL);

Ret->NumChars = NumChars;
Ret->FAI = FAI;
Ret->EscapeCount = 1;
Ret->CharCountTot = 0;

if ( (Ret->CharCounts = AllocMem(NumChars*sizeof(long),MEMF_CLEAR)) == NULL )
  { free(Ret); return(NULL); }

return(Ret);
}

void O0coder_AddC(struct O0coderInfo * O0I,long Char)
{
long * CharCounts;

CharCounts = O0I->CharCounts;

if ( CharCounts[Char] == 0 )
  {
  O0I->EscapeCount ++;
  }
else if ( CharCounts[Char] == 1 && O0I->EscapeCount > 1 )
  {
  O0I->EscapeCount --;
  }

CharCounts[Char] ++;

if ( (++O0I->CharCountTot) > 16000 )
  {
  int i,NumChars = O0I->NumChars;
  O0I->CharCountTot = 0;
  for(i=0;i<NumChars;i++)
    { CharCounts[i] >>= 1; O0I->CharCountTot += CharCounts[i]; }
  }

return;
}

void O0coder_EncodeC(struct O0coderInfo * O0I,long Char)
{
long TotProb,i;
long * CharCounts;

CharCounts = O0I->CharCounts;
TotProb    = O0I->EscapeCount + O0I->CharCountTot;

if ( CharCounts[Char] )
  {
  long LowProb = O0I->EscapeCount;

  for(i=0;i<Char;i++)
    LowProb += CharCounts[i];

  FastArithEncodeRange(O0I->FAI,LowProb,LowProb+CharCounts[Char],TotProb);
  }
else
  {
  long LowProb = 0,NumChars = O0I->NumChars;

  FastArithEncodeRange(O0I->FAI,0,O0I->EscapeCount,TotProb);

  /* use order -1 */

  for(i=0;i<Char;i++)
    if ( !CharCounts[i] ) LowProb++;

  TotProb = LowProb;
  for(;i<NumChars;i++)
    if ( !CharCounts[i] ) TotProb++;

  FastArithEncodeRange(O0I->FAI,LowProb,LowProb+1,TotProb);
  }

O0coder_AddC(O0I,Char);

return;
}

long O0coder_DecodeC(struct O0coderInfo * O0I)
{
long TargetProb,LowProb,TotProb,i;
long * CharCounts;
long Char,NumChars;

NumChars   = O0I->NumChars;
CharCounts = O0I->CharCounts;
TotProb    = O0I->EscapeCount + O0I->CharCountTot;

FastArithDecodeRange(O0I->FAI,&TargetProb,TotProb);

if ( TargetProb < O0I->EscapeCount )
  {
  FastArithDecodeRangeRemove(O0I->FAI,0,O0I->EscapeCount,TotProb);

  /** decode with order -1 **/

  TotProb = 0;
  for(i=0;i<NumChars;i++)
    if ( !CharCounts[i] ) TotProb++;

  FastArithDecodeRange(O0I->FAI,&TargetProb,TotProb);

  LowProb = 0;
  Char = 0x10000;
  for(i=0;i<NumChars;i++)
    {
    if ( !CharCounts[i] )
      {
      if ( TargetProb == 0 )
        { Char = i; break; }
      TargetProb--;
      LowProb++;
      }
    }

  if ( Char == 0x10000 || CharCounts[Char] != 0 )
    CleanUp("Order0coder major error");

  FastArithDecodeRangeRemove(O0I->FAI,LowProb,LowProb+1,TotProb);
  }
else
  {
  TargetProb -= O0I->EscapeCount;
  Char = NumChars;
  LowProb = O0I->EscapeCount;
  for(i=0;i<NumChars;i++)
    {
    TargetProb -= CharCounts[i];
    if ( TargetProb < 0 )
      { Char = i; break; }
    LowProb += CharCounts[i];
    }

  if ( Char == NumChars )
    CleanUp("Error : Char not found in Order0!");

  FastArithDecodeRangeRemove(O0I->FAI,LowProb,LowProb + CharCounts[Char],TotProb);
  }

O0coder_AddC(O0I,Char);

return(Char);
}

void O0coder_CleanUp(struct O0coderInfo * O0I)
{
smartfree( O0I->CharCounts );
free(O0I);
}
