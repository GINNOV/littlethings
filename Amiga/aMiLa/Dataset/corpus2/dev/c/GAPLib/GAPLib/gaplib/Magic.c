
#include <stdlib.h>
#include <GAP.h>
IPTR l5T(struct Population *,unsigned long int);void n9N(struct Population *,IPTR,unsigned long int);
void f9P(struct Population *,IPTR,unsigned long int);void y8E(struct Population *);
struct Magic {struct Magic *Next;unsigned long int id;IPTR Magic;};IPTR l5T(struct Population *t1La,unsigned long int id)
{struct Magic *M;M = t1La->Magic;while(M!=0 && M->id!=id) {M = M->Next;}if(M!=0) {
return(M->Magic);}return(0L);}void n9N(struct Population *t1La,IPTR b1R,unsigned long int id)
{struct Magic *M;M = malloc(sizeof(struct Magic));M->Next = t1La->Magic;t1La->Magic = M;
M->id = id;M->Magic = b1R;}void f9P(struct Population *t1La,IPTR b1R,unsigned long int id)
{struct Magic *M;M = t1La->Magic;while(M!=0 && M->id!=id) {M = M->Next;}if(M!=0) {
M->Magic = b1R;} else {n9N(t1La,b1R,id);}}void y8E(struct Population *t1La)
{struct Magic *M,*N;M = t1La->Magic;while(M!=0) {N = M->Next;free(M);M = N;
}}