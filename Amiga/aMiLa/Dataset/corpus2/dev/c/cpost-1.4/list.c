/*------------------------------------------------------------------
 * list.c : list functions
 *------------------------------------------------------------------
 * 10-19-88 originally by Patrick J. Mueller
 * 08-07-92 fixed up by Patrick J. Mueller
 *------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"

/*------------------------------------------------------------------
 * create a list
 *------------------------------------------------------------------*/
List *ListCreate(
   int              itemSize,
   ListCompareFunc *cmpFunc,
   ListNoMemFunc   *memFunc
   )
   {
   List *list;

   /*---------------------------------------------------------------
    * sanity check
    *---------------------------------------------------------------*/
   if (!itemSize || !cmpFunc)
      return NULL;

   /*---------------------------------------------------------------
    * allocate structure
    *---------------------------------------------------------------*/
   list = malloc(sizeof(List));
   if (!list)
      {
      if (memFunc)
         memFunc();

      return NULL;
      }

   /*---------------------------------------------------------------
    * set fields
    *---------------------------------------------------------------*/
   list->head     = NULL;
   list->itemSize = itemSize;
   list->count    = 0;
   list->cmpFunc  = cmpFunc;
   list->memFunc  = memFunc;

   return list;
   }

/*------------------------------------------------------------------
 * destroy a list
 *------------------------------------------------------------------*/
void ListDestroy(
   List *list
   )
   {
   ListNode *node;
   ListNode *next;

   if (!list)
      return;

   /*---------------------------------------------------------------
    * destroy each node
    *---------------------------------------------------------------*/
   node = list->head;
   while (node)
      {
      next = node->next;
      free(node->pItem);
      free(node);
      node = next;
      }

   /*---------------------------------------------------------------
    * destroy list
    *---------------------------------------------------------------*/
   free(list);
   }

/*------------------------------------------------------------------
 * get number of items in list
 *------------------------------------------------------------------*/
int ListCount(
   List *list
   )
   {
   if (!list)
      return 0;
   else
      return list->count;
   }

/*------------------------------------------------------------------
 * find an item
 *------------------------------------------------------------------*/
void *ListFind(
   List *list,
   void *pItem
   )
   {
   ListNode *node;
   int       cmp;

   if (!list || !pItem)
      return NULL;

   /*---------------------------------------------------------------
    * look for item
    *---------------------------------------------------------------*/
   for (node=list->head; node; node=node->next)
      {
      cmp = list->cmpFunc(pItem,node->pItem);

      if (0 == cmp)
         return node->pItem;

      else if (cmp < 0)
         return NULL;
      }

   return NULL;
   }

/*------------------------------------------------------------------
 * add an item
 *------------------------------------------------------------------*/
void *ListAdd(
   List      *list,
   void      *pItem
   )
   {
   ListNode *last;
   ListNode *node;
   ListNode *new;
   int       cmp;

   if (!list || !pItem)
      return NULL;

   /*---------------------------------------------------------------
    * find insertion point
    *---------------------------------------------------------------*/
   last = NULL;
   for (node=list->head; node; node=node->next)
      {
      cmp = (list->cmpFunc)(pItem,node->pItem);

      if (0 == cmp)
         return NULL;

      else if (cmp < 0)
         break;

      last = node;
      }

   /*---------------------------------------------------------------
    * allocate memory
    *---------------------------------------------------------------*/
   new = malloc(sizeof(ListNode));
   if (new)
      new->pItem = malloc(list->itemSize);

   if (!new || !new->pItem)
      {
      if (list->memFunc)
         list->memFunc();
      return NULL;
      }

   /*---------------------------------------------------------------
    * update count, copy item
    *---------------------------------------------------------------*/
   list->count++;
   memcpy(new->pItem,pItem,list->itemSize);

   /*---------------------------------------------------------------
    * link into list
    *---------------------------------------------------------------*/
   if (last)
      {
      new->next  = last->next;
      last->next = new;
      }

   else
      {
      new->next  = list->head;
      list->head = new;
      }

   return new->pItem;
   }

/*------------------------------------------------------------------
 * delete an item
 *------------------------------------------------------------------*/
void ListDelete(
   List *list,
   void *pItem
   )
   {
   ListNode *last;
   ListNode *node;
   int      cmp;

   if (!list || !pItem)
      return;

   /*---------------------------------------------------------------
    * find node
    *---------------------------------------------------------------*/
   last = NULL;
   for (node=list->head; node; node=node->next)
      {
      cmp = (list->cmpFunc)(pItem,node->pItem);
      if (0 == cmp)
         break;

      else if (cmp < 0)
         return;

      last = node;
      }

   /*---------------------------------------------------------------
    * if not found, exit
    *---------------------------------------------------------------*/
   if (!node)
      return;

   /*---------------------------------------------------------------
    * unlink from list
    *---------------------------------------------------------------*/
   if (last)
      {
      if (last->next)
         last->next = last->next->next;
      else
         last->next = NULL;
      }

   else
      list->head = node->next;

   /*---------------------------------------------------------------
    * update count, destroy item
    *---------------------------------------------------------------*/
   list->count--;

   free(node->pItem);
   free(node);
   }

/*------------------------------------------------------------------
 * iterate through items
 *------------------------------------------------------------------*/
void ListIterate(
   List            *list,
   ListIterateFunc *pIterateFunc,
   void            *pUserData
   )
   {
   ListNode *node;

   if (!list || !pIterateFunc)
      return;

   for (node=list->head; node; node=node->next)
      pIterateFunc(node->pItem,pUserData);
   }

/*------------------------------------------------------------------
 * test suite
 *------------------------------------------------------------------*/
#if defined(TEST)

/*------------------------------------------------------------------
 * compare function
 *------------------------------------------------------------------*/
static int compareFunc(
   void *overi1,
   void *overi2
   )
   {
   int *i1 = overi1;
   int *i2 = overi2;

   if      (*i1 < *i2) return -1;
   else if (*i1 > *i2) return  1;
   else                return  0;
   }

/*------------------------------------------------------------------
 * iterate function
 *------------------------------------------------------------------*/
static void iterateFunc(
   void *overI,
   void *overCounter
   )
   {
   int *pi       = overI;
   int *pCounter = overCounter;

   printf("%5d : %5d\n",*pCounter,*pi);
   *pCounter += 1;
   }

/*------------------------------------------------------------------
 *
 *------------------------------------------------------------------*/
int main(void)
   {
   List *iList;
   int   i;
   int   counter;

   iList = ListCreate(sizeof(int),compareFunc,NULL);

   printf("%d items\n",ListCount(iList));

   for (i= 1; i<10; i++)
      ListAdd(iList,&i);

   for (i=20; i>10; i--)
      ListAdd(iList,&i);

   for (i=0; i<=21; i++)
      if (!ListFind(iList,&i))
         printf("didn't find %d\n",i);

   printf("\n");
   printf("%d items\n",ListCount(iList));
   counter = 1;
   ListIterate(iList,iterateFunc,&counter);

   for (i=-1; i<5; i++)
      ListDelete(iList,&i);

   for (i=21; i>15; i--)
      ListDelete(iList,&i);

   printf("\n");
   printf("%d items\n",ListCount(iList));
   counter = 1;
   ListIterate(iList,iterateFunc,&counter);

   ListDestroy(iList);

   return 0;
   }

#endif
