/*  
 *
 * Lista semplice, dummy element
 *
 * Simple list, dummy element
 *
 */

#include "lista.h"

static PTLELEM create(TLITEM i){
   PTLELEM p;
   MALLOC(p,PTLELEM,sizeof(TLELEM));
   p->info=i;
   p->next=NULL;
   return p;
   }

void ListDelete(TL* p){
   int i;
   for (i=1;i<=p->nelem;i++)
       ListGetFront(p);
   FREE(p->head);
   return;
   }

void ListCreate(TL*l){
     PTLELEM p;
     p=create(0);
     l->head=p;
     l->current=NULL;
     l->nelem=0;
     }

void ListPutFront(TL* l,TLITEM i) {
   PTLELEM p;
   p=create(i);
   p->next=l->head;
   l->head=p;
   l->nelem++;
   }

void ListPutBack(TL* l,TLITEM i) {
   PTLELEM p,d;
   int a;
   if (l->nelem==0) {
                     ListPutFront(l,i);
                     return; }
   p=create(i);
   d=l->head;
   for (a=2;a<=(l->nelem);a++)
        d=d->next;
   p->next=d->next;
   d->next=p;
   l->nelem++;
   }

TLITEM ListGetFront(TL* l){
   PTLELEM p;
   TLITEM i;
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   i=l->head->info;
   p=l->head;
   l->head=l->head->next;
   l->nelem--;
   FREE(p);
   return i;
   }

TLITEM ListGetBack(TL*l){
   PTLELEM p,d;
   TLITEM i;
   int a;
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   d=l->head;
   if (l->nelem==1) { i=d->info;
                      l->head=d->next;
                      FREE(d);
                    }
    else {

          for (a=2;a<=(l->nelem-1);a++)
          d=d->next;
          p=d->next;
          i=p->info;
          d->next=p->next;
          FREE(p);          }
   l->nelem--;
   return(i);  }

int ListIsEmpty(TL *l){
     return (l->nelem==0);
   }

void ListAtFront(TL*l){
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  l->current=l->head;
  }

int ListNext(TL*l){
  if (ListIsEmpty(l)||l->current==NULL) FATAL("Puntatore corrente indefinito o lista vuota");
  if (l->current->next->next==NULL) return(1!=1);
  l->current=l->current->next;
  return(1==1);
  }

int ListRetry(TL *l) {
  PTLELEM p,d;
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  p=l->current;
  ListAtFront (l);
  if (l->current==p) return(1!=1);
  while (p!=l->current)
  {d=l->current;
   ListNext(l);}
   l->current=d;
   return (1==1);
  }

void ListAtEnd(TL*l){
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  ListAtFront(l);
  while (ListNext(l));}


TLITEM ListReadCurrent(TL *l){
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  return(l->current->info);
  }

TLITEM ListGetCurrent(TL*l){
  PTLELEM p;
  TLITEM i;
  if (ListIsEmpty(l)) FATAL("GET su lista vuota");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  i=l->current->info;
  p=l->current;
   if (p==l->head) l->head=p->next;
    else{
          ListRetry(l);
          l->current->next=p->next; }
  FREE(p);
  l->nelem--;
  return i;}

void ListPutAfterCurrent(TL*l,TLITEM el){
  PTLELEM p;
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  p=create (el);
  p->next=l->current->next;
  l->current->next=p;
  l->nelem++;
  }

  /* implementazione dell'algoritmo BUBBLE SORT su lista */

static swap(TL*l){
   TLITEM a;
   a=l->current->info;
   l->current->info=l->current->next->info;
   l->current->next->info=a;
   }

void ListBubbleSort(TL*l){
   int swapflag,k=0,i=0;
   do {
     swapflag=0;
     ListAtFront(l);
     for (i=0;i<l->nelem-k-1;i++)
       {
        if(l->current->info>l->current->next->info)
           {
           swap(l);
           swapflag=1;
           }
        ListNext(l);
        }
     k++;
     }
   while (swapflag);
}
