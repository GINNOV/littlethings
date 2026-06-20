
#include <stdlib.h>
#include <GAP.h>
#include "GAPLocal.h"
#define i4A(n) (((long **)t1La->Polys)[n])
void DeletePopulation(struct Population *);void DeletePopulation(struct Population *t1La)
{int i;void (*s4O)(void *);s4O = (void (*)(void *)) l5T(t1La,t7X(KILL));if(s4O!=NULL) {
for(i=0;i!=t1La->NumPolys;i++) {(*s4O)(i4A(i));free(i4A(i));}} else {for(i=0;
i!=t1La->NumPolys;i++) {free(i4A(i));}}free((void *)l5T(t1La,t7X(PBOX)));y8E(t1La);
free(t1La->Polys);free(t1La);}