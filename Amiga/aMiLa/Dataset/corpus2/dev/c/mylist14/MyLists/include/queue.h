/*
         Queue.h
         -------
         Header file for implementation of a generic queue with a single
         linked list.
         
         Author: C. De Maeyer
         Date  : 18-06-1994
         
         (C) 1994 Blue Heaven Software - All rights reserved.
*/

#ifndef QUEUE_H
#define QUEUE_H
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
#define QUEUE_MAX INT_MAX     /* Max number of entries */

/* Status */  
#define QUEUE_OK        0
#define QUEUE_FULL      -1
#define QUEUE_EMPTY     -2
#define QUEUE_GETNODE   -3
#define QUEUE_MEMORY    -4

/* Type */
typedef struct QueueNode
{
        struct QueueNode *next;
        void             *data;
} QUEUENODE;

typedef struct Queue
{
        QUEUENODE        *head;
        QUEUENODE        *tail;
        int              nr_nodes;  /* Current number of entries */
        int              data_len;  /* Length of data entry */
} QUEUE;
                         
/* Functions */
QUEUE *Queue_Create(int len);           /* Allocate queue */
void Queue_Free(QUEUE *theQueue);       /* Deallocate queue */

void Queue_Clear(QUEUE *theQueue);      /* Remove all entries */

int IsQueue_Empty(QUEUE *theQueue);     /* TRUE for empty queue */
int IsQueue_Full(QUEUE *theQueue);      /* TRUE for full queue */

int Queue_Size(QUEUE *theQueue);        /* Gets number of entries */

int Queue_Enqueue(QUEUE *theQueue,void *ndata);/* Enqueue entry on Queue */
int Queue_Serve(QUEUE *theQueue,void *ndata);  /* Serve entry from Queue */

/* Support functions */
QUEUENODE *Queue_GetNode(QUEUE *theQueue);   /* Allocate an entry node */
void Queue_FreeNode(QUEUENODE *theNode);     /* Deallocate entry node */

/* end */
