/*------------------------------------------------------------------
 * hash.h : hash table functions
 *------------------------------------------------------------------
 * 10-19-88 originally by Patrick J. Mueller
 * 08-07-92 fixed up by Patrick J. Mueller
 *------------------------------------------------------------------*/

#if !defined(HASH_H_INCLUDED)
#define HASH_H_INCLUDED

typedef int HashFunc     (void *pItem, int buckets);

typedef struct
   {
   int                itemSize;
   int                buckets;
   List             **bucket;
   HashFunc          *hashFunc;
   ListNoMemFunc     *memFunc;
   } Hash;

/*------------------------------------------------------------------
 * create a hash table
 *------------------------------------------------------------------*/
Hash *HashCreate(
   int                  itemSize,
   int                  buckets,
   HashFunc            *hashFunc,
   ListCompareFunc     *cmpFunc,
   ListNoMemFunc       *memFunc
   );

/*------------------------------------------------------------------
 * destroy a hash table
 *------------------------------------------------------------------*/
void HashDestroy(
   Hash *hash
   );

/*------------------------------------------------------------------
 * find an entry in a hash table
 *------------------------------------------------------------------*/
void *HashFind(
   Hash  *hash,
   void  *pItem
   );

/*------------------------------------------------------------------
 * add an entry to a hash table
 *------------------------------------------------------------------*/
void *HashAdd(
   Hash *hash,
   void *pItem
   );

/*------------------------------------------------------------------
 * delete an entry from a hash table
 *------------------------------------------------------------------*/
void HashDelete(
   Hash *hash,
   void *pTtem
   );

/*------------------------------------------------------------------
 * iterate through hash table
 *------------------------------------------------------------------*/
void HashIterate(
   Hash            *hash,
   ListIterateFunc *pIterateFunc,
   void            *pUserData
   );

#endif
