
#include <GAP.h>
#include "GAPLocal.h"
#ifdef GAPDEBUG
#include <stdio.h>
#endif
void *PopMember(struct Population *,const long int);
#define i4A(n) (((long **)t1La->Polys)[n])
void *PopMember(struct Population *t1La,const long int n)
{
#ifdef GAPDEBUG
if(n>0 && n<t1La->NumPolys) {return(i4A(n));} else {fprintf(stderr,"\x50\x6f\x70\x4d\x65\x6d\x62\x65\x72\x3a\x20\x49\x6e\x64\x65\x78\x20\x6f\x75\x74\x20\x6f\x66\x20\x72\x61\x6e\x67\x65\x2c\x20\x25\x64\x20\x6e\x6f\x74\x20\x69\x6e\x20\x5b\x30\x2c\x25\x64\x5d\x2e\n",n,t1La->NumPolys-1);
return(0);}
#else
return(i4A(n));
#endif
}