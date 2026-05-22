#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/memory.h>
#include <exec/semaphores.h>

#include <string.h>


#ifdef ORION_TRACK

   #ifndef ORION_NOVEC

      #define AllocVec(size,flags)  dhAllocVec(size,flags,__LINE__,__FILE__);
      #define FreeVec(mem)          dhFreeVec(mem,__LINE__,__FILE__)

      VOID *dhAllocVec(ULONG size,ULONG flags,ULONG line,STRPTR file);
      void dhFreeVec(VOID *mem,ULONG line,STRPTR file);

   #endif

   #ifndef ORION_NOMEM

      #define AllocMem(size,flags) dhAllocMem(size,flags,__LINE__,__FILE__)
      #define FreeMem(mem,size)    dhFreeMem(mem,size,__LINE__,__FILE__)

      VOID *dhAllocMem(ULONG size,ULONG flags,ULONG line,STRPTR file);
      void dhFreeMem(VOID *mem,ULONG size,ULONG line,STRPTR file);

   #endif

   #ifndef ORION_NOBITMAP

      #define AllocBitMap(x,y,depth,flags,friend) dhAllocBitMap(x,y,depth,flags,friend,__LINE__,__FILE__)
      #define FreeBitMap(bm)  dhFreeBitMap(bm,__LINE__,__FILE__)

      struct BitMap *dhAllocBitMap(ULONG sizex,ULONG sizey,ULONG depth,ULONG flags,
               struct BitMap *friend_bitmap,ULONG line,STRPTR file);
      void dhFreeBitMap(struct BitMap *bm,ULONG line,STRPTR file);

   #endif

   #ifndef ORION_NOPOOL

      #define CreatePool(flags,psize,tsize)   dhCreatePool(flags,psize,tsize,__LINE__,__FILE__)
      #define DeletePool(pool)   dhDeletePool(pool,__LINE__,__FILE__)

      #define AllocPooled(pool,size)  dhAllocPooled(pool,size,__LINE__,__FILE__)
      #define FreePooled(pool,mem,size)   dhFreePooled(pool,mem,size,__LINE__,__FILE__)

      VOID *dhAllocPooled(VOID *pool,ULONG size,ULONG line,STRPTR file);
      void dhFreePooled(VOID *pool,VOID *mem,ULONG size,ULONG line,STRPTR file);

      VOID *dhCreatePool(ULONG flags,ULONG p_size,ULONG t_size,ULONG line,STRPTR file);
      void dhDeletePool(VOID *pool,ULONG line,STRPTR file);

   #endif

   #ifndef ORION_NOMALLOC

      #define malloc(size)       dhmalloc(size,__LINE__,__FILE__)
      #define free(mem)          dhfree(mem,__LINE__,__FILE__)

      VOID *dhmalloc(ULONG size,ULONG line,STRPTR file);
      void dhfree(VOID *mem,ULONG line,STRPTR file);

   #endif

#endif
