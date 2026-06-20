/*
         Stack.h
         -------
         Header file for implementation of a generic stack with a single
         linked list.
         
         Author: C. De Maeyer
         Date  : 18-06-1994
         
         (C) 1994 Blue Heaven Software - All rights reserved.
*/
#ifndef STACK_H
#define STACK_H
#endif

#ifndef _LIMITS_H
#include <limits.h>
#endif
#ifndef _STDLIB_H
#include <stdlib.h>
#endif
#ifndef _STRING_H
#include <string.h>
#endif


/* Constants */
#define STACK_MAX INT_MAX     /* Max number of entries */

/* Status */  
#define STACK_OK        0
#define STACK_FULL      -1
#define STACK_EMPTY     -2
#define STACK_GETNODE   -3
#define STACK_MEMORY    -4

/* Type */
typedef struct StackNode
{
        struct StackNode *next;
        void             *data;
} STACKNODE;

typedef struct Stack
{
        STACKNODE        *top;
        int              nr_nodes;  /* Current number of entries */
        int              data_len;  /* Length of data entry */
} STACK;
                         
/* Functions */
STACK *Stack_Create(int len);           /* Allocate stack */
void Stack_Free(STACK *theStack);       /* Deallocate stack */

void Stack_Clear(STACK *theStack);      /* Remove all entries */

int IsStack_Empty(STACK *theStack);     /* TRUE for empty stack */
int IsStack_Full(STACK *theStack);      /* TRUE for full stack */

int Stack_Size(STACK *theStack);        /* Gets number of entries */

int Stack_Push(STACK *theStack,void *ndata); /* Push entry on stack */
int Stack_Pop(STACK *theStack,void *ndata);  /* Pop entry from stack */

/* Support functions */
STACKNODE *Stack_GetNode(STACK *theStack);   /* Allocate an entry node */
void Stack_FreeNode(STACKNODE *theNode);     /* Deallocate entry node */

/* end */
