/*
**     $VER: MemoryManagement.c V0.02 (20-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 14-06-95  Version 0.01     Initial module.
**              20-06-95  Version 0.02     FreeMemory and FreeThisMem have
**                                         completly rewritten. FreeThisMem
**                                         now marks freed memory as invalid.
**                                         FreeMemory relies entierly on
**                                         FreeThisMem.
**
**  MemoryManagement.c contains all the neseccary functions to control
**  memory management for IFFConverter.
**
*/


#include <exec/memory.h>
#include <proto/exec.h>

#include "IFFConverter.h"


// Defining variables
APTR LoadFileName     = NULL;
APTR SaveFileName     = NULL;
APTR SaveBuffer       = NULL;
ULONG * ColourMap     = NULL;
ULONG * SColourMap    = NULL;
ULONG * PlanePtrs     = NULL;
STRPTR GraphicsDrawer = NULL;

ULONG LoadFileNameSize   = 0;
ULONG SaveFileNameSize   = 0;
ULONG SaveBufferSize     = 0;
ULONG GraphicsDrawerSize = 0;
ULONG ColourMapSize      = 16*4;
ULONG PlanePtrsSize;

// Defining protos
void AllocateMemory(void);
BOOL AllocThisMem(APTR *, ULONG, ULONG);
BOOL AllocThisMemNoComplain(APTR *, ULONG, ULONG);
void FreeMemory(void);
void FreeThisMem(APTR, ULONG);

/*
**  AllocateMemory()
**
**     Will allocate all the needed memory for IFFConverter to run. When
**     'AllocateMemory' fails, it will notify the user of the problem
**     and waits until the user acknowlege the problem and then it quits.
**
**  pre:  None.
**  post: None.
**
*/
void AllocateMemory()
{
   if( AllocThisMem(&ColourMap, ColourMapSize, MEMF_CLEAR) )
      if( AllocThisMem(&SColourMap, ColourMapSize, MEMF_CLEAR) )
         // We know that all necessay memory has been allocated,
         // so let us return to the calling function.
         return;
         
   ErrorHandler( IFFerror_NoMemory, (APTR)ColourMapSize );   // Exit to system.
}


/*
**  Result = AllocThisMem(MemToAlloc, MemToAllocSize, MemType)
**
**     Alloacates a piece of memory when possible. If it turns out
**     to be impossible, then the users will be notified of the
**     problem and 'AllocThisMem' will wait until the user will
**     acknowlege the problem. The memory will be allocated according
**     to 'MemType'.
**
**  pre:  MemToAlloc - NULL Pointer.
**        MemToAllocSize - Size of the memory to alloacte.
**        MemType - Type of memory to be allocated.
**  post: MemToAlloc - Pointer to allocated memory. Or NULL if failure.
**        Result - TRUE if memory allocation was succesful,
**                 FALSE if unsuccesful.
**
*/
BOOL AllocThisMem(APTR *MemToAlloc, ULONG MemToAllocSize, ULONG MemType)
{
   if(!(*MemToAlloc = AllocMem(MemToAllocSize, MemType)))
   {
      ErrorHandler( IFFerror_NoMemoryDoReturn, (APTR)MemToAllocSize );
      return(FALSE);
   }

   return(TRUE);
}


/*
**  Result = AllocThisMemNoComplain( MemToAlloc, MemToAllocSize, MemType)
**
**     Specification are the same as AllocTheMem. The exception however,
**     is that this function will no complain about failure of 'AllocMem()'.
**     It will just return TRUE for a succes and FALSE for failure.
**
*/
BOOL AllocThisMemNoComplain(APTR *MemToAlloc, ULONG MemToAllocSize, ULONG MemType)
{
   if(!(*MemToAlloc = AllocMem(MemToAllocSize, MemType)))
      return(FALSE);
   return(TRUE);
}


/*
**  FreeMemory()
**
**     Will give back all the allocated memory (you gotta keep friends).
**
**  pre:  None.
**  post: None.
**
*/
void FreeMemory()
{
   FreeThisMem(&LoadFileName, LoadFileNameSize);
   FreeThisMem(&SaveFileName, SaveFileNameSize);
   FreeThisMem(&ColourMap, ColourMapSize);
   FreeThisMem(&SColourMap, ColourMapSize);
   FreeThisMem(&PlanePtrs, PlanePtrsSize);
   FreeThisMem(&SaveBuffer, SaveBufferSize);
   FreeThisMem(&GraphicsDrawer, GraphicsDrawerSize);
}


/*
**  FreeThisMem(MemToFree, MemToFreenSize)
**
**     Frees when possible a piece of allocated memory. NOTE: be sure
**     to free allocated memory ONLY!!!! When the memory has been freed,
**     MemToFree will be marked as invalid (NULL).
**
**  pre:  MemToFree - Pointer to Allocated memory or NULL.
**        MemToFreeSize - Size of memory to be freeed.
**  post: MemToFree - NULL.
**
*/
void FreeThisMem(APTR *MemToFree, ULONG MemToFreeSize)
{
   if(*MemToFree)
   {
      FreeMem(*MemToFree, MemToFreeSize);
      *MemToFree = NULL;
   }
}
