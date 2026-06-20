
#include <math.h>
#include <GAP.h>
#include "GAPLocal.h"
#ifndef z3H
#define z3H(x) ((x)*(x))
#endif
double q2M(struct Population *t1La,double r9F);double q2M(struct Population *t1La,double r9F)
{int i;double y4K;struct r5X *y4E;y4E = (struct r5X *)l5T(t1La,t7X(PBOX));y4K = 0;
for(i=0;i!=t1La->NumPolys;i++) {y4K += z3H(y4E[i].c8Y-r9F);}return(sqrt(y4K/t1La->NumPolys));
}