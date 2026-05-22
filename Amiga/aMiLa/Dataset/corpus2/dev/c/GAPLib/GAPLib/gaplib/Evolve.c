
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <float.h>
#include <math.h>
#include <GAP.h>
#include "GAPLocal.h"
#ifndef DBL_EPSILON 
#define DBL_EPSILON (2e-16)
#endif
#define i4A(n) (((long **)t1La->Polys)[n])
#ifndef z3H
#define z3H(x) ((x)*(x))
#endif
#define x9N(t,v) fprintf(stderr,"*** Error %d *** Evolve: Illegal value (%ld) for tag %s!\n",__LINE__,v,#t)
#define m4Gj(t) fprintf(stderr,"*** Error %d *** Evolve: Illegal NULL value for tag %s!\n",__LINE__,#t)
struct Population *Evolve (struct Population *, struct TagItem *);struct Population *EvolveT (struct Population *,...);
static int e8G (const struct r5X *j1H, const struct r5X *q0M);static int i2M(const double *,const double *);
struct Population *Evolve (struct Population *t1La, struct TagItem *o6Y){void (*v7H) (void *,int) = y6C;
void (*v5D) (void *, void *,int) = l3Z;double (*j7J) (void *,void *,int) = e6M;
double (*r9P) (void *) = NULL;double (*f1Z) (long int,long int) = h5J;void (*j5H)(void *);
 void (*a2Q)(void *);struct r5X *y4E=NULL;void *j1H=0,*q0M=0; double sum=0, y4K=0, b7V=0, f5H, d5X=0, q8K=0;
int i,n,t;int q=0,q2=0;int b9R = ~0, h7T = 0, z9L = DRANDOM;int n1Z = 0,i8U = 0, f9Z = 0;
long n7N = 0, s8G = 0, d3B = 0;Tag tag = TAG_DONE;int w6M, r1F;void *b7T=NULL;
 if (o6Y != NULL) {tag = o6Y[0].ti_Tag;}i = 0;while (tag != TAG_DONE) { switch (tag) {
case EVL_Evaluator:r9P = (double (*)(void *)) o6Y[i].ti_Data;break;case EVL_Transcriber:
fprintf(stderr,"\x54\x72\x61\x6e\x73\x63\x72\x69\x70\x74\x69\x6f\x6e\x20\x6e\x6f\x74\x20\x79\x65\x74\x20\x69\x6d\x70\x6c\x65\x6d\x65\x6e\x74\x65\x64\x2c\x20\x73\x6f\x72\x72\x79\x2e\n");break;case EVL_Newbies:
d3B = o6Y[i].ti_Data;if(d3B<0 || d3B>t1La->NumPolys) {x9N(EVL_Newbies,d3B);d3B = 0;
}break;case EVL_Mutator:v7H = (void (*)(void *,int)) o6Y[i].ti_Data;break;
case EVL_Select:z9L = o6Y[i].ti_Data;if(z9L<x5L || z9L>g0U) {x9N(EVL_Select,(long int)z9L);
z9L = DRANDOM;}break;case EVL_PreMutate:h7T = o6Y[i].ti_Data;break;case EVL_Elite: 
n7N = o6Y[i].ti_Data;if(n7N<0 || n7N>t1La->NumPolys) {x9N(EVL_Elite,n7N);n7N = 0;
}break;case EVL_Stats:b9R = o6Y[i].ti_Data;break;case EVL_Dump:s8G = o6Y[i].ti_Data;
if(s8G<0 || s8G>t1La->NumPolys) {x9N(EVL_Dump,s8G);s8G = 0;}break;case EVL_Crosser:
v5D = (void (*)(void *, void *,int)) o6Y[i].ti_Data;if(v5D==NULL) {m4Gj(EVL_Crosser);
v5D=l3Z;}break;case EVL_Mensurator:j7J = (double (*)(void *,void *,int)) o6Y[i].ti_Data;
if(j7J==NULL) {m4Gj(EVL_Mensurator);j7J = e6M;}break;case EVL_Crowding:n1Z = (int) o6Y[i].ti_Data;
break;case EVL_InitDumped:f9Z = (int) o6Y[i].ti_Data;break;case EVL_EraseBest:
i8U = (int) o6Y[i].ti_Data;break;case EVL_Thermostat:f1Z = (double (*) (long int,long int)) o6Y[i].ti_Data;
if(f1Z==NULL) {m4Gj(EVL_Thermostat);f1Z = h5J;}break;case EVL_Flags:n = (int) o6Y[i].ti_Data;
n1Z = n&FLG_Crowding;f9Z = n&FLG_InitDumped;i8U = n&FLG_EraseBest;b9R = n&FLG_Statistics;
break;case TAG_IGNORE:break;case TAG_MORE:o6Y = (struct TagItem *) o6Y[i].ti_Data;
i = -1;if(o6Y==0) {m4Gj(TAG_MORE);tag = TAG_DONE;continue;}break;default:
fprintf (stderr, "\x45\x76\x6f\x6c\x76\x65\x3a\x20\x55\x6e\x72\x65\x63\x6f\x67\x6e\x69\x7a\x65\x64\x20\x74\x61\x67\x20\x28\x30\x78\x25\x6c\x78\x29\x21\n", tag);} tag = o6Y[++i].ti_Tag;
} if(r9P != NULL && t1La!=NULL) {w6M = t1La->Bytes;if((q0M = malloc((size_t)w6M))!=NULL && (j1H=malloc((size_t)w6M))!=NULL) {
y4E = (struct r5X *) l5T(t1La,t7X(PBOX));j5H = (void (*)(void *)) l5T(t1La,t7X(INIT));
a2Q = (void (*)(void *)) l5T(t1La,t7X(KILL));for(i = 0; i != t1La->NumPolys; i++) {
if((y4E[i].j1H = malloc((size_t)w6M))==NULL) {fprintf (stderr, "\x2a\x2a\x2a\x20\x45\x72\x72\x6f\x72\x20\x25\x64\x20\x2a\x2a\x2a\x20\x45\x76\x6f\x6c\x76\x65\x3a\x20\x4e\x6f\x20\x46\x72\x65\x65\x20\x53\x74\x6f\x72\x65\x2e\n",__LINE__);
for(n=0;n<i;n++) {free(y4E[i].j1H);}free(q0M);return(0);}memcpy ((y4E[i].j1H), i4A(i), (size_t)w6M);
if(!(t1La->Flags&c4U)) {y4E[i].c8Y = (*r9P)(y4E[i].j1H);}sum += y4E[i].c8Y;
}t1La->Flags &= ~c4U;if(n7N>0 || s8G>0 || (z9L!=TOURNAMENT && z9L!=FITPROP && z9L!=UNIVERSAL) || i8U>0) { 
qsort(y4E, (size_t)t1La->NumPolys, sizeof (struct r5X), (int(*)(const void *,const void *))e8G);
}if(d3B>0) { for(i=0;i!=d3B;i++) {if(i8U==0) {n=Rnd(t1La->NumPolys); } else {
n = i;}sum-=y4E[n].c8Y;if(a2Q!=NULL) {(*a2Q)(y4E[n].j1H);}if(j5H==(void (*)(void *))ZERO_INIT) {
memset(y4E[n].j1H,0,(size_t)w6M);} else if(j5H==(void (*)(void *))RAND_INIT) {
for(t=0;t!=w6M;t++) {((char *)y4E[n].j1H)[t]=Rnd(256);}} else {(*j5H)(y4E[n].j1H);
}y4E[n].c8Y = (*r9P)(y4E[n].j1H);sum += y4E[n].c8Y;}}if((h7T) && (v7H!=NULL)) {
for(i = 0; i != t1La->NumPolys; i++) {(*v7H)(y4E[i].j1H,w6M);}}for(i = 0; i < s8G;
 i++) { n = t1La->NumPolys-(i+1);if(f9Z!=0) {sum -= y4E[n].c8Y;if(a2Q!=NULL) {
(*a2Q)(y4E[n].j1H);}if(j5H!=NULL) {(*j5H)(y4E[n].j1H);}y4E[n].c8Y = (*r9P)(y4E[n].j1H);
sum += y4E[n].c8Y;} else {memcpy(y4E[n].j1H, y4E[i].j1H,(size_t)w6M);y4E[n].c8Y = y4E[i].c8Y;
}}switch(z9L) {case TEMPERATURE:r1F = m6C;b7T = (void *)f1Z;break;case SIGMA:
r1F = c2Y;break;default:r1F = f3P;}sum = z5P(t1La,sum,b7T,r1F);if(n1Z==0) { 
for(i = 0; i < n7N; i++) { memcpy(i4A(i), y4E[i].j1H, (size_t)w6M);}}i = n7N;
t = 0;n = 0;if(z9L==UNIVERSAL) {d5X = sum/(double)t1La->NumPolys;b7V = q8K = 0.0;
y4K = 0.0;q = -1;q2 = t1La->NumPolys;}while(i < t1La->NumPolys) { switch(z9L) {
case DRANDOM:n = Rnd((long)t1La->NumPolys-1)+1; t = Rnd((long)n); break;case TEMPERATURE: 
case SIGMA: case FITPROP:y4K = InRand(0.0,sum);b7V = y4E[0].c8Y;n = 0;while(b7V<y4K) {
n++;b7V += y4E[n].c8Y;}y4K = InRand(0.0,sum);b7V = y4E[0].c8Y;t = 0;while(b7V<y4K) {
t++;b7V += y4E[t].c8Y;}break;case UNIVERSAL:y4K += d5X;if(b7V>=y4K) {n = q;
} else {do {b7V += y4E[++q].c8Y;if(q>=t1La->NumPolys) { q = t1La->NumPolys-1;
break;}} while(b7V<=y4K);n = q;}if(q8K>=y4K) {t = q2;} else {do {q8K += y4E[--q2].c8Y;
if(q2<0) { q2 = 0;break;}} while(q8K<=y4K);t = q2;}break;case TOURNAMENT:
t = Rnd(t1La->NumPolys);n = Rnd(t1La->NumPolys);q = Rnd(t1La->NumPolys);n = (y4E[n].c8Y>y4E[q].c8Y)?n:q;
q = Rnd(t1La->NumPolys);t = (y4E[t].c8Y>y4E[q].c8Y)?t:q;break;case INORDER:
n++;if(n==t1La->NumPolys) {n=0;t++;if(t==t1La->NumPolys) {t=0;}}break;default:
fprintf(stderr, "\x2a\x2a\x2a\x20\x45\x72\x72\x6f\x72\x20\x25\x64\x20\x2a\x2a\x2a\n\x45\x76\x6f\x6c\x76\x65\x3a\x20\x55\x6e\x6b\x6e\x6f\x77\x6e\x20\x53\x65\x6c\x65\x63\x74\x69\x6f\x6e\x20\x4d\x65\x74\x68\x6f\x64\x20\x28\x25\x64\x29\x21\n",__LINE__,z9L);
return(0);}if(n1Z==0) {memcpy(i4A(i), y4E[t].j1H, (size_t)w6M);memcpy(q0M, y4E[n].j1H, (size_t)w6M);
(*v5D)(i4A(i),q0M,w6M);} else {memcpy(j1H,y4E[t].j1H,(size_t)w6M);memcpy(q0M, y4E[n].j1H, (size_t)w6M);
(*v5D)(j1H,q0M,w6M);q = 0;y4K = DBL_MAX;for(q2=0;q2!=t1La->NumPolys;q2++) { 
f5H = (*j7J)(j1H,i4A(q2),w6M);if(f5H<y4K) {y4K = f5H;q = q2;}}memcpy(i4A(q),j1H,(size_t)w6M);
 }i++;} if ((!h7T) && (v7H!=NULL)) {for (i = 0; i != t1La->NumPolys; i++) {
(*v7H)(i4A(i),w6M);}}for(i=0;i!=t1La->NumPolys;i++) {free(y4E[i].j1H);}free(j1H);
free(q0M);} else { if(j1H)free(j1H);if(q0M)free(q0M);fprintf (stderr, "\x2a\x2a\x2a\x20\x45\x72\x72\x6f\x72\x20\x25\x64\x20\x2a\x2a\x2a\x20\x45\x76\x6f\x6c\x76\x65\x3a\x20\x4e\x6f\x20\x46\x72\x65\x65\x20\x53\x74\x6f\x72\x65\x2e\n",__LINE__);
return(0);}if (b9R) {double maxv,minv,type=0,r9F,e2K;void *max;double *m0C;
long c2E,tempcount;if(t1La->Flags&l3B) {t1La->Flags|=c4U;}t1La->Stat.Generation = t1La->Generation+1;
m0C = malloc((size_t)t1La->NumPolys * sizeof(double));if(m0C!=NULL) {maxv=sum=0;
max = i4A(0);for (i = 0; i != t1La->NumPolys; i++) {y4K = (*r9P) (i4A(i));y4E[i].c8Y = m0C[i] = y4K;
sum += y4K;if (y4K > maxv) { maxv = y4K; max = (void *)i4A(i);}}qsort(m0C,(size_t)t1La->NumPolys,sizeof(double),(int(*)(const void *,const void *))i2M);
minv = m0C[t1La->NumPolys-1];if(t1La->NumPolys&1) {t1La->Stat.MedianFitness = m0C[(t1La->NumPolys)>>1];
} else {t1La->Stat.MedianFitness = ((m0C[(t1La->NumPolys)>>1])+(m0C[((t1La->NumPolys)>>1)-1]))/2;
}i=0;c2E = -1;while(i<t1La->NumPolys) {tempcount=0;while(fabs(m0C[i]-m0C[i+1])<DBL_EPSILON && i<(t1La->NumPolys-1)) {
i++;tempcount++;}i++;tempcount++;if(tempcount>c2E) {c2E=tempcount;type = m0C[i-1];
}}r9F = (sum / t1La->NumPolys);e2K = q2M(t1La,r9F);free(m0C);t1La->Stat.AverageFitness = r9F;
t1La->Stat.MaxFitness = maxv;t1La->Stat.MinFitness = minv;t1La->Stat.Max = max;
t1La->Stat.TypeFitness = type;t1La->Stat.TypeCount = c2E;t1La->Stat.StdDeviation = e2K;
} else {fprintf(stderr,"\x45\x76\x6f\x6c\x76\x65\x3a\x20\x4e\x6f\x20\x66\x72\x65\x65\x20\x73\x74\x6f\x72\x65\x20\x74\x6f\x20\x63\x72\x65\x61\x74\x65\x20\x73\x74\x61\x74\x69\x73\x74\x69\x63\x73\x2e\n");t1La->Stat.Max=NULL;
}}} else {if(r9P==NULL) {fprintf (stderr, "\x45\x76\x6f\x6c\x76\x65\x3a\x20\x52\x65\x71\x75\x69\x72\x65\x64\x20\x61\x74\x74\x72\x69\x62\x75\x74\x65\x20\"\x45\x56\x4c\x5f\x45\x76\x61\x6c\x75\x61\x74\x6f\x72\"\x20\x6d\x69\x73\x73\x69\x6e\x67\x2e\n");
} else {fprintf(stderr,"\x45\x76\x6f\x6c\x76\x65\x3a\x20\x49\x6c\x6c\x65\x67\x61\x6c\x20\x4e\x55\x4c\x4c\x20\x50\x6f\x70\x75\x6c\x61\x74\x69\x6f\x6e\x20\x70\x6f\x69\x6e\x74\x65\x72\x2e\n");}}f9P(t1La,t1La->NumPolys,t7X(SIZE));
t1La->Generation++;return (t1La);}struct Population *EvolveT (struct Population *t1La,...)
{va_list ap;int i=0;struct TagItem o6Y[64]; va_start(ap,t1La);while((o6Y[i].ti_Tag = va_arg(ap,Tag)),o6Y[i].ti_Tag != TAG_DONE && o6Y[i].ti_Tag != TAG_MORE) {
o6Y[i].ti_Data = va_arg(ap,IPTR);i++;}if(o6Y[i].ti_Tag == TAG_MORE) {o6Y[i].ti_Data = va_arg(ap,IPTR);
if(o6Y[i].ti_Data == 0) {m4Gj(TAG_MORE);o6Y[i].ti_Tag = TAG_DONE;}}va_end(ap);
return (Evolve (t1La,o6Y));}static int e8G (const struct r5X *t1H, const struct r5X *w4G)
{double d1,d2;d1 = t1H->c8Y;d2 = w4G->c8Y;return((d1>d2)?-1:(d1==d2)?0:1);}
static int i2M(const double *a,const double *b){double d1,d2;d1 = *a;d2 = *b;
return((d1>d2)?-1:(d1==d2)?0:1);}