/* 
 *
 *  Pila
 *
 *  Stack
 *
 */

#ifndef STAcK
#define STAcK
#include <stdlib.h>
#include <stdio.h>
#include "myerror.h"

typedef int TSITEM;
typedef struct { TSITEM *stack;
                 int current;
                 int size;
                 }TSTACK;

extern void StackCreate(TSTACK*,int);
extern void StackFree(TSTACK *);
extern TSITEM StackPop(TSTACK*);
extern void StackPush(TSTACK*,TSITEM);
extern TSITEM StackRead(TSTACK*);
extern int StackIsFull(TSTACK*);
extern int StackIsEmpty(TSTACK*);
#endif
