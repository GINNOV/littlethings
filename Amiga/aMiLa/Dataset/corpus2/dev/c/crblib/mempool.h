#ifndef CRB_MEMPOOL_H
#define CRB_MEMPOOL_H

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

extern MemPool * AllocPool(long HunkLength,long NumHunks,long AutoExtendNumItems);
extern bool ExtendPool(MemPool * Pool,long NumHunks);
extern void FreePool(MemPool * Pool); /*ok to call this with Pool == NULL*/
extern void ResetPool(MemPool * Pool);
extern void * GetPoolHunk(MemPool * Pool,bool AutoExtendFlag);
extern bool FreePoolHunk(MemPool * Pool,void *Hunk);

 /* NOTEZ: GetPool clears the memory block to zeros*/

#endif /*CRB_MEMPOOL_H*/
