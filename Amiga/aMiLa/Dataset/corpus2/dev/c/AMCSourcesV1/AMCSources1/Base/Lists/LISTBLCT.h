/*
 *
 * Lista bilinkata, no dummy
 *
 * Bilinked list, no dummy
 *
 */

#ifndef LISTEBL
#define LISTEBL
#include <stdlib.h>
#include <stdio.h>
#include "myerror.h"


typedef int TLITEM;
typedef struct s1 *PTLELEM;
typedef struct s1{ TLITEM info;
                   PTLELEM next;
                   PTLELEM prev;
                   }TLELEM;
typedef struct s2{PTLELEM head;
                  PTLELEM tail;
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
extern void ListAtTail(TL*);
extern int ListNext(TL*);
extern int ListPrevious(TL*);
extern TLITEM ListReadCurrent(TL*);
extern TLITEM ListGetCurrent(TL*);
extern void ListPutAfterCurrent(TL*,TLITEM);
#endif
