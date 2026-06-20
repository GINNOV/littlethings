
#include <GAP.h>
#include <math.h>
void l3Z (void *,void *,int);double e6M(void *,void *,int);void y6C (void *,int);
double h5J(long int,long int);void l3Z (void *j1H,void *q0M,int y2M){Crossover(j1H,q0M,Rnd((long)y2M<<3),(long)y2M);
}double e6M(void *j1H,void *q0M,int y2M){return((double)HammingDist(j1H,q0M,y2M));
}void y6C (void *j1H,int y2M) {int i;for(i=0;i!=(y2M<<3);i++) {if (Rnd (1024) == 512) {
Flip(j1H,(long)i);}}}double h5J(long int Generation,long int PopSize){double d;
const double y4W=2.722; d = pow((1.0+1.0/Generation),(double)Generation);return(PopSize*(y4W-d));
}