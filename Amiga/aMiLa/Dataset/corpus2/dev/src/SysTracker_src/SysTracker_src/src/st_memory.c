/***************************************************************************/
/* st_memory.c - Memory control module.                                    */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"
#include "st_strings.h"

/***************************************************************************/
/* Data and defines */

APTR MemPool = NULL;
struct SignalSemaphore MemPoolKey;

/***************************************************************************/

GPROTO BOOL MEM_Init( void )
{
  /*********************************************************************
   *
   * MEM_Init()
   *
   * Initialize the memory resources. This includes creating the main
   * memory pool and initializing a semaphore for it.
   *
   *********************************************************************
   *
   */
  
  if (!(MemPool = (APTR) CreatePool(MEMF_CLEAR | MEMF_PUBLIC,
                            POOL_PUDDLESIZE, POOL_THRESHSIZE)))
    return FALSE;

  memset(&MemPoolKey, 0, sizeof(struct SignalSemaphore));
  InitSemaphore((struct SignalSemaphore *) &MemPoolKey);
  return TRUE;
}

GPROTO void MEM_Free( void )
{
  /*********************************************************************
   *
   * MEM_Free()
   * 
   * Release the resources allocated by MEM_Init().
   *
   *********************************************************************
   *
   */
  
  if (MemPool)
  {
    DeletePool(MemPool); MemPool = NULL;
  }
}

GPROTO APTR MEM_AllocVec( ULONG Size )
{
  /*********************************************************************
   *
   * MEM_AllocVec()
   *
   * Allocate a vector using the main memory pool. Semaphore protected.
   *
   *********************************************************************
   *
   */
  
  register ULONG *Vec;
  Size += 4;
  ObtainSemaphore((struct SignalSemaphore *) &MemPoolKey);  
  if (Vec = AllocPooled(MemPool, Size))
    *Vec++ = Size;
  ReleaseSemaphore((struct SignalSemaphore *) &MemPoolKey);

  return (APTR) Vec;
}
 
GPROTO void MEM_FreeVec( APTR Vec )
{
  /*********************************************************************
   *
   * MEM_FreeVec()
   *
   * Free a vector that was allocated with the MEM_AllocVec() function.
   * Semaphore protected.
   *
   *********************************************************************
   *
   */

  if (Vec)
  { 
    ObtainSemaphore((struct SignalSemaphore *) &MemPoolKey);
    FreePooled(MemPool, ((UBYTE *) Vec) - 4, ((ULONG *) Vec)[-1]);
    ReleaseSemaphore((struct SignalSemaphore *) &MemPoolKey);
  }
}

GPROTO UBYTE *MEM_StrToVec( UBYTE *Str )
{
  /*********************************************************************
   *
   * MEM_StrToVec()
   *
   * Copy a NULL terminated string to a vector, this routine uses
   * MEM_AllocVec() for the actual allocation of the vector, so the
   * result of this call should eventually be freed by MEM_FreeVec().
   *
   * (This should really be in st_strings.c!)
   *
   *********************************************************************
   *
   */

  register UBYTE *StrBuf;

  if (!Str) return NULL;
  if (StrBuf = MEM_AllocVec(strlen(Str) + 1))
    strcpy(StrBuf, Str);

  return StrBuf;
}



