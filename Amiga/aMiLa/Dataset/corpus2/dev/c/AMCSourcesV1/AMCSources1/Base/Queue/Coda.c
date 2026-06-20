/*
 *
 *  Coda bounded, implementata con array dinamico
 *
 *  Bounded Queue, implemented with dynamic array
 *
 */

#include "coda.h"


static void incfirst(TQUEUE*q){
  q->first++;
  if (q->first==q->size) q->first=0;
  }
static void inclast(TQUEUE*q){
  q->last++;
  if (q->last==q->size) q->last=0;
  }

void QueueCreate (TQUEUE*q,int isize){
    TQITEM*p;
    CALLOC(p,TQITEM*,isize,sizeof(TQITEM));
    q->queue=p;
    q->size=isize;
    q->current=0;
    q->last=0;
    q->first=0;/* fasullo*/
}

void QueuePut(TQUEUE*q,TQITEM i){
if (!QueueIsFull(q)) {
     q->queue[q->last]=i;
     q->current++;
     inclast(q);
     }
     else
     FATAL (PUT su coda piena);
}

int QueueIsFull(TQUEUE*q){
return (q->current==q->size);
}

int QueueIsEmpty(TQUEUE*q){
return (q->current==0);
}

TQITEM QueueGet(TQUEUE*q){
    TQITEM p;
    if (!QueueIsEmpty(q)){
    p=q->queue[q->first];
    q->current--;
    incfirst(q);
    return(p);}
    else
    FATAL (GET su coda vuota);
}
