/*****************************************************************************
 *                                                                           *
 * ASAP - Amiga Software Authoring Platform                                  *
 *                                                                           *
 * Written by Laurie Perrin                                                  *
 *                                                                           *
 * ALocalContextItem wrapper class                                           *
 *                                                                           *
 *****************************************************************************/

#ifndef ASAP_LocalContextItem_H
#define ASAP_LocalContextItem_H

#include <New.h>

extern "C"
{
 #include <Proto/IFFParse.h>
}

class ALocalContextItem : public LocalContextItem
{
 public:
 inline static ALocalContextItem *AllocLocalItem( long type, long id, long ident, long dataSize);
 inline void * operator new (size_t, long type, long id, long ident, long dataSize);
 inline APTR LocalItemData();
 inline void FreeLocalItem();
 inline void operator delete (void *localItem);
 inline void SetLocalItemPurge(Hook *purgeHook);
};
//-----------------------------------------------------------------------------
ALocalContextItem * ALocalContextItem::AllocLocalItem (long type, long id, long ident, long dataSize)
{
 return (ALocalContextItem *) ::AllocLocalItem(type, id, ident, dataSize);
}
//-----------------------------------------------------------------------------
void * ALocalContextItem::operator new (size_t, long type, long id, long ident, long dataSize)
{
 return ALocalContextItem::AllocLocalItem(type, id, ident, dataSize);
}
//-----------------------------------------------------------------------------
APTR ALocalContextItem::LocalItemData ()
{
 return ::LocalItemData(this);
}
//-----------------------------------------------------------------------------
void ALocalContextItem::FreeLocalItem ()
{
 ::FreeLocalItem(this);
}
//-----------------------------------------------------------------------------
void ALocalContextItem::operator delete (void *localItem)
{
 ((ALocalContextItem *) localItem)->FreeLocalItem();
}
//-----------------------------------------------------------------------------
void ALocalContextItem::SetLocalItemPurge (Hook *purgeHook)
{
 ::SetLocalItemPurge(this, purgeHook);
}

#endif