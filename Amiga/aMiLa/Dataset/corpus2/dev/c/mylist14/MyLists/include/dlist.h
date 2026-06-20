/*
         SList.h
         -------
         Header file for implementation of a generic double linked list.
         
         Author: C. De Maeyer
         Date  : 20-02-1995
         
         (C) 1994 Blue Heaven Software - All rights reserved.
*/

#ifndef DLIST_H
#define DLIST_H
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
#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* Constants */
#define DLIST_MAX INT_MAX     /* Max number of entries */

/* Status */  
#define DLIST_OK        0
#define DLIST_FULL      -1
#define DLIST_EMPTY     -2
#define DLIST_GETNODE   -3
#define DLIST_MEMORY    -4
#define DLIST_BOL       -5
#define DLIST_EOL       -6
#define DLIST_POSITION  -7

/* Type */
typedef struct DListNode
{
        struct DListNode *next;
        struct DListNode *prev;
        void             *data;
} DLISTNODE;

typedef struct DList
{
        DLISTNODE        *head;     /* the head of the list */
        DLISTNODE        *tail;
        DLISTNODE        *current;  /* the current node */
        int              nr_nodes;  /* Current number of entries */
        int              data_len;  /* Length of data entry */
} DLIST;
                         
/* Functions */
DLIST *DList_Create(int len);               /* Allocate single list */
void DList_Free(DLIST *theDList);           /* Deallocate single list */

void DList_Clear(DLIST *theDList);          /* Remove all entries */

int IsDList_Empty(DLIST *theDList);         /* TRUE for empty list */
int IsDList_Full(DLIST *theDList);          /* TRUE for full list */

int DList_Size(DLIST *theDList);            /* Gets number of entries */

int DList_GetPos(DLIST *theDList);          /* Current position */
int DList_SetPos(DLIST *theDList,int pos);  /* Set position */

int DList_FindNext(DLIST *theDList);        /* sets position to next */
int DList_FindPrev(DLIST *theDList);        /* set position to previous */
int DList_FindKey(DLIST *theDList,
                  void *key);               /* seeks data */

int DList_Update(DLIST *theDList,
                 void *ndata);              /* enter value in current */
int DList_Retrieve(DLIST *theDList,
                   void *ndata);            /* gets current data */
int DList_Delete(DLIST *theDList);          /* delete current node */

int DList_InsertBefore(DLIST *theDList,     /* insert before current */
                       void *ndata);
int DList_InsertAfter(DLIST *theDList,      /* insert after current */
                      void *ndata);

/* Support functions */
DLISTNODE *DList_GetNode(DLIST *theDList);  /* Allocate an entry node */
void DList_FreeNode(DLISTNODE *theDList);   /* Deallocate entry node */

/* end */
