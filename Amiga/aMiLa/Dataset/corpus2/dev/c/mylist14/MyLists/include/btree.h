/*
         BTree.h
         -------
         Header file for implementation of a generic binary tree.
         
         Author: C. De Maeyer
         Date  : 10-07-1994

         Read through the READ.ME file for more information.
                  
         (C) 1994 Blue Heaven Software - All rights reserved.
*/
#ifndef BTREE_H
#define BTREE_H
#endif

#ifndef STACK_H
#include "stack.h"
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
#define BTREE_MAX INT_MAX     /* Max number of entries */

/* Status */  
#define BTREE_OK        0
#define BTREE_FULL      -1
#define BTREE_EMPTY     -2
#define BTREE_GETNODE   -3
#define BTREE_MEMORY    -4
#define BTREE_LEFT      -5
#define BTREE_RIGHT     -6
#define BTREE_NOTFOUND  -7
#define BTREE_POSITION  -8
#define BTREE_FOUND     -9

/* Type */
typedef struct BTreeNode
{
        struct BTreeNode *left;
        struct BTreeNode *right;
        void             *data;
} BTREENODE;

typedef struct BTree
{
        BTREENODE       *root;     /* the head of the list */
        BTREENODE       *current;  /* the current node */
        int             nr_nodes;  /* Current number of entries */
        int             data_len;  /* Length of data entry */
} BTREE;
                         
/* Functions */
BTREE *BTree_Create(int len); 
void BTree_Free(BTREE *theBTree);  

void BTree_Clear(BTREE *theBTree);

int IsBTree_Empty(BTREE *theBTree);
int IsBTree_Full(BTREE *theBTree);

int BTree_Size(BTREE *theBTree);

int BTree_FindLeft(BTREE *theBTree);
int BTree_FindRight(BTREE *theBTree);
int BTree_FindKey(BTREE *theBTree,void *key,int len,int mode);

int BTree_Retrieve(BTREE *theBTree,void *ndata);
 
int BTree_DelLeaf(BTREE *theBTree);
int BTree_Insert(BTREE *theBTree,void *ndata);

/* Support functions */
BTREENODE *BTree_GetNode(BTREE *theBTree);
void BTree_FreeNode(BTREENODE *theBTree); 

/* end */
