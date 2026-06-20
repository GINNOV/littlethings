/* 
 *
 *  Coda bounded, implementata con array dinamico
 *
 *  Bounded Queue, implemented with dynamic array
 *
 */

#ifndef CODA
#define CODA
#include <stdlib.h>
#include <stdio.h>
#include "myerror.h"


typedef int TQITEM;
typedef struct s {TQITEM *queue;
                  int size;
                  int first,last;
                  int current;
                  }TQUEUE;
extern void QueueCreate(TQUEUE*,int);
extern TQITEM QueueGet (TQUEUE*);
extern void QueuePut (TQUEUE*,TQITEM);
extern int QueueIsFull(TQUEUE*);  
extern int QueueIsEmpty(TQUEUE*);
#endif
