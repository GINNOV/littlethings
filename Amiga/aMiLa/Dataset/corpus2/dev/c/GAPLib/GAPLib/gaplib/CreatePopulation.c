
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <GAP.h>
#include "GAPLocal.h"
#define i4A(n) (((long **)t1La->Polys)[n])
struct Population *CreatePopulationT(const long int,const long int,...);struct Population *CreatePopulation(const long int,const long int,struct TagItem *);
struct Population *CreatePopulationT(const long int Num,const long int y2M,...)
{va_list ap;int i=0;struct TagItem o6Y[64]; va_start(ap,y2M);while((o6Y[i].ti_Tag = va_arg(ap,Tag))!= TAG_DONE) {
o6Y[i].ti_Data = va_arg(ap,IPTR);i++;}va_end(ap);return (CreatePopulation(Num,y2M,o6Y));
}struct Population *CreatePopulation(const long int Num,const long int y2M,struct TagItem *o6Y)
{struct Population *t1La;int i,n;void (*m8K)(void *)=(void (*)(void *))1L;void (*x1T)(void *)=NULL;
IPTR T;Tag tag;if(y2M!=0) {if((Num>0) && ((t1La=malloc(sizeof(struct Population)))!=NULL)) {
t1La->Magic=0;t1La->Flags=l3B;t1La->NumPolys=Num;t1La->Generation=0;t1La->Bytes=y2M;
t1La->Stat.AverageFitness=0;t1La->Stat.MaxFitness=0;t1La->Stat.MinFitness=0;
t1La->Stat.MedianFitness=0;t1La->Stat.StdDeviation = 0;t1La->Stat.TypeFitness = 0;
t1La->Stat.TypeCount = 0;t1La->Stat.Generation = 0;t1La->Stat.Max=NULL;n9N(t1La,Num,t7X(SIZE));
if(o6Y!=NULL) {i = 0;tag = o6Y[i].ti_Tag;while(tag!=TAG_DONE) {switch(tag) {
case POP_Init:m8K = (void (*)(void *)) o6Y[i].ti_Data;break;case POP_Destruct:
x1T = (void (*)(void *)) o6Y[i].ti_Data;break;case POP_Cache:if(o6Y[i].ti_Data!=0) {
t1La->Flags |= l3B;} else {t1La->Flags &= ~l3B;}break;case TAG_IGNORE:break;
case TAG_MORE:o6Y = (struct TagItem *) o6Y[i].ti_Data;if(o6Y==NULL) {fprintf(stderr,"\x43\x72\x65\x61\x74\x65\x50\x6f\x70\x75\x6c\x61\x74\x69\x6f\x6e\x3a\x20\x49\x6c\x6c\x65\x67\x61\x6c\x20\x4e\x55\x4c\x4c\x20\x76\x61\x6c\x75\x65\x20\x66\x6f\x72\x20\x54\x41\x47\x5f\x4d\x4f\x52\x45\x2e\n");
tag = TAG_DONE;continue;}i = -1;break;default:fprintf(stderr,"\x43\x72\x65\x61\x74\x65\x50\x6f\x70\x75\x6c\x61\x74\x69\x6f\x6e\x3a\x20\x55\x6e\x73\x75\x70\x70\x6f\x72\x74\x65\x64\x20\x54\x61\x67\x20\x28\x30\x78\x25\x6c\x78\x29\x21\n",o6Y[i].ti_Tag);
}tag = o6Y[++i].ti_Tag;} }if(x1T!=NULL){ n9N(t1La,(IPTR)x1T,t7X(KILL)); }n9N(t1La,(IPTR)m8K,t7X(INIT));
if((T = (IPTR)malloc((size_t)(sizeof(struct r5X)*Num)))!=(IPTR)NULL) {n9N(t1La,T,t7X(PBOX));
if((t1La->Polys=malloc((size_t)(sizeof(long *)*Num)))!=NULL) {for(i=0;i!=Num;i++) {
i4A(i) = malloc((size_t)y2M);if(i4A(i)==NULL) {for(i--;i>=0;i--) {free(i4A(i));
}free(t1La->Polys);free(t1La);}}if(m8K==NULL) {for(i=0;i!=Num;i++) {memset(i4A(i),0,(size_t)y2M);
}} else if (m8K==(void (*)(void *))RAND_INIT) {for(i=0;i!=Num;i++) {for(n=0;
n!=y2M;n++) {((char *)i4A(i))[n] = Rnd(256);}}} else {for(i=0;i!=Num;i++)(*m8K)(i4A(i));
}return(t1La);} else {free(t1La);return(NULL); }} else {free(t1La);return(NULL);
}} else {return(NULL); }} else {return(NULL);}}