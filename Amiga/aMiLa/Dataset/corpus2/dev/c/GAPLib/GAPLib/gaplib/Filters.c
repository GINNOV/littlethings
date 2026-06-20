#include <stdio.h>
#include <math.h>
#include <float.h>
#include <GAP.h>
#include "GAPLocal.h"
double z5P(struct Population *t1La,double c6W,void *data,int r1F);double z5P(struct Population *t1La,double c6W,void *data,int r1F)
{struct r5X *y4E;double (*f1Z)(long int,long int);double sum = 0.0,c0W,mean,stddev,r9F;
int i;if(r1F==f3P) {return(c6W);}y4E = (struct r5X *)l5T(t1La,t7X(PBOX));r9F = c6W/t1La->NumPolys;
switch(r1F) {case m6C:f1Z = (double (*)(long int,long int))data;c0W = (*f1Z)(t1La->Generation,t1La->NumPolys);
if(c0W>0.0) {sum = 0.0;for(i=0;i!=t1La->NumPolys;i++) {y4E[i].c8Y = exp((y4E[i].c8Y-r9F)/c0W);
sum += y4E[i].c8Y;}} else {fprintf(stderr,"\x45\x76\x6f\x6c\x76\x65\x2f\x47\x41\x50\x46\x69\x6c\x74\x65\x72\x3a\x20\x49\x6c\x6c\x65\x67\x61\x6c\x20\x74\x65\x6d\x70\x65\x72\x61\x74\x75\x72\x65\x20\x25\x66\x21\n",c0W);
sum = c6W;}break;case c2Y:if(!((t1La->Flags&l3B) && (t1La->Generation == t1La->Stat.Generation))) {
stddev = q2M(t1La,r9F);} else {stddev = t1La->Stat.StdDeviation;}if(stddev>DBL_EPSILON) { 
mean = y4E[t1La->NumPolys>>1].c8Y;mean = ((t1La->NumPolys)&1)?mean:(mean+y4E[(t1La->NumPolys>>1)-1].c8Y)/2.0;
sum = 0.0;for(i=0;i!=t1La->NumPolys;i++) {y4E[i].c8Y = 1.0 + (y4E[i].c8Y-mean)/(2.0*stddev);
if(y4E[i].c8Y<=0.0) {y4E[i].c8Y = 0.05; }sum += y4E[i].c8Y;}} break;default:
fprintf(stderr,"\x45\x76\x6f\x6c\x76\x65\x2f\x47\x41\x50\x46\x69\x6c\x74\x65\x72\x3a\x20\x49\x6e\x76\x61\x6c\x69\x64\x20\x66\x69\x6c\x74\x65\x72\x20\x74\x79\x70\x65\x2c\x20\x69\x6e\x74\x65\x72\x6e\x61\x6c\x20\x65\x72\x72\x6f\x72\x2e\n");sum = c6W;
}return(sum);}