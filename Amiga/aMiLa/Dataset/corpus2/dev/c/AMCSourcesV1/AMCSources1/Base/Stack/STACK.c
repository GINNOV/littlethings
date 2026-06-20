/* 
 *
 *  Pila
 *
 *  Stack
 *
 */

#include "stack.h"

void StackCreate(TSTACK *s,int isize){
   TSITEM *p;
   CALLOC(p,TSITEM*,isize,sizeof(TSITEM));
   s->stack=p;
   s->size=isize;
   s->current=0;
   }

void StackFree(TSTACK *s){
   FREE(s->stack);
   s->stack = NULL;
   }

void StackPush (TSTACK *s,TSITEM i){
   if (s->stack==NULL) FATAL(Stack inesistente);
   if (StackIsFull(s)) FATAL(Stack Pieno);
   s->stack[s->current]=i;
   s->current++;
   }

TSITEM StackRead (TSTACK *s){
   if (s->stack==NULL) FATAL(Stack inesistente);
   if (StackIsEmpty(s)) FATAL(Stack Vuoto);
   return(s->stack[s->current-1]);
   }

TSITEM StackPop(TSTACK *s){
   if (s->stack==NULL) FATAL(Stack inesistente);
   if (StackIsEmpty(s)) FATAL(Stack Vuoto);
   s->current--;
   return s->stack[s->current];
   }

int StackIsEmpty(TSTACK *s){
   if (s->stack==NULL) FATAL(Stack inesistente);
   return(s->current==0);
   }

int StackIsFull(TSTACK *s){
   if (s->stack==NULL) FATAL(Stack inesistente);
   return(s->current==(s->size));
   }

void StackErase(TSTACK *s) {
   FREE(s->stack);
   s->current=0;
   s->stack=NULL;
   s->size=0;
   }

