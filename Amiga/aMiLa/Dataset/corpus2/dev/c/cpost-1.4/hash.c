/*------------------------------------------------------------------
 * hash.c : hash table functions
 *------------------------------------------------------------------
 * 10-19-88 originally by Patrick J. Mueller
 * 08-07-92 fixed up by Patrick J. Mueller
 *------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "list.h"
#include "hash.h"

/*------------------------------------------------------------------
 * create hash table
 *------------------------------------------------------------------*/
Hash *HashCreate(
   int                  itemSize,
   int                  buckets,
   HashFunc            *hashFunc,
   ListCompareFunc     *cmpFunc,
   ListNoMemFunc       *memFunc
   )
   {
   Hash *hash;
   int   i;

   /*---------------------------------------------------------------
    * sanity check
    *---------------------------------------------------------------*/
   if (!itemSize || !buckets || !cmpFunc || !hashFunc)
      return NULL;

   /*---------------------------------------------------------------
    * allocate table structure
    *---------------------------------------------------------------*/
   hash = malloc(sizeof(List));
   if (!hash)
      {
      if (memFunc)
         memFunc();
      return NULL;
      }

   /*---------------------------------------------------------------
    * fill in fields
    *---------------------------------------------------------------*/
   hash->itemSize = itemSize;
   hash->buckets  = buckets;
   hash->hashFunc = hashFunc;
   hash->memFunc  = memFunc;

   /*---------------------------------------------------------------
    * allocate buckets
    *---------------------------------------------------------------*/
   hash->bucket = malloc(buckets*sizeof(List *));
   if (!hash->bucket)
      {
      free(hash);

      if (memFunc)
         memFunc();

      return NULL;
      }

   /*---------------------------------------------------------------
    * initialize to zero
    *---------------------------------------------------------------*/
   memset(hash->bucket,0,buckets*sizeof(List *));

   /*---------------------------------------------------------------
    * initialize buckets
    *---------------------------------------------------------------*/
   for (i=0; i<buckets; i++)
      {
      hash->bucket[i] = ListCreate(itemSize,cmpFunc,memFunc);

      if (!hash->bucket[i])
         {
         HashDestroy(hash);

         if (memFunc)
            memFunc();
         }
      }

   /*---------------------------------------------------------------
    * return
    *---------------------------------------------------------------*/
   return hash;
   }

/*------------------------------------------------------------------
 * destroy hash table
 *------------------------------------------------------------------*/
void HashDestroy(
   Hash *hash
   )
   {
   int i;

   if (!hash)
      return;

   for (i=0; i<hash->buckets; i++)
      ListDestroy(hash->bucket[i]);

   free(hash->bucket);
   free(hash);
   }

/*------------------------------------------------------------------
 * find entry in hash table
 *------------------------------------------------------------------*/
void *HashFind(
   Hash *hash,
   void *pItem
   )
   {
   int h;

   if (!hash)
      return NULL;

   h = hash->hashFunc(pItem,hash->buckets);
   if ((h < 0) || (h >= hash->buckets))
      return NULL;

   return ListFind(hash->bucket[h],pItem);
   }

/*------------------------------------------------------------------
 * add entry to hash table
 *------------------------------------------------------------------*/
void *HashAdd(
   Hash *hash,
   void *pItem
   )
   {
   int h;

   if (!hash)
      return NULL;

   h = hash->hashFunc(pItem,hash->buckets);
   if ((h < 0) || (h >= hash->buckets))
      return NULL;

   return ListAdd(hash->bucket[h],pItem);
   }

/*------------------------------------------------------------------
 * delete entry from hash table
 *------------------------------------------------------------------*/
void HashDelete(
   Hash *hash,
   void *pItem
   )
   {
   int h;

   if (!hash)
      return;

   h = hash->hashFunc(pItem,hash->buckets);
   if ((h < 0) || (h >= hash->buckets))
      return;

   ListDelete(hash->bucket[h],pItem);
   }

/*------------------------------------------------------------------
 * iterate through hash table
 *------------------------------------------------------------------*/
void HashIterate(
   Hash            *hash,
   ListIterateFunc *pIterateFunc,
   void            *pUserData
   )
   {
   int i;

   if (!hash)
      return;

   for (i=0; i<hash->buckets; i++)
      ListIterate(hash->bucket[i],pIterateFunc,pUserData);
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
 * hash function
 *------------------------------------------------------------------*/
static int hashFunc(
   void *overi,
   int   buckets
   )
   {
   int *i = overi;
   return *i % buckets;
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
   Hash *iHash;
   int   i;
   int   counter;

   iHash = HashCreate(sizeof(int),3,compareFunc,hashFunc,NULL);

   for (i= 1; i<10; i++)
      HashAdd(iHash,&i);

   for (i=20; i>10; i--)
      HashAdd(iHash,&i);

   for (i=0; i<=21; i++)
      if (!HashFind(iHash,&i))
         printf("didn't find %d\n",i);

   counter = 1;
   HashIterate(iHash,iterateFunc,&counter);

   for (i=-1; i<5; i++)
      HashDelete(iHash,&i);

   for (i=21; i>15; i--)
      HashDelete(iHash,&i);

   counter = 1;
   HashIterate(iHash,iterateFunc,&counter);

   HashDestroy(iHash);

   return 0;
   }

#endif
