/*
 *
 *  Lista Bilinkata, no dummy
 *
 *  Bilinked list, no dummy
 *
 */

#include "listblct.h"
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
   if (p==NULL) FATAL ("Lista mai inizializzata");
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
   if (l==NULL) FATAL ("Lista mai inizializzata");
   p=create(i);
   p->next=l->head;
   p->prev=NULL;
   l->head=p;
   if (l->nelem!=0)  p->next->prev=p;
     else   l->tail=p;
   l->nelem++;
   }

void ListPutBach(TL* l,TLITEM i) {
   PTLELEM p;
   int a;
   if (l==NULL) FATAL ("Lista mai inizializzata");
   if (l->nelem==0) {
                     ListPutFront(l,i);
                     return; }
   p=create(i);
   l->tail->next=p;
   p->prev=l->tail;
   p->next=NULL;
   l->tail=p;
   l->nelem++;
   }

TLITEM ListGetFront(TL* l){
   PTLELEM p;
   TLITEM i;
   if (l==NULL) FATAL ("Lista mai inizializzata");
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   i=l->head->info;
   p=l->head;
   l->head=l->head->next;
   if (l->nelem!=1)  p->next->prev=NULL;
           else {l->head=NULL;
                 l->tail=NULL;}
   l->nelem--;
   FREE(p);
   return i;
   }

TLITEM ListGetBack(TL*l){
   TLITEM i;
   int a;
   if (l==NULL) FATAL ("Lista mai inizializzata");
   if (ListIsEmpty(l)) FATAL("GET su lista vuota");
   i=l->tail->info;
   if (l->nelem==1)       {FREE (l->tail);
                           l->tail=NULL;
                           l->head=NULL;}
    else {
                 l->tail=l->tail->prev;
                 FREE(l->tail->next);
                 l->tail->next=NULL;   }
   l->nelem--;
   return(i);  }

int ListIsEmpty(TL *l){
     if (l==NULL) FATAL ("Lista mai inizializzata");
     return (l->nelem==0);
   }

void ListAtFront(TL*l){
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  l->current=l->head;
  }

int ListNext(TL*l){
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)||l->current==NULL) FATAL("Puntatore corrente indefinito o lista vuota");
  if (l->current->next==NULL) return(1!=1);
  l->current=l->current->next;
  return(1==1);
  }

int ListPrevious(TL *l) {
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  if (l->current==l->head) return(1!=1);
  l->current=l->current->prev;
  return (1==1);
  }

void ListAtTail(TL*l){
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  l->current=l->tail;
  }


TLITEM ListReadCurrent(TL *l){
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  return(l->current->info);
  }

TLITEM ListGetCurrent(TL*l){
  PTLELEM p;
  TLITEM i;
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)) FATAL("GET su lista vuota");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  if (l->nelem==1) return (ListGetFront(l));
  i=l->current->info;
  p=l->current;
  p->prev->next=p->next;
  if (l->tail==l->current) p->next=NULL;
         else
             p->next->prev=p->prev;
  FREE(p);
  l->nelem--;
  return i;}

void ListPutAfterCurrent(TL*l,TLITEM el){
  PTLELEM p;
  if (l==NULL) FATAL ("Lista mai inizializzata");
  if (ListIsEmpty(l)) FATAL("Lista vuota nessun elemento a cui puntare");
  if (l->current==NULL) FATAL("Puntatore corrente non definito");
  p=create (el);
  p->prev=l->current;
  if (l->current==l->tail) {p->next=NULL;
                            l->tail=p;}
      else
        {  p->next=l->current->next;
           l->current->next->prev=p;}
  l->current->next=p;
  l->nelem++;
  }
