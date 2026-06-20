/* 
 *
 *  Lista semplice, Dummy element
 *
 *  Simple list, dummy element
 *
 */

#ifndef LISTE
#define LISTE

#include <stdlib.h>
#include <stdio.h>
#include "myerror.h"


typedef int TLITEM;
typedef struct s1 *PTLELEM;
typedef struct s1{ TLITEM info;
                   PTLELEM next;
                   }TLELEM;
typedef struct s2{PTLELEM head;
                  int nelem;
                  PTLELEM current;
                  }TL;
extern void ListCreate(TL*); 
extern void ListDelete(TL*);
extern void ListPutFront(TL*,TLITEM);
extern void ListPutBack(TL*,TLITEM);
extern TLITEM ListGetFront(TL*);
extern TLITEM ListGetBack(TL*);
extern int ListIsEmpty(TL*);
extern void ListAtFront(TL*);
extern void ListAtEnd(TL*);
extern int ListNext(TL*);
extern int ListRetry(TL*);
extern TLITEM ListReadCurrent(TL*);
extern TLITEM ListGetCurrent(TL*);
extern void ListPutAfterCurrent(TL*,TLITEM);
extern void ListBubbleSort(TL*);

#endif
