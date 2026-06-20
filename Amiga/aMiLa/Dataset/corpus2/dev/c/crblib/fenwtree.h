#ifndef _FENWICK_TREE_H
#define _FENWICK_TREE_H

/** bugs ? **/

extern void HalveFenwickTreeLong (long * ProbTree,long ProbTreeLen,long NumSymbols,long * TotProbPtr);
extern void HalveFenwickTreeUword(uword * ProbTree,long ProbTreeLen,long NumSymbols,uword * TotProbPtr);
/* uword version is NoAddOne */

/*
 *
 *  Fenwick tree-maintenance macros:
 *
 */

#define FORW(i) (i + ( i & -i ))
#define BACK(i) (i & ( i - 1 ))

#define ProbTree_Update(ProbTree,ProbTreeLen,GotCWork) \
  while (GotCWork < ProbTreeLen)    \
    {                                       \
    ProbTree[GotCWork] ++;          \
    GotCWork = FORW(GotCWork);              \
    }                                       \
/* end ProbTree_Update macro */

#define ProbTree_Update_Variable(ProbTree,ProbTreeLen,GotCWork,Amount) \
  while (GotCWork < ProbTreeLen)    \
    {                                       \
    ProbTree[GotCWork] += Amount; \
    GotCWork = FORW(GotCWork);              \
    }                                       \
/* end ProbTree_Update_Variable macro */

#define ProbTree_GetRange(ProbTree,GotCWork,LowProb,HighProb,SharedProb,GotCParent) \
{                                                                          \
  LowProb = 0;                                      \
  HighProb = ProbTree[GotCWork];            \
  SharedProb = 0;                                   \
  GotCParent = BACK(GotCWork);                      \
                                                    \
  GotCWork--;                                       \
  while ( GotCWork != GotCParent )                  \
    {                                               \
    LowProb += ProbTree[GotCWork];          \
    GotCWork = BACK(GotCWork);                      \
    }                                               \
                                                    \
  while ( GotCWork > 0 )                            \
    {                                               \
    SharedProb += ProbTree[GotCWork];     \
    GotCWork = BACK(GotCWork);                      \
    }                                               \
                                                    \
  LowProb  += SharedProb;                           \
  HighProb += SharedProb;                           \
}                                                                          \
/* end ProbTree_GetRange macro */


#define ProbTree_FindTarget(ProbTree,ProbTreeLen,GotC,TargetProb,MidC)     \
{                                                                          \
  GotC = 0; TargetProb++;                                                  \
  MidC = ProbTreeLen >> 1;                                                 \
  while ( MidC > 0 )                                                       \
    {                                                                      \
    if ( TargetProb > ProbTree[GotC + MidC] )                              \
      {                                                                    \
      GotC += MidC;                                                        \
      TargetProb -= ProbTree[GotC];                                        \
      }                                                                    \
    MidC >>= 1;                                                            \
    }                                                                      \
  GotC++;                                                                  \
}                                                                          \
/* end ProbTree_FindTarget */



#define ProbTree_GetProb(ProbTree,GotCWork,Prob,GotCParent)\
{                                                                          \
  Prob = ProbTree[GotCWork];                \
  GotCParent = BACK(GotCWork);                      \
  GotCWork--;                                       \
  while ( GotCWork != GotCParent )                  \
    {                                               \
    Prob -= ProbTree[GotCWork];           \
    GotCWork = BACK(GotCWork);                      \
    }                                               \
}                                                                          \
/* end ProbTree_GetRange macro */

#endif /* FENWICK_TREE_H */
