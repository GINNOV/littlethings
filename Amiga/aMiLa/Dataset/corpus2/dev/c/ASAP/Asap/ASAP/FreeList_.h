/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AFreeList wrapper class                                                   *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_FreeList_H
#define ASAP_FreeList_H

extern "C"
{
 #include <Proto/Icon.h>
}

class AFreeList : public FreeList
{
 public:
 inline BOOL AddFreeList(APTR mem, unsigned long size);
 inline void FreeFreeList();
};
//----------------------------------------------------------------------------
BOOL AFreeList::AddFreeList (APTR mem, unsigned long size)
{
 return ::AddFreeList(this, mem, size);
}
//----------------------------------------------------------------------------
void AFreeList::FreeFreeList ()
{
 ::FreeFreeList(this);
}

#endif
