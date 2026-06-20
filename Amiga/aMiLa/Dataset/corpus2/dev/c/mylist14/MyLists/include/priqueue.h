/*
         PriQueue.h
         ----------
         Header file for implementation of a generic priority queue as
         a single linked list and MAX_PRI+1 priorities.
         
         Author: Chris De Maeyer
         Date  : 25-02-1995
         
         (C) 1994-95 Blue Heaven Software - All rights reserved.
*/

#ifndef PRIQUEUE_H
#define PRIQUEUE_H
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
#define PRIQUEUE_MAX INT_MAX  /* Max number of entries (nodes) */
#define MAX_PRI      15       /* highest (first served) */
#define MIN_PRI      0        /* lowest (last served) */

/* Status */  
#define PRIQUEUE_OK         0
#define PRIQUEUE_FULL      -1
#define PRIQUEUE_EMPTY     -2
#define PRIQUEUE_GETNODE   -3
#define PRIQUEUE_MEMORY    -4
#define PRIQUEUE_LOW       -5
#define PRIQUEUE_HIGH      -6
/* Type */
typedef struct PriQueueNode
{
        struct PriQueueNode *next;
        void                *data;
        short               pri;
} PRIQUEUENODE;

typedef struct PriQueue
{
        PRIQUEUENODE     *head;
        PRIQUEUENODE     *priNodes[MAX_PRI+1]; /* ptrs to buckets */
        int              nr_nodes;  /* Current number of entries */
        int              data_len;  /* Length of data entry */
} PRIQUEUE;
                         
/* Functions */
PRIQUEUE *PriQueue_Create(int len);     /* Allocate queue */
void PriQueue_Free(PRIQUEUE *theQueue); /* Deallocate queue */

void PriQueue_Clear(PRIQUEUE *theQueue);/* Remove all entries */

int IsPriQueue_Empty(PRIQUEUE *theQueue);/* TRUE for empty queue */
int IsPriQueue_Full(PRIQUEUE *theQueue); /* TRUE for full queue */

int PriQueue_Size(PRIQUEUE *theQueue);  /* Gets number of entries */

int PriQueue_Enqueue(PRIQUEUE *theQueue,
                     void *ndata,short pri); /* Enqueue (add) entry */
int PriQueue_Serve(PRIQUEUE *theQueue,
                     void *ndata,short *pri);/* Serve (delete) entry */

/* Support functions */
PRIQUEUENODE *PriQueue_GetNode(PRIQUEUE *theQueue);/* Allocate an entry */
void PriQueue_FreeNode(PRIQUEUENODE *theNode);  /* Deallocate entry */
PRIQUEUENODE *FindPri(PRIQUEUE *theQueue,short pri);
  /* find last node with a higher priority than pri */

/* end */
