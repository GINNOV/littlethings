#include <crbinc/inc.h>
#include <crbinc/memutil.h>

/*structs:*/
struct MemBlock
  {
  struct MemBlock * Next;
  char * MemBase;
  char * MemPtr;
  long MemLength;
  long MemFree;
  };

typedef struct _MemPool
  {
  long HunkLength;
  struct MemBlock * CurMemBlock;
  struct MemBlock * MemBlock;
  long AutoExtendNumItems;
  long NumFreedHunks;
  long MaxNumFreedHunks;
  void ** FreedHunks;
  } MemPool;

/*
 *  MemPool
 *    system for fast Resetting & Freeing of nodes; for use in tree structures
 *     requires no traversing for freeing
 *    does auto-extending of memory space in case you use more space than
 *     expected or if you don't know how much you will need
 *
 */

/*protos:*/
MemPool * AllocPool(long HunkLength,long NumHunks,long AutoExtendNumItems);
bool ExtendPool(MemPool * Pool,long NumHunks);
void FreePool(MemPool * Pool); /*ok to call with Pool = NULL;*/
void ResetPool(MemPool * Pool);
void * GetPoolHunk(MemPool * Pool,bool AutoExtendFlag);
bool FreePoolHunk(MemPool * Pool,void *Hunk);

/*
 * HunkLength is forced to be a multiple of 4
 */
MemPool * AllocPool (long HunkLength,long NumHunks,long AutoExtendNumItems)
{
MemPool * Ret;

if ( (Ret = malloc(sizeof(MemPool))) == NULL )
  return(NULL);

Ret->HunkLength = PaddedSize(HunkLength);
Ret->CurMemBlock = NULL;
Ret->MemBlock = NULL;
Ret->NumFreedHunks = 0;
Ret->MaxNumFreedHunks = 16;
Ret->AutoExtendNumItems = AutoExtendNumItems;

if ( (Ret->FreedHunks = malloc(Ret->MaxNumFreedHunks*sizeofpointer)) == NULL )
  {
  free(Ret);
  return(NULL);
  }

if ( ! ExtendPool(Ret,NumHunks) )
  {
  free(Ret->FreedHunks);
  free(Ret);
  return(NULL);
  }

return(Ret);
}

void FreePool(MemPool * Pool)
{
struct MemBlock * CurMemBlock;
struct MemBlock * NextMemBlock;

if ( Pool == NULL ) return;

CurMemBlock = Pool->MemBlock;
while(CurMemBlock)
  {
  free(CurMemBlock->MemBase);
  NextMemBlock = CurMemBlock->Next;
  free(CurMemBlock);
  CurMemBlock = NextMemBlock;
  }

free(Pool->FreedHunks);
free(Pool);
}

void * GetPoolHunk (MemPool * Pool,bool AutoExtendFlag)
{
void * Ret;
struct MemBlock * CurMemBlock;

if ( Pool->NumFreedHunks > 0 )
  {
  Pool->NumFreedHunks--;
  Ret = Pool->FreedHunks[Pool->NumFreedHunks];
  return(Ret);
  }

if ( (CurMemBlock = Pool->CurMemBlock) == NULL )
  return(NULL);

if ( CurMemBlock->MemFree < Pool->HunkLength )
  {
  if ( AutoExtendFlag )
    {
    if ( ! ExtendPool(Pool,Pool->AutoExtendNumItems) )
      return(NULL);
    CurMemBlock = Pool->CurMemBlock;
    }
  else
    {
    return(NULL);
    }
  }

Ret = (void *) CurMemBlock->MemPtr;

CurMemBlock->MemFree -= Pool->HunkLength;
CurMemBlock->MemPtr  += Pool->HunkLength;

MemClear(Ret,Pool->HunkLength);

return(Ret);
}

void ResetPool(MemPool * Pool)
{
struct MemBlock * CurMemBlock;

Pool->NumFreedHunks = 0;
Pool->CurMemBlock = Pool->MemBlock;

CurMemBlock = Pool->MemBlock;
while ( CurMemBlock )
  {
  CurMemBlock->MemFree = CurMemBlock->MemLength;
  CurMemBlock->MemPtr = CurMemBlock->MemBase;

  /* MemClear */
    {
    register long *DonePtr;
    register long *MemPtr;

    MemPtr =(long *)(CurMemBlock->MemBase);
    DonePtr=(long *)((char *)MemPtr+CurMemBlock->MemLength);

    while(MemPtr<DonePtr)
      {
      *MemPtr = 0;
      MemPtr ++;
      }
    }
  /* */

  CurMemBlock = CurMemBlock->Next;
  }

}

bool ExtendPool(MemPool * Pool, long NumHunks)
{
struct MemBlock * NewMemBlock;

NewMemBlock = Pool->MemBlock;
while ( NewMemBlock )
  {
  if ( NewMemBlock->MemFree > Pool->HunkLength )
    {
    Pool->CurMemBlock = NewMemBlock;
    return(1);
    }
  NewMemBlock = NewMemBlock->Next;
  }

if ( (NewMemBlock = malloc(sizeof(struct MemBlock))) == NULL )
  return(0);

NewMemBlock->MemLength = NumHunks * Pool->HunkLength;
NewMemBlock->MemFree = NewMemBlock->MemLength;

if ( (NewMemBlock->MemBase = malloc(NewMemBlock->MemLength)) == NULL )
  {
  free(NewMemBlock);
  return(0);
  }

NewMemBlock->MemPtr = NewMemBlock->MemBase;

NewMemBlock->Next = Pool->MemBlock;
Pool->MemBlock = NewMemBlock;

Pool->CurMemBlock = NewMemBlock;

return(1);
}

bool FreePoolHunk(MemPool * Pool,void * Hunk)
{
if ( Pool->NumFreedHunks >= Pool->MaxNumFreedHunks )
  {
  void ** NewFreedHunks;

  if ( (NewFreedHunks = malloc((Pool->MaxNumFreedHunks<<1)*sizeof(void *))) == NULL )
    return(0);

  MemCpyFast(NewFreedHunks,Pool->FreedHunks,Pool->MaxNumFreedHunks);

  free(Pool->FreedHunks);
  
  Pool->FreedHunks = NewFreedHunks;
  Pool->MaxNumFreedHunks <<= 1;
  }

Pool->FreedHunks[Pool->NumFreedHunks] = Hunk;
Pool->NumFreedHunks++;

return(1);
}
