/*------------------------------------------------------------------
 * list.h : list functions
 *------------------------------------------------------------------
 * 10-19-88 originally by Patrick J. Mueller
 * 08-07-92 fixed up by Patrick J. Mueller
 *------------------------------------------------------------------*/

#if !defined(LIST_H_INCLUDED)
#define LIST_H_INCLUDED

typedef int  ListCompareFunc (void *pItem1, void *pItem2);
typedef void ListIterateFunc (void *pItem,  void *pUserData);
typedef void ListNoMemFunc   (void);

typedef struct ListNode ListNode;
struct ListNode
   {
   void     *pItem;
   ListNode *next;
   };

typedef struct List
   {
   int              count;
   int              itemSize;
   ListNode        *head;
   ListCompareFunc *cmpFunc;
   ListNoMemFunc   *memFunc;
   } List;

/*------------------------------------------------------------------
 * create a list
 *------------------------------------------------------------------*/
List *ListCreate(
   int              itemSize,
   ListCompareFunc *cmpFunc,
   ListNoMemFunc   *memFunc
   );

/*------------------------------------------------------------------
 * destroy a list
 *------------------------------------------------------------------*/
void ListDestroy(
   List *list
   );

/*------------------------------------------------------------------
 * count items in list
 *------------------------------------------------------------------*/
int ListCount(
   List *list
   );

/*------------------------------------------------------------------
 * find an item
 *------------------------------------------------------------------*/
void *ListFind(
   List *list,
   void *pItem
   );

/*------------------------------------------------------------------
 * add an item to the list
 *------------------------------------------------------------------*/
void *ListAdd(
   List *list,
   void *pItem
   );

/*------------------------------------------------------------------
 * delete item from list
 *------------------------------------------------------------------*/
void ListDelete(
   List *list,
   void *pItem
   );

/*------------------------------------------------------------------
 * iterate through list
 *------------------------------------------------------------------*/
void ListIterate(
   List            *list,
   ListIterateFunc *pIterateFunc,
   void            *pUserData
   );

#endif
