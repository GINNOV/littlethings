/*
         SList.h
         -------
         Header file for implementation of a generic single linked list.
         
         Author: C. De Maeyer
         Date  : 20-06-1994
         
         (C) 1994 Blue Heaven Software - All rights reserved.
*/

#ifndef SLIST_H
#define SLIST_H
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
#define SLIST_MAX INT_MAX     /* Max number of entries */

/* Status */  
#define SLIST_OK        0
#define SLIST_FULL      -1
#define SLIST_EMPTY     -2
#define SLIST_GETNODE   -3
#define SLIST_MEMORY    -4
#define SLIST_BOL       -5
#define SLIST_EOL       -6
#define SLIST_POSITION  -7

/* Type */
typedef struct SListNode
{
        struct SListNode *next;
        void             *data;
} SLISTNODE;

typedef struct SList
{
        SLISTNODE        *head;     /* the head of the list */
        SLISTNODE        *current;  /* the current node */
        int              nr_nodes;  /* Current number of entries */
        int              data_len;  /* Length of data entry */
} SLIST;
                         
/* Functions */
SLIST *SList_Create(int len);               /* Allocate single list */
void SList_Free(SLIST *theSList);           /* Deallocate single list */

void SList_Clear(SLIST *theSList);          /* Remove all entries */

int IsSList_Empty(SLIST *theSList);         /* TRUE for empty list */
int IsSList_Full(SLIST *theSList);          /* TRUE for full list */

int SList_Size(SLIST *theSList);            /* Gets number of entries */

int SList_GetPos(SLIST *theSList);          /* Current position */
int SList_SetPos(SLIST *theSList,int pos);  /* Set position */

int SList_FindNext(SLIST *theSList);        /* sets position to next */
int SList_FindPrev(SLIST *theSList);        /* set position to previous */
int SList_FindKey(SLIST *theSList,
                  void *key);               /* seeks data */

int SList_Update(SLIST *theSList,
                 void *ndata);              /* enter value in current */
int SList_Retrieve(SLIST *theSList,
                   void *ndata);            /* gets current data */
int SList_Delete(SLIST *theSList);          /* delete current node */

int SList_InsertBefore(SLIST *theSList,     /* insert before current */
                       void *ndata);
int SList_InsertAfter(SLIST *theSList,      /* insert after current */
                      void *ndata);

/* Support functions */
SLISTNODE *SList_GetNode(SLIST *theSList);  /* Allocate an entry node */
void SList_FreeNode(SLISTNODE *theSList);   /* Deallocate entry node */

/* end */
