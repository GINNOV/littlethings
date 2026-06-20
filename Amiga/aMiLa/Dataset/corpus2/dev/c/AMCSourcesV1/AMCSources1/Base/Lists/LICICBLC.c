/*  
 *
 *  Lista Bilinkata circolare
 *
 *  Biliked circular list
 *
 */

#include "licicblc.h"

static PTLELEM create(TLITEM i){
   PTLELEM p;
   MALLOC(p,PTLELEM,sizeof(TLELEM));
   p->info=i;
   p->next=NULL;
   p->prev=NULL;
   return p;
   }

void ListErase(TL* p){
   int i;
   for (i=1;i<=p->nelem;i++)
       ListGetFront(p);
   }

void ListCreate(TL*l){
     PTLELEM p;
     l->head=NULL;
     l->current=NULL;
     l->tail=NULL;
     l->nelem=0;
    }

void ListPutFront(TL* l,TLITEM i) {
   PTLELEM p;
   p=create(i);
   p->next=l->head;
   l->head=p;
   if (l->nelem!=0)  {p->next->prev=p;
                      p->prev=l->tail;
                      l->tail->next=p;}
     else   {l->tail=p;
             p->prev=p;
             p->next=p;}
   l->nelem++;
   }

void ListPutBack(TL* l,TLITEM i) {
   PTLELEM p;
   int a;
   if (l->nelem==0) {
                     ListPutFront(l,i);
                     return; }
   p=create(i);
   l->tail->next=p;
   p->prev=l->tail;
   p->next=l->head;
   l->tail=p;
   l->head->prev=p;
   l->nelem++;
   }

TLITEM ListGetFront(TL* l){
   PTLELEM p;
   TLITEM i;
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   i=l->head->info;
   p=l->head;
   l->head=l->head->next;
   if (l->nelem!=1)  {p->next->prev=l->tail;
                      l->tail->next=p->next;
                     }
           else {l->head=NULL;
                 l->tail=NULL;}
   l->nelem--;
   FREE(p);
   return i;
   }

TLITEM ListGetBack(TL*l){
   TLITEM i;
   int a;
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   i=l->tail->info;
   if (l->nelem==1)       {FREE (l->tail);
                           l->tail=NULL;
                           l->head=NULL;}
    else {
                 l->tail=l->tail->prev;
                 FREE(l->tail->next);
                 l->tail->next=l->head;
                 l->head->prev=l->tail;  }
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
  l->current=l->current->next;
  if (l->current==l->head) return(1!=1);
  return(1==1);
  }

int ListPrevious(TL *l) {
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  l->current=l->current->prev;
  if (l->current==l->tail) return(1!=1);
  return (1==1);
  }

void ListAtTail(TL*l){
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  l->current=l->tail;
  }


TLITEM ListReadCurrent(TL *l){
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  return(l->current->info);
  }

TLITEM ListGetCurrent(TL*l){
  PTLELEM p;
  TLITEM i;
  if (ListIsEmpty(l)) FATAL("GET su lista vuota");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  if (l->current==l->head) return(ListGetFront(l));
  if (l->current==l->tail) return(ListGetBach(l));
  i=l->current->info;
  p=l->current;
  p->prev->next=p->next;
  p->next->prev=p->prev;
  l->current=p->next;
  FREE(p);
  l->nelem--;
  return i;}

void ListPutAfterCurrent(TL*l,TLITEM el){
  PTLELEM p,a;
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  p=create (el);
  a=l->current;
  p->prev=l->current;
  p->next=l->current->next;
  l->current->next->prev=p;
  l->current->next=p;
  if (a==l->tail) l->tail=p;
  l->nelem++;
  }
