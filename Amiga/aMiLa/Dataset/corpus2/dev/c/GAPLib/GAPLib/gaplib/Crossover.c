
#include <stdio.h>
#include <stdlib.h>
#include "GAPLocal.h"
void Crossover (void *,void *,const long int At,const long int y2M);void Crossover(void *I1,void *I2,const long int At,const long int y2M)
{char *f7V,*u8A;int i,n,t;unsigned char y2Y;n = (At>>3);f7V = (char *)I1;u8A = (char *)I2;
for(i=n+1;i<y2M;i++) {t = f7V[i];f7V[i] = u8A[i];u8A[i] = t;}y2Y = 0xff>>(At&7);
i = f7V[n];t = u8A[n];f7V[n] &= ~y2Y;f7V[n] |= t&y2Y;u8A[n] &= ~y2Y;u8A[n] |= i&y2Y;
}