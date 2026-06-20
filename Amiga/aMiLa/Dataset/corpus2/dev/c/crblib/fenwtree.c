
#include <crbinc/inc.h>
#include <crbinc/fenwtree.h>

void HalveFenwickTreeLong(long * ProbTree,long ProbTreeLen,long NumSymbols,long * TotProbPtr)
{
long OldValues[32],NewValues[32];
long i,j,ZeroCount,SumOld,SumNew;

for(i=1;i<ProbTreeLen;i++)
  {
  j = i;
  for(ZeroCount=0; !(j&1); j >>= 1)
    ZeroCount++;

  OldValues[ZeroCount] = ProbTree[i];

  SumOld = SumNew = 0;
  for(j=ZeroCount-1;j>=0;j--)
    {
    SumOld += OldValues[j];
    SumNew += NewValues[j];
    }

  ProbTree[i] -= SumOld;
  ProbTree[i] >>= 1;
  ProbTree[i] += SumNew;

  NewValues[ZeroCount] = ProbTree[i];
  }

/* get totprob */
  {
  long GotCWork,GotCParent;
  long LowProb,HighProb,SharedProb;

  GotCWork = NumSymbols;
  ProbTree_GetRange(ProbTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

  *TotProbPtr = HighProb; 
  }
/* end get totprob */

}

/*
 * no add one
 *
 */
void HalveFenwickTreeUword(uword * ProbTree,long ProbTreeLen,long NumSymbols,uword * TotProbPtr)
{
uword OldValues[32],NewValues[32];
long i,j,ZeroCount,SumOld,SumNew;

for(i=1;i<ProbTreeLen;i++)
  {
  j = i;
  for(ZeroCount=0; !(j&1); j >>= 1)
    ZeroCount++;

  OldValues[ZeroCount] = ProbTree[i];

  SumOld = SumNew = 0;
  for(j=ZeroCount-1;j>=0;j--)
    {
    SumOld += OldValues[j];
    SumNew += NewValues[j];
    }

  ProbTree[i] -= SumOld;
  ProbTree[i] >>= 1;
  ProbTree[i] += SumNew;

  NewValues[ZeroCount] = ProbTree[i];
  }

/* get totprob */
  {
  long GotCWork,GotCParent;
  long LowProb,HighProb,SharedProb;

  GotCWork = NumSymbols;
  ProbTree_GetRange(ProbTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent);

  *TotProbPtr = HighProb; 
  }
/* end get totprob */

}

