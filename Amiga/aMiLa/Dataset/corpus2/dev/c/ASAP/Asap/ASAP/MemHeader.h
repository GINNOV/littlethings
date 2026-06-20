/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMemHeader wrapper class                                                  *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMemHeader_H
#define ASAP_AMemHeader_H

extern "C"
{
 #include <EXEC/Memory.h>
 #include <Proto/EXEC.h>
}

class AMemHeader : public MemHeader
{
 public:
 inline APTR Allocate(unsigned long byteSize);
 inline void Deallocate(APTR memoryBlock, unsigned long byteSize);
};
//----------------------------------------------------------------------------
APTR AMemHeader::Allocate (unsigned long byteSize)
{
 return ::Allocate(this, byteSize);
}
//----------------------------------------------------------------------------
void AMemHeader::Deallocate (APTR memoryBlock, unsigned long byteSize)
{
 ::Deallocate(this, memoryBlock, byteSize);
}

#endif
