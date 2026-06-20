
#ifndef PACKER_H
#define PACKER_H

/*********************************************************************** 
 * The PackedMem structure is returned from the Pack Routine.Use it to *
 * get information about the memory that was packed.                   *
 * Remember to free the structure and memory by calling freepack(pack).*
 ***********************************************************************/ 

struct  PackedMem 
   {
   UBYTE *MemPtr;      /* Pointer to start address of packed memory.  */
   ULONG Count;        /* Count of how much memory is packed.         */
   ULONG AllocCount;   /* How much memory we allocated for packing.   */
   ULONG Size;         /* Orignal size that we packed.                */
   };

#endif PACKER_H

