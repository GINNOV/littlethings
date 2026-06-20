
#include "GAPLocal.h"
unsigned long int HammingDist(void *,void *,const int);static const int u6K[16] = {
0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4};unsigned long int HammingDist(void *f7V,void *u8A,const int Bytes)
{int i,t;unsigned long d=0;unsigned char *i0=f7V,*i1=u8A;for(i=0;i<Bytes;i++) {
t = i0[i]^i1[i];d += u6K[t&0xf]+u6K[t>>4];}return(d);}