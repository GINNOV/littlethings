/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * AMemList wrapper class                                                    *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_AMemList_H
#define ASAP_AMemList_H

#include <New.h>

extern "C"
{
 #include <EXEC/Memory.h>
 #include <Proto/EXEC.h>
}

template <unsigned int EntryCount>
class AMemList : public MemList
{
 public:
 
 LONG Entries[(EntryCount - 1) * 2];

 inline AMemList * AllocEntry();
 inline void * operator new(size_t, MemList *);
 inline void FreeEntry();
 inline void operator delete (void *);
};
//----------------------------------------------------------------------------
template <unsigned int EntryCount>
AMemList * AMemList<EntryCount>::AllocEntry ()
{
 return (AMemList *) ::AllocEntry(this);
}
//----------------------------------------------------------------------------
template <unsigned int EntryCount>
void * AMemList<EntryCount>::operator new (size_t, MemList *entry)
{
 return (AMemList *) ::AllocEntry(entry);
}
//----------------------------------------------------------------------------
template <unsigned int EntryCount>
void AMemList<EntryCount>::FreeEntry ()
{
 ::FreeEntry(this);
}
//----------------------------------------------------------------------------
template <unsigned int EntryCount>
void AMemList<EntryCount>::operator delete (void *entry)
{
 ((AMemList *) entry)->FreeEntry();
}

#endif
