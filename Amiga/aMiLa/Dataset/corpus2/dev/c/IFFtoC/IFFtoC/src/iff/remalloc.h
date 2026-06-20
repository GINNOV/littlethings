/** RemAlloc.h **********************************************************/
/*  ChipAlloc(), ExtAlloc(), RemAlloc(), RemFree().                     */
/*  ALLOCators which REMember the size allocated, for simpler freeing.  */
/*                                                                      */
/* Date      Who Changes                                                */
/* --------- --- -------------------------------------------------------*/
/* 16-Jan-86 sss Created from DPaint/DAlloc.c                           */
/* 22-Jan-86 jhm Include Compiler.h                                     */
/* 25-Jan-86 sss Added ChipNoClearAlloc,ExtNoClearAlloc                 */
/*                                                                      */ 
/* By Jerry Morrison and Steve Shaw, Electronic Arts.                   */ 
/* This software is in the public domain.                               */ 
/*                                                                      */ 
/* This version for the Commodore-Amiga computer.                       */
/*                                                                      */ 
/************************************************************************/
#ifndef REM_ALLOC_H
#define REM_ALLOC_H

#ifndef COMPILER_H
#include "iff/compiler.h"
#endif

#if defined(__GNUC__)
#pragma pack(2)
#endif



/* How these allocators work:
 * The allocator procedures get the memory from the system allocator,
 * actually allocating 4 extra bytes. We store the length of the node in
 * the first 4 bytes then return a ptr to the rest of the storage. The
 * deallocator can then find the node size and free it. */


#ifdef FDwAT

/* RemAlloc allocates a node with "size" bytes of user data.
 * Example:
 *   struct BitMap *bm;
 *   bm = (struct BitMap *)RemAlloc( sizeof(struct BitMap), ...flags... );
 */
extern UBYTE *RemAlloc(LONG, LONG);
                    /* size, flags */

/* ALLOCator that remembers size, allocates in CHIP-accessable memory.
 * Use for all data to be displayed on screen, all sound data, all data to be
 * blitted, disk buffers, or access by any other DMA channel.
 * Does clear memory being allocated.*/    
extern UBYTE *ChipAlloc(LONG);
                     /* size */

/* ChipAlloc, without clearing memory.  Purpose: speed when allocate
 * large area that will be overwritten anyway.*/
extern UBYTE *ChipNoClearAlloc(LONG);
    
/* ALLOCator that remembers size, allocates in extended memory.
 * Does clear memory being allocated.
 * NOTICE: does NOT declare "MEMF_FAST".  This allows machines
 * lacking extended memory to allocate within chip memory,
 * assuming there is enough memory left.*/    
extern UBYTE *ExtAlloc(LONG);
                    /* size */

/* ExtAlloc, without clearing memory.  Purpose: speed when allocate
 * large area that will be overwritten anyway.*/
extern UBYTE *ExtNoClearAlloc(LONG);


/* FREEs either chip or extended memory, if allocated with an allocator
 * which REMembers size allocated.
 * Safe: won't attempt to de-allocate a NULL pointer.
 * Returns NULL so caller can do
 *   p = RemFree(p);
 */
extern UBYTE *RemFree(UBYTE *);
                  /*  p  */

#else /* not FDwAT */

extern UBYTE *RemAlloc();
extern UBYTE *ChipAlloc();
extern UBYTE *ExtAlloc();
extern UBYTE *RemFree();

#endif /* FDwAT */

#if defined(__GNUC__)
#pragma pack()
#endif


#endif REM_ALLOC_H

